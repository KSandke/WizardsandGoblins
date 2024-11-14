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
    
    init(scene: SKScene, probabilities: [GoblinType: Double] = [
        .normal: 70.0,
        .large: 15.0,
        .small: 15.0
    ]) {
        self.scene = scene
        self.goblinTypeProbabilities = probabilities
    }

    func spawnGoblin(at position: CGPoint, specificType: GoblinType? = nil) {
        guard let scene = scene else { return }
        
        // Decide which goblin type to spawn
        let goblinType = specificType ?? randomGoblinType()
        
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
        
        // After creating the goblin's physics body
        let physicsBody = SKPhysicsBody(rectangleOf: goblinSprite.size)
        physicsBody.isDynamic = true
        physicsBody.affectedByGravity = false
        physicsBody.allowsRotation = false
        physicsBody.categoryBitMask = PhysicsCategory.goblin
        physicsBody.contactTestBitMask = PhysicsCategory.spell | PhysicsCategory.castle
        physicsBody.collisionBitMask = PhysicsCategory.none
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
        let goblinSpeed = goblinSpeed(for: container.type)
        let distanceToTarget = container.sprite.position.distance(to: targetPosition)
        
        if container.type == .ranged {
            // Ranged goblin stops at attack range and starts attacking
            let attackRange: CGFloat = 300
            
            let stopDistance = max(distanceToTarget - attackRange, 0)
            let adjustedTarget = container.sprite.position.pointTowards(target: targetPosition, distance: stopDistance)
            
            let moveDuration = TimeInterval(stopDistance / goblinSpeed)
            let moveAction = SKAction.move(to: adjustedTarget, duration: moveDuration)
            let startAttacking = SKAction.run { [weak self] in
                self?.startRangedAttack(container: container)
            }
            let sequence = SKAction.sequence([moveAction, startAttacking])
            container.sprite.run(sequence)
        } else {
            // Default behavior for other goblins
            let moveDuration = TimeInterval(distanceToTarget / goblinSpeed)
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
    }
    
    func startRangedAttack(container: GoblinContainer) {
        // Attack action repeats indefinitely
        let attackInterval: TimeInterval = 1.5 // Time between attacks
        let attackAction = SKAction.run { [weak self] in
            self?.performRangedAttack(container: container)
        }
        let waitAction = SKAction.wait(forDuration: attackInterval)
        let attackSequence = SKAction.sequence([attackAction, waitAction])
        let repeatAttack = SKAction.repeatForever(attackSequence)
        container.sprite.run(repeatAttack, withKey: "rangedAttack")
    }

    func performRangedAttack(container: GoblinContainer) {
        guard let scene = scene as? GameScene else { return }
        let targetPosition = scene.playerView.castlePosition
        
        // Create projectile sprite
        let projectile = SKSpriteNode(imageNamed: "GoblinProjectile") // Ensure you have this asset
        projectile.size = CGSize(width: 15, height: 15)
        projectile.position = container.sprite.position
        projectile.name = "goblinProjectile"
        
        // Set physics body for collision detection
        let physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width / 2)
        physicsBody.isDynamic = true
        physicsBody.affectedByGravity = false
        physicsBody.categoryBitMask = PhysicsCategory.goblinProjectile
        physicsBody.contactTestBitMask = PhysicsCategory.castle
        physicsBody.collisionBitMask = PhysicsCategory.none
        projectile.physicsBody = physicsBody
        
        scene.addChild(projectile)
        
        // Calculate movement
        let direction = (targetPosition - projectile.position).normalized()
        let speed: CGFloat = 300.0
        let moveDuration = TimeInterval(projectile.position.distance(to: targetPosition) / speed)
        let moveAction = SKAction.move(to: targetPosition, duration: moveDuration)
        
        // Remove projectile upon reaching the target
        let removeAction = SKAction.removeFromParent()
        let hitAction = SKAction.run { [weak scene] in
            // Apply damage to the castle
            scene?.castleTakeDamage(damage: container.damage)
        }
        
        projectile.run(SKAction.sequence([moveAction, hitAction, removeAction]))
    }

    func goblinSpeed(for type: GoblinType) -> CGFloat {
        switch type {
        case .normal:
            return 100
        case .large:
            return 50   // Half speed
        case .small:
            return 200  // Double speed
        case .ranged:
            return 80   // Set speed for ranged goblin
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
        case .ranged:
            return 50   // Set health for ranged goblin
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
        case .ranged:
            return 10   // Set damage for ranged goblin
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
        case .ranged:
            return CGSize(width: 50, height: 50)   // Set size for ranged goblin
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
        case .ranged:
            return "Goblin1"   // Set image for ranged goblin
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
    func handleSpellHit(on goblinNode: SKSpriteNode) {
        if let container = goblinContainers.first(where: { $0.sprite == goblinNode }) {
            // Apply damage
            container.health -= /* spell damage */
            updateHealthBar(for: container)

            // Check if goblin is dead
            if container.health <= 0 {
                removeGoblin(container: container)
            // Inform the game scene that a goblin has died
            if let gameScene = scene as? GameScene {
                gameScene.goblinDied(container: container, goblinKilled: true)
            }
            }
        }
    }
    private func updateHealthBar(for container: GoblinContainer) {
        let healthPercentage = container.health / container.maxHealth
        container.healthFill.xScale = max(healthPercentage, 0)
    }
}
 