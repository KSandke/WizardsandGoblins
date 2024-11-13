// Model/Goblin.swift

import SpriteKit

class Goblin {
    // Goblin types
    enum GoblinType {
        case normal
        case small
        case large
    }
    
    // Goblin properties
    var goblins: [SKSpriteNode] = []
    var goblinContainers: [GoblinContainer] = []
    var goblinSpawnInterval: TimeInterval = 2.0
    
    // Wave properties
    var currentWave: Int = 1
    var remainingGoblins: Int = 10
    var isSpawningEnabled = true
    var totalGoblinsSpawned = 0
    var maxGoblinsPerWave = 10
    
    // Labels
    var waveLabel: SKLabelNode!
    var goblinCountLabel: SKLabelNode!
    
    // Reference to the GameScene
    weak var scene: SKScene?
    
    // Reference to PlayerState and PlayerView
    var playerState: PlayerState!
    var playerView: PlayerView!
    
    // Goblin Healthbar
    struct GoblinContainer {
        let sprite: SKSpriteNode
        let healthBar: SKShapeNode
        let healthFill: SKShapeNode
        let type: GoblinType
    }
    
    init(scene: SKScene, playerState: PlayerState, playerView: PlayerView) {
        self.scene = scene
        self.playerState = playerState
        self.playerView = playerView
        
        waveSetup()
        goblinCounterSetup()
        startGoblinSpawning()
    }
    
    func waveSetup() {
        waveLabel = SKLabelNode(text: "Wave: \(currentWave)")
        waveLabel.fontSize = 24
        waveLabel.fontColor = .black
        waveLabel.position = CGPoint(x: 80, y: scene!.size.height - 60)
        scene?.addChild(waveLabel)
    }
    
    func goblinCounterSetup() {
        goblinCountLabel = SKLabelNode(text: "Goblins: \(remainingGoblins)")
        goblinCountLabel.fontSize = 24
        goblinCountLabel.fontColor = .black
        goblinCountLabel.position = CGPoint(x: scene!.size.width - 100, y: scene!.size.height - 60)
        scene?.addChild(goblinCountLabel)
    }
    
    func updateWaveLabel() {
        waveLabel.text = "Wave: \(currentWave)"
    }
    
    func updateGoblinCounter() {
        goblinCountLabel.text = "Goblins: \(remainingGoblins)"
    }
    
    func startGoblinSpawning() {
        let spawnGoblinAction = SKAction.run { [weak self] in
            guard let self = self else { return }
            if self.isSpawningEnabled && self.totalGoblinsSpawned < self.maxGoblinsPerWave {
                let randomX = CGFloat.random(in: 0...self.scene!.size.width)
                let spawnPosition = CGPoint(x: randomX, y: self.scene!.size.height + 50)
                self.spawnGoblin(at: spawnPosition)
            }
        }
        let waitForNextSpawn = SKAction.wait(forDuration: goblinSpawnInterval)
        let spawnSequence = SKAction.sequence([waitForNextSpawn, spawnGoblinAction])
        scene?.run(SKAction.repeatForever(spawnSequence))
    }
    
    func spawnGoblin(at position: CGPoint) {
        totalGoblinsSpawned += 1
        
        let goblinType = randomGoblinType()
        let (goblinSpeed, goblinDamage, goblinHealth) = goblinAttributes(for: goblinType)
        
        let goblin = SKSpriteNode(imageNamed: "Goblin1")
        goblin.size = CGSize(width: 50, height: 50)
        goblin.position = position
        goblin.name = "goblin"
        
        // Create health bar background
        let healthBarWidth: CGFloat = 40
        let healthBarHeight: CGFloat = 5
        let healthBar = SKShapeNode(rectOf: CGSize(width: healthBarWidth, height: healthBarHeight))
        healthBar.fillColor = .gray
        healthBar.strokeColor = .black
        healthBar.position = CGPoint(x: 0, y: goblin.size.height/2 + 5)
        
        // Create health bar fill
        let healthFill = SKShapeNode(rectOf: CGSize(width: healthBarWidth, height: healthBarHeight))
        healthFill.fillColor = .red
        healthFill.strokeColor = .clear
        healthFill.position = healthBar.position
        
        // Add health bars as children of goblin
        goblin.addChild(healthBar)
        goblin.addChild(healthFill)
        
        let physicsBody = SKPhysicsBody(rectangleOf: goblin.size)
        physicsBody.isDynamic = true
        physicsBody.affectedByGravity = false
        physicsBody.categoryBitMask = 1
        physicsBody.contactTestBitMask = 2
        goblin.physicsBody = physicsBody
        
        goblin.userData = NSMutableDictionary()
        goblin.userData?.setValue(goblinHealth, forKey: "health")
        goblin.userData?.setValue(goblinHealth, forKey: "maxHealth")
        goblin.userData?.setValue(goblinType, forKey: "type")
        goblin.userData?.setValue(goblinDamage, forKey: "damage")
        
        scene?.addChild(goblin)
        
        // Create container and store it
        let container = GoblinContainer(sprite: goblin, healthBar: healthBar, healthFill: healthFill, type: goblinType)
        goblinContainers.append(container)
        
        let moveAction = SKAction.move(to: playerView.castlePosition, duration: TimeInterval(position.distance(to: playerView.castlePosition) / goblinSpeed))
        let damageAction = SKAction.run { [weak self] in
            guard let self = self else { return }
            self.castleTakeDamage(damage: goblinDamage)
            
            // Remove from containers array
            self.goblinContainers.removeAll(where: { $0.sprite == goblin })
            goblin.removeFromParent()
            
            // Handle goblin death
            self.goblinDied(container: container)
        }
        
        let sequence = SKAction.sequence([moveAction, damageAction])
        goblin.run(sequence)
    }
    
