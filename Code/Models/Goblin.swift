import Foundation
import SpriteKit

class GoblinManager {
    enum GoblinType {
        case normal
        case large
        case small
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
    
    init(scene: SKScene, probabilities: [GoblinType: Double]) {
        self.scene = scene
        self.goblinTypeProbabilities = probabilities
    }

    func spawnGoblin(at position: CGPoint) {
        guard let scene = scene else { return }
        
        // Decide which goblin type to spawn based on probabilities
        let goblinType = randomGoblinType()
        
        // Create a goblin of that type
        let goblinSprite = SKSpriteNode(imageNamed: imageName(for: goblinType))
        goblinSprite.size = goblinSize(for: goblinType)
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
        
        let health = goblinHealth(for: goblinType)
        let damage = goblinDamage(for: goblinType)
        let container = GoblinContainer(
            type: goblinType,
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
    
    private func randomGoblinType() -> GoblinType {
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
        let moveDuration = TimeInterval(container.sprite.position.distance(to: targetPosition) / goblinSpeed(for: container.type))
        
        let moveAction = SKAction.move(to: targetPosition, duration: moveDuration)
        let damageAction = SKAction.run { [weak self] in
            scene.castleTakeDamage(damage: container.damage)
            // Call goblinDied with goblinKilled = false for castle collision
            scene.goblinDied(container: container, goblinKilled: false)
            self?.removeGoblin(container: container)
        }
        let sequence = SKAction.sequence([moveAction, damageAction])
        container.sprite.run(sequence)
    }
    
    func goblinSpeed(for type: GoblinType) -> CGFloat {
        switch type {
        case .normal:
            return 100
        case .large:
            return 50   // Half speed
        case .small:
            return 200  // Double speed
        }
    }
    
    func goblinHealth(for type: GoblinType) -> CGFloat {
        switch type {
        case .normal:
            return 50
        case .large:
            return 100  // Double health
        case .small:
            return 25   // Half health
        }
    }
    
    func goblinDamage(for type: GoblinType) -> CGFloat {
        switch type {
        case .normal:
            return 10
        case .large:
            return 20   // Double damage
        case .small:
            return 5    // Half damage
        }
    }
    
    func goblinSize(for type: GoblinType) -> CGSize {
        switch type {
        case .normal:
            return CGSize(width: 50, height: 50)
        case .large:
            return CGSize(width: 100, height: 100)    // Twice as big
        case .small:
            return CGSize(width: 25, height: 25)      // Half the size
        }
    }
    
    func imageName(for type: GoblinType) -> String {
        switch type {
        case .normal:
            return "Goblin1"
        case .large:
            return "Goblin1"   // Update with the appropriate image asset
        case .small:
            return "Goblin1"   // Update with the appropriate image asset
        }
    }
    
    func applySpell(_ spell: Spell, at position: CGPoint, in gameScene: GameScene) {
        var containersToRemove: [GoblinContainer] = []
        
        for container in goblinContainers {
            let distance = position.distance(to: container.sprite.position)
            if distance <= spell.aoeRadius {
                // Apply damage
                container.health -= spell.damage
                if container.health <= 0 {
                    // Goblin dies - pass goblinKilled = true since it was killed by a spell
                    gameScene.goblinDied(container: container, goblinKilled: true)
                    containersToRemove.append(container)
                } else {
                    // Update health bar
                    let healthRatio = container.health / container.maxHealth
                    container.healthFill.xScale = healthRatio
                    // Apply special effects
                    spell.specialEffect?(spell, container)
                }
            }
        }
        
        // Remove goblins after the loop
        for container in containersToRemove {
            removeGoblin(container: container)
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
    }
} 
