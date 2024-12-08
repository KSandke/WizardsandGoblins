import Foundation
import SpriteKit

public class Goblin {
    public enum GoblinType {
        case normal
        case large
        case small
        case ranged
    }
    
    public class GoblinContainer {
        let sprite: SKSpriteNode
        let type: GoblinType
        let healthBar: SKShapeNode
        let healthFill: SKShapeNode
        var health: CGFloat
        var damage: CGFloat
        let maxHealth: CGFloat
        let goldValue: Int
        private var isAttacksPaused = false
        var isRanged: Bool
        var isAttacking: Bool = false
        private var attackTimer: Timer?
        
        // Add status effects tracking
        private var statusEffects: Set<String> = []
        private var statusDurations: [String: TimeInterval] = [:]
        
        init(type: GoblinType, sprite: SKSpriteNode, healthBar: SKShapeNode, healthFill: SKShapeNode, health: CGFloat, damage: CGFloat, maxHealth: CGFloat, goldValue: Int, isRanged: Bool = false) {
            self.type = type
            self.sprite = sprite
            self.healthBar = healthBar
            self.healthFill = healthFill
            self.health = health
            self.damage = damage
            self.maxHealth = maxHealth
            self.goldValue = goldValue
            self.isRanged = isRanged
        }
        
        func applyDamage(_ damage: CGFloat) {
            health -= damage
            
            // Create damage number with isCastleDamage set to false
            if let gameScene = sprite.scene as? GameScene {
                gameScene.playerView.createDamageNumber(
                    damage: Int(damage),
                    at: sprite.position,
                    isCritical: damage >= 50,
                    isCastleDamage: false
                )
            }
            
            // Check if goblin should die
            if health <= 0 {
                // Stop all actions when the goblin dies
                sprite.removeAllActions()
                
                // Find the game scene and notify BEFORE removing the sprite
                if let gameScene = sprite.scene as? GameScene {
                    gameScene.goblinDied(container: self, goblinKilled: true)
                    // Remove from goblinContainers array
                    gameScene.goblinManager.goblinContainers.removeAll { $0 === self }
                }
                
                // Remove the sprite and health bars from the scene
                sprite.removeFromParent()
                return
            }
            
            // Update health bar only if still alive
            let healthRatio = max(0, health / maxHealth)  // Ensure ratio doesn't go negative
            healthFill.xScale = healthRatio
        }
        
        func pauseAttacks() {
            isAttacksPaused = true
            sprite.removeAction(forKey: "rangedAttack") // Stops ranged attacks if applicable
            attackTimer?.invalidate()
        }
        
        func resumeAttacks() {
            isAttacksPaused = false
            if isAttacking {
                guard let scene = sprite.scene as? GameScene else { return }
                startAttacking()
            }
        }
        
        func startAttackingGoblins(in scene: GameScene) {
            // Create an attack sequence
            let attackAction = SKAction.run { [weak self] in
                guard let self = self else { return }
                
                // Find the nearest non-shadow goblin
                if let nearestGoblin = scene.goblinManager.goblinContainers
                    .filter({ $0 !== self })
                    .min(by: { $0.sprite.position.distance(to: self.sprite.position) <
                              $1.sprite.position.distance(to: self.sprite.position) }) {
                    
                    let attackRange: CGFloat = 50
                    
                    if self.sprite.position.distance(to: nearestGoblin.sprite.position) <= attackRange {
                        // Attack the goblin
                        nearestGoblin.applyDamage(self.damage)
                        
                        // Visual feedback for attack
                        let slash = SKSpriteNode(color: .red, size: CGSize(width: 20, height: 20))
                        slash.position = nearestGoblin.sprite.position
                        scene.addChild(slash)
                        slash.run(SKAction.sequence([
                            SKAction.fadeOut(withDuration: 0.2),
                            SKAction.removeFromParent()
                        ]))
                    } else {
                        // Move towards the nearest goblin
                        let direction = (nearestGoblin.sprite.position - self.sprite.position).normalized()
                        let speed: CGFloat = 150
                        self.sprite.position = self.sprite.position + CGPoint(x: direction.x * speed * 1/60,
                                                                            y: direction.y * speed * 1/60)
                        
                        // Update sprite facing direction
                        self.sprite.xScale = direction.x < 0 ? -abs(self.sprite.xScale) : abs(self.sprite.xScale)
                    }
                }
            }
            
            // Run the attack sequence continuously
            let sequence = SKAction.sequence([
                attackAction,
                SKAction.wait(forDuration: 1/60) // 60 FPS update rate
            ])
            sprite.run(SKAction.repeatForever(sequence), withKey: "shadowAttack")
        }
        