    func goblinAttributes(for type: GoblinType) -> (speed: CGFloat, damage: CGFloat, health: CGFloat) {
        let baseSpeed: CGFloat = 100
        let baseDamage: CGFloat = 10
        let baseHealth: CGFloat = 50
        
        switch type {
        case .normal:
            return (baseSpeed, baseDamage, baseHealth)
        case .small:
            return (baseSpeed * 1.5, baseDamage * 0.5, baseHealth * 0.5)
        case .large:
            return (baseSpeed * 0.75, baseDamage * 2.0, baseHealth * 2.0)
        }
    }
    
    func randomGoblinType() -> GoblinType {
        // For example, 70% normal, 15% small, 15% large
        let randomValue = Int.random(in: 1...100)
        if randomValue <= 70 {
            return .normal
        } else if randomValue <= 85 {
            return .small
        } else {
            return .large
        }
    }
    
    func castleTakeDamage(damage: CGFloat) {
        if playerState.takeDamage(damage) {
            // Game over
            scene?.removeAllActions()
            if let gameScene = scene as? GameScene {
                gameScene.gameOver()
            }
        }
    }
    
    func goblinDied(container: GoblinContainer) {
        // Remove from containers array first
        goblinContainers.removeAll(where: { $0.sprite == container.sprite })
        container.sprite.removeFromParent()
        
        // Add coins when goblin is killed (50% chance of 5 coins)
        if Bool.random() {
            playerState.addCoins(5) // 50% chance of 5 coins
        }
        // Add points when goblin is eliminated
        playerState.addScore(points: 10)
        
        // Create coin particle effect
        createCoinEffect(at: container.sprite.position)
        
        // Only decrease if counter is greater than 0
        if remainingGoblins > 0 {
            remainingGoblins -= 1
            updateGoblinCounter()
            
            // Check if wave is complete when counter reaches 0
            if remainingGoblins == 0 {
                startNextWave()
            }
        }
    }
    
    func createCoinEffect(at position: CGPoint) {
        guard let scene = scene else { return }
        let coinSprite = SKSpriteNode(imageNamed: "coin") // Make sure to add a coin image to assets
        coinSprite.size = CGSize(width: 20, height: 20)
        coinSprite.position = position
        scene.addChild(coinSprite)
        
        let moveUp = SKAction.moveBy(x: 0, y: 50, duration: 0.5)
        let fade = SKAction.fadeOut(withDuration: 0.3)
        let remove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([moveUp, fade, remove])
        
        coinSprite.run(sequence)
    }
    
    func startNextWave() {
        isSpawningEnabled = false
        
        // Create countdown label
        let countdownLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        countdownLabel.fontSize = 72
        countdownLabel.position = CGPoint(x: scene!.frame.midX, y: scene!.frame.midY)
        countdownLabel.zPosition = 100 // Ensure it appears above other nodes
        scene?.addChild(countdownLabel)
        
        // Create countdown sequence
        var actions: [SKAction] = []
        
        // Add actions for each number (5 to 1)
        for i in (1...5).reversed() {
            let showNumber = SKAction.run { countdownLabel.text = "\(i)" }
            let wait = SKAction.wait(forDuration: 1.0)
            actions.append(contentsOf: [showNumber, wait])
        }
        
        // Add final actions
        let removeLabel = SKAction.run { countdownLabel.removeFromParent() }
        let startWave = SKAction.run { [weak self] in
            guard let self = self else { return }
            self.currentWave += 1
            self.remainingGoblins = 10 + (self.currentWave - 1) * 5
            self.maxGoblinsPerWave = self.remainingGoblins
            self.totalGoblinsSpawned = 0
            self.isSpawningEnabled = true
            self.updateWaveLabel()
            self.updateGoblinCounter()
            // Reset player mana
            self.playerState.playerOneMana = self.playerState.maxMana
            self.playerState.playerTwoMana = self.playerState.maxMana
        }
        
        // Add the remove label and start wave actions to the sequence
        actions.append(removeLabel)
        actions.append(startWave)
        
        // Run the complete sequence
        scene?.run(SKAction.sequence(actions))
    }
}