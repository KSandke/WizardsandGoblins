import Foundation
import SpriteKit

class Goblin {
    enum GoblinType {
        case normal
        case large
        case small
        case ranged
    }
    
    class GoblinContainer {
        let sprite: SKSpriteNode
        let type: GoblinType
        let healthBar: SKShapeNode
        let healthFill: SKShapeNode
        var health: CGFloat
        let damage: CGFloat
        let maxHealth: CGFloat
                
        init(type: GoblinType, sprite: SKSpriteNode, healthBar: SKShapeNode, healthFill: SKShapeNode, health: CGFloat, damage: CGFloat, maxHealth: CGFloat) {
            self.type = type
            self.sprite = sprite
            self.healthBar = healthBar
            self.healthFill = healthFill
            self.health = health
            self.damage = damage
            self.maxHealth = maxHealth
        }
    }
    
    weak var scene: SKScene?
    var goblinContainers: [GoblinContainer] = []
    
    // Probabilities for each goblin type
    var goblinTypeProbabilities: [GoblinType: Double]
    
    // Add this property near the top of the class
    var nextGoblinType: GoblinType = .normal
    
    // Add ArrowContainer to track arrows
    class ArrowContainer {
        let sprite: SKSpriteNode
        let damage: CGFloat
        
        init(sprite: SKSpriteNode, damage: CGFloat) {
            self.sprite = sprite
            self.damage = damage
        }
    }
    
    // Add property to track arrows
    var arrowContainers: [ArrowContainer] = []
    
    init(scene: SKScene, probabilities: [GoblinType: Double] = [
        .normal: 60.0,
        .large: 15.0,
        .small: 15.0,
        .ranged: 10.0
    ]) {
        self.scene = scene
        self.goblinTypeProbabilities = probabilities
    }

    func spawnGoblin(at position: CGPoint, specificType: GoblinType? = nil) {
        guard let scene = scene else { return }
        
        // Use specificType if provided, otherwise use the probability-based type
        nextGoblinType = specificType ?? getRandomGoblinType()
        
        // Create a goblin of that type
        let goblinSprite = SKSpriteNode(imageNamed: imageName(for: nextGoblinType))
        goblinSprite.size = goblinSize(for: nextGoblinType)
        goblinSprite.position = position
        goblinSprite.name = "goblin"
        
        // Create health bar background
        let healthBarWidth: CGFloat = goblinSprite.size.width * 0.8
        let healthBarHeight: CGFloat = 5
        let healthBar = SKShapeNode(rectOf: CGSize(width: healthBarWidth, height: healthBarHeight))
        healthBar.fillColor = .gray
        healthBar.strokeColor = .black
        healthBar.position = CGPoint(x: 0, y: goblinSprite.size.height / 2 + 5)
        
        // Create health bar fill
        let healthFill = SKShapeNode(rectOf: CGSize(width: healthBarWidth, height: healthBarHeight))
        healthFill.fillColor = .red
        healthFill.strokeColor = .clear
        healthFill.position = healthBar.position
        
        // Add health bars as children of goblin
        goblinSprite.addChild(healthBar)
        goblinSprite.addChild(healthFill)
        
        let physicsBody = SKPhysicsBody(rectangleOf: goblinSprite.size)
        physicsBody.isDynamic = false
        physicsBody.affectedByGravity = false
        physicsBody.allowsRotation = false
        physicsBody.categoryBitMask = 1
        physicsBody.contactTestBitMask = 2
        goblinSprite.physicsBody = physicsBody
        
        let health = goblinHealth(for: nextGoblinType)
        let damage = goblinDamage(for: nextGoblinType)
        let container = GoblinContainer(
            type: nextGoblinType,
            sprite: goblinSprite,
            healthBar: healthBar,
            healthFill: healthFill,
            health: health,
            damage: damage,
            maxHealth: health
        )
        goblinContainers.append(container)
        
        scene.addChild(goblinSprite)
        
        moveGoblin(container: container)
    }
    
    private func getRandomGoblinType() -> GoblinType {
        // Compute total probability
        let totalProbability = goblinTypeProbabilities.values.reduce(0, +)
        // Generate random number between 0 and totalProbability
        let randomValue = Double.random(in: 0..<totalProbability)
        var cumulativeProbability = 0.0
        for (type, probability) in goblinTypeProbabilities {
            cumulativeProbability += probability
            if randomValue < cumulativeProbability {
                return type
            }
        }
        // Default to normal if something goes wrong
        return .normal
    }
    
    private func moveGoblin(container: GoblinContainer) {
        guard let scene = scene as? GameScene else { return }
        let targetPosition = scene.playerView.castlePosition
        
        // Calculate the final position for the goblin
        let finalPosition: CGPoint
        if container.type == .ranged {
            let vector = CGVector(dx: targetPosition.x - container.sprite.position.x,
                                  dy: targetPosition.y - container.sprite.position.y)
            let distance = sqrt(vector.dx * vector.dx + vector.dy * vector.dy)
            let ratio = max(0, (distance - 500) / distance)
            finalPosition = CGPoint(
                x: container.sprite.position.x + vector.dx * ratio,
                y: container.sprite.position.y + vector.dy * ratio
            )
        } else {
            finalPosition = targetPosition
        }
        
        let moveDuration = TimeInterval(container.sprite.position.distance(to: finalPosition) / goblinSpeed(for: container.type))
        let moveAction = SKAction.move(to: finalPosition, duration: moveDuration)
        
        if container.type == .ranged {
            // Ranged goblins move to a position and start shooting arrows
            container.sprite.run(moveAction)
            
            // Create repeating arrow attack
            let spawnArrow = SKAction.run { [weak self] in
                guard let self = self else { return }
                // Ensure the goblin is still alive
                guard self.goblinContainers.contains(where: { $0 === container }) else { return }
                
                // Spawn an arrow towards the castle
                self.spawnArrow(from: container.sprite.position, to: scene.playerView.castlePosition)
            }
            
            // Set up the arrow attack sequence
            let waitAction = SKAction.wait(forDuration: 1.5) // Adjust as needed
            let attackSequence = SKAction.sequence([spawnArrow, waitAction])
            let repeatAttack = SKAction.repeatForever(attackSequence)
            container.sprite.run(repeatAttack, withKey: "rangedAttack")
        } else {
            // Other goblins move and damage the castle upon arrival
            let damageAction = SKAction.run { [weak self] in
                scene.castleTakeDamage(damage: container.damage)
                scene.goblinDied(container: container, goblinKilled: false)
                self?.removeGoblin(container: container)
            }
            let sequence = SKAction.sequence([moveAction, damageAction])
            container.sprite.run(sequence)
        }
    }
    