        func startAttacking() {
            guard let gameScene = sprite.scene as? GameScene else { return }
            isAttacking = true
            
            if isRanged {
                startRangedAttack(scene: gameScene)
            } else {
                startMeleeAttack(scene: gameScene)
            }
        }
        
        private func startRangedAttack(scene: GameScene) {
            let targetPosition = CGPoint(x: scene.size.width / 2, y: 100) // Use same position as castlePosition
            let distanceToTarget = sprite.position.distance(to: targetPosition)
            
            if distanceToTarget <= 401 { // Matches the stopDistance in moveGoblin
                print("Ranged goblin is within range and starts shooting.")
                let spawnArrow = SKAction.run { [weak self] in
                    guard let self = self else { return }
                    if self.sprite.position.distance(to: targetPosition) <= 401 {  // Double-check distance before each shot
                        scene.goblinManager.spawnArrow(from: self.sprite.position, 
                                                     to: targetPosition)
                    }
                }
                let waitAction = SKAction.wait(forDuration: 1.5)
                let attackSequence = SKAction.sequence([spawnArrow, waitAction])
                let repeatAttack = SKAction.repeatForever(attackSequence)
                sprite.run(repeatAttack, withKey: "rangedAttack")
            } else {
                print("Ranged goblin is not within range. Current distance: \(distanceToTarget)")
                
                // Add a check action that continuously monitors distance
                let checkRangeAction = SKAction.run { [weak self] in
                    guard let self = self else { return }
                    let currentDistance = self.sprite.position.distance(to: targetPosition)
                    if currentDistance <= 400 && !self.sprite.hasActions() {
                        self.startRangedAttack(scene: scene)
                    }
                }
                let waitAction = SKAction.wait(forDuration: 0.5)  // Check every half second
                let checkSequence = SKAction.sequence([checkRangeAction, waitAction])
                sprite.run(SKAction.repeatForever(checkSequence), withKey: "checkRange")
            }
        }
        
        private func startMeleeAttack(scene: GameScene) {
            // Create melee attack timer
            attackTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                scene.castleTakeDamage(damage: self.damage)
                
                // Visual feedback for melee attack
                let attackAnimation = SKAction.sequence([
                    SKAction.scale(to: 1.2, duration: 0.1),
                    SKAction.scale(to: 1.0, duration: 0.1)
                ])
                self.sprite.run(attackAnimation)
            }
        }
        
        func stopAttacking() {
            isAttacking = false
            sprite.removeAction(forKey: "rangedAttack")
            attackTimer?.invalidate()
            attackTimer = nil
        }
        
        // Add methods for status effects
        func hasStatusEffect(_ effectName: String) -> Bool {
            return statusEffects.contains(effectName)
        }
        