    func goblinSpeed(for type: GoblinType) -> CGFloat {
        switch type {
        case .normal, .ranged:
            return 100
        case .large:
            return 50
        case .small:
            return 200
        // case .arrow:
        //     return 300
        }
    }
    
    func goblinHealth(for type: GoblinType) -> CGFloat {
        switch type {
        case .normal, .ranged:
            return 50
        case .large:
            return 100
        case .small:
            return 25
        // case .arrow:
        //     return 0
        }
    }
    
    func goblinDamage(for type: GoblinType) -> CGFloat {
        switch type {
        case .normal:
            return 10
        case .large:
            return 20
        case .small:
            return 5
        case .ranged:
            return 5
        // case .arrow:
        //     return 5
        }
    }
    
    func goblinSize(for type: GoblinType) -> CGSize {
        switch type {
        case .normal, .ranged:
            return CGSize(width: 50, height: 50)
        case .large:
            return CGSize(width: 100, height: 100)
        case .small:
            return CGSize(width: 50, height: 50)
        // case .arrow:
        //     return CGSize(width: 10, height: 10)
        }
    }
    
    func imageName(for type: GoblinType) -> String {
        switch type {
        case .normal, .large:
            return "Goblin1"
        case .ranged:
            return "rangedGoblin" // You'll need to add this asset
        // case .arrow:
        //     return "Arrow" // You'll need to add this asset
        case .small:
            return "smallGoblin"
        }
    }
    
    func applySpell(_ spell: Spell, at position: CGPoint, in gameScene: GameScene) {
        var containersToRemove: [GoblinContainer] = []
        var arrowsToRemove: [ArrowContainer] = []
        
        // Check goblins
        for container in goblinContainers {
            let distance = position.distance(to: container.sprite.position)
            if distance <= spell.aoeRadius {
                // Apply damage
                container.health -= spell.damage
                if container.health <= 0 {
                    gameScene.goblinDied(container: container, goblinKilled: true)
                    containersToRemove.append(container)
                } else {
                    // Update health bar
                    let healthRatio = container.health / container.maxHealth
                    container.healthFill.xScale = healthRatio
                    spell.specialEffect?(spell, container)
                }
            }
        }
        
        // Check arrows
        for arrow in arrowContainers {
            let distance = position.distance(to: arrow.sprite.position)
            if distance <= spell.aoeRadius {
                arrowsToRemove.append(arrow)
            }
        }
        
        // Remove affected entities
        for container in containersToRemove {
            removeGoblin(container: container)
        }
        for arrow in arrowsToRemove {
            removeArrow(container: arrow)
        }
    }

    func removeGoblin(container: GoblinContainer) {
        goblinContainers.removeAll { $0 === container }
        container.sprite.removeFromParent()
    }
    
    func removeAllGoblins(in gameScene: GameScene) {
        var containersToRemove: [GoblinContainer] = []
        for container in goblinContainers {
            gameScene.goblinDied(container: container, goblinKilled: false)
            containersToRemove.append(container)
        }

        for container in containersToRemove {
            removeGoblin(container: container)
        }

        // Remove all arrows
        for arrow in arrowContainers {
            removeArrow(container: arrow)
        }
    }

    private func spawnArrow(from startPosition: CGPoint, to targetPosition: CGPoint) {
        guard let scene = scene as? GameScene else { return }

        // Create the arrow sprite
        let arrowSprite = SKSpriteNode(imageNamed: "Arrow")
        arrowSprite.size = CGSize(width: 10, height: 10)
        arrowSprite.position = startPosition
        arrowSprite.zPosition = 1

        // Create arrow container
        let arrowContainer = ArrowContainer(sprite: arrowSprite, damage: 5)
        arrowContainers.append(arrowContainer)

        // Calculate movement duration based on distance and speed
        let moveDuration = TimeInterval(startPosition.distance(to: targetPosition) / arrowSpeed())

        // Define the movement action
        let moveAction = SKAction.move(to: targetPosition, duration: moveDuration)
        let damageAction = SKAction.run { [weak self] in
            scene.castleTakeDamage(damage: arrowContainer.damage)
            self?.removeArrow(container: arrowContainer)
        }
        let sequence = SKAction.sequence([moveAction, damageAction])

        arrowSprite.run(sequence)
        scene.addChild(arrowSprite)
    }

    func removeArrow(container: ArrowContainer) {
        arrowContainers.removeAll { $0 === container }
        container.sprite.removeFromParent()
    }

    func arrowSpeed() -> CGFloat {
        return 300.0 // Adjust the speed as needed
    }
} 