        func addStatusEffect(_ effectName: String, duration: TimeInterval) {
            statusEffects.insert(effectName)
            statusDurations[effectName] = duration
            
            // Schedule removal of status effect
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
                self?.removeStatusEffect(effectName)
            }
        }
        
        func removeStatusEffect(_ effectName: String) {
            statusEffects.remove(effectName)
            statusDurations.removeValue(forKey: effectName)
        }
        
        func getRemainingDuration(for effectName: String) -> TimeInterval? {
            guard let endTime = statusDurations[effectName] else { return nil }
            return max(0, endTime - Date().timeIntervalSinceReferenceDate)
        }
        
        // Add helper methods for targeting
        func isAtFullHealth() -> Bool {
            return health >= maxHealth
        }
        
        func getHealthPercentage() -> CGFloat {
            return health / maxHealth
        }
        
        func isInRange(of point: CGPoint, radius: CGFloat) -> Bool {
            return sprite.position.distance(to: point) <= radius
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
    
    // Add property to track shadow goblins separately
    private var shadowGoblins: [GoblinContainer] = []
    
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
        guard let gameScene = scene as? GameScene else { return }
        
        // Create a goblin of that type
        let nextGoblinType = specificType ?? getRandomGoblinType()
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
        
        // Setup physics body
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
            maxHealth: health,
            goldValue: goblinGoldValue(for: nextGoblinType),
            isRanged: nextGoblinType == .ranged
        )
        
        goblinContainers.append(container)
        gameScene.addChild(goblinSprite)
        
        let targetPosition = CGPoint(x: gameScene.size.width / 2, y: 100)
        moveGoblin(container: container, to: targetPosition, in: gameScene)
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
    
    private func moveGoblin(container: GoblinContainer, to targetPosition: CGPoint, in gameScene: GameScene) {
        let distanceToTarget = container.sprite.position.distance(to: targetPosition)
        let stopDistance: CGFloat = container.isRanged ? 400 : 0

        if distanceToTarget > stopDistance {
            // Calculate the actual stop position for ranged goblins
            let finalPosition: CGPoint
            if container.isRanged {
                let direction = (targetPosition - container.sprite.position).normalized()
                let stopPoint = targetPosition - (direction * stopDistance)
                finalPosition = stopPoint
            } else {
                finalPosition = targetPosition
            }

            let moveDuration = TimeInterval((distanceToTarget - stopDistance) / goblinSpeed(for: container.type))
            let moveAction = SKAction.move(to: finalPosition, duration: moveDuration)
            
            let startAttackAction = SKAction.run { [weak container] in
                container?.startAttacking()
            }
            
            let sequence = SKAction.sequence([moveAction, startAttackAction])
            container.sprite.run(sequence)
        } else {
            container.startAttacking()
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
            return 125
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
        case .normal:
            return "normalGoblin"
        case .large:
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
                // Apply the spell effect
                spell.applySpecialEffect(on: container)
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
        guard let gameScene = scene as? GameScene else { return }

        // Create the arrow sprite
        let arrowSprite = SKSpriteNode(imageNamed: "Arrow")
        arrowSprite.size = CGSize(width: 25, height: 25)
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
            gameScene.castleTakeDamage(damage: arrowContainer.damage)
            self?.removeArrow(container: arrowContainer)
        }
        let sequence = SKAction.sequence([moveAction, damageAction])

        arrowSprite.run(sequence)
        gameScene.addChild(arrowSprite)
    }

    func removeArrow(container: ArrowContainer) {
        arrowContainers.removeAll { $0 === container }
        container.sprite.removeFromParent()
    }

    func arrowSpeed() -> CGFloat {
        return 300.0 // Adjust the speed as needed
    }

    func goblinGoldValue(for type: GoblinType) -> Int {
        switch type {
        case .normal:
            return 5
        case .large:
            return 15
        case .small:
            return 3
        case .ranged:
            return 10
        }
    }

    func addShadowGoblin(_ shadowGoblin: GoblinContainer) {
        shadowGoblins.append(shadowGoblin)
    }
    
    func removeShadowGoblin(_ shadowGoblin: GoblinContainer) {
        shadowGoblins.removeAll { $0 === shadowGoblin }
        shadowGoblin.sprite.removeFromParent()
    }
    
    // Add targeting helper methods
    func getGoblins() -> [GoblinContainer] {
        return goblinContainers
    }
    
    func getGoblinsInRange(of point: CGPoint, radius: CGFloat) -> [GoblinContainer] {
        return goblinContainers.filter { $0.isInRange(of: point, radius: radius) }
    }
    
    func getGoblinsWithFullHealth() -> [GoblinContainer] {
        return goblinContainers.filter { $0.isAtFullHealth() }
    }
    
    func getGoblinsWithHealthPercentage(above percentage: CGFloat) -> [GoblinContainer] {
        return goblinContainers.filter { $0.getHealthPercentage() >= percentage }
    }
    
    func getGoblinsWithHealthPercentage(below percentage: CGFloat) -> [GoblinContainer] {
        return goblinContainers.filter { $0.getHealthPercentage() <= percentage }
    }
    
    func getNearestGoblin(to point: CGPoint) -> GoblinContainer? {
        return goblinContainers.min { goblin1, goblin2 in
            point.distance(to: goblin1.sprite.position) < point.distance(to: goblin2.sprite.position)
        }
    }
    
    func getGoblinsWithStatusEffect(_ effectName: String) -> [GoblinContainer] {
        return goblinContainers.filter { $0.hasStatusEffect(effectName) }
    }
    
    func getGoblinsWithoutStatusEffect(_ effectName: String) -> [GoblinContainer] {
        return goblinContainers.filter { !$0.hasStatusEffect(effectName) }
    }
}

// Add this extension to your Goblin.swift file
extension Goblin.GoblinContainer: Hashable {
    public static func == (lhs: Goblin.GoblinContainer, rhs: Goblin.GoblinContainer) -> Bool {
        // Use object identity since each container should be unique
        ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    
    public func hash(into hasher: inout Hasher) {
        // Hash using object identity
        hasher.combine(ObjectIdentifier(self))
    }
}
