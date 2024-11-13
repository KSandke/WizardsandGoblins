// Managers/GoblinManager.swift
import SpriteKit

class GoblinManager {
    weak var scene: SKScene?
    var goblins: [Goblin] = []
    var currentWave: Int = 1
    var remainingGoblins: Int = 10
    var totalGoblinsSpawned: Int = 0
    var maxGoblinsPerWave: Int = 10
    var isSpawningEnabled = true
    var goblinSpawnInterval: TimeInterval = 2.0

    var waveLabel: SKLabelNode!
    var goblinCountLabel: SKLabelNode!
    
    var castlePosition: CGPoint
    
    // Callbacks
    var castleTakeDamage: ((CGFloat) -> Void)?
    var goblinKilled: ((CGPoint) -> Void)?
    
    init(scene: SKScene, castlePosition: CGPoint) {
        self.scene = scene
        self.castlePosition = castlePosition
        waveSetup()
        goblinCounterSetup()
        startSpawning()
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
    
    func startSpawning() {
        let spawnGoblinAction = SKAction.run { [weak self] in
            self?.spawnGoblin()
        }
        let waitForNextSpawn = SKAction.wait(forDuration: goblinSpawnInterval)
        let spawnSequence = SKAction.sequence([waitForNextSpawn, spawnGoblinAction])
        scene?.run(SKAction.repeatForever(spawnSequence))
    }
    
    func spawnGoblin() {
        guard let scene = scene else { return }
        // Only spawn if spawning is enabled and we haven't reached the wave's goblin limit
        if !isSpawningEnabled || totalGoblinsSpawned >= maxGoblinsPerWave {
            return
        }
        
        totalGoblinsSpawned += 1
        
        // Randomly decide which type of goblin to spawn based on probability
        // For example:
        // 70% chance of normal goblin
        // 15% chance of small goblin
        // 15% chance of large goblin
        let randomValue = Int.random(in: 1...100)
        let goblinType: Goblin.GoblinType
        if randomValue <= 70 {
            goblinType = .normal
        } else if randomValue <= 85 {
            goblinType = .small
        } else {
            goblinType = .large
        }
        
        let randomX = CGFloat.random(in: 0...scene.size.width)
        let spawnPosition = CGPoint(x: randomX, y: scene.size.height + 50)
        
        let goblin = Goblin(type: goblinType, position: spawnPosition)
        goblins.append(goblin)
        scene.addChild(goblin.sprite)
        
        goblin.move(to: castlePosition) { [weak self] in
            guard let self = self else { return }
            self.castleTakeDamage?(goblin.damage)
            self.goblinDied(goblin)
        }
    }
    
    func goblinDied(_ goblin: Goblin) {
        // Remove from goblins array
        goblins.removeAll { $0 === goblin }
        let goblinPosition = goblin.sprite.position
        goblin.sprite.removeFromParent()
        
        // Callback to notify goblin was killed
        goblinKilled?(goblinPosition)
        
        // Update goblin counter
        if remainingGoblins > 0 {
            remainingGoblins -= 1
            updateGoblinCounter()
            
            // Check if wave is complete when counter reaches 0
            if remainingGoblins == 0 {
                startNextWave()
            }
        }
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
        }
        
        // Add the remove label and start wave actions to the sequence
        actions.append(removeLabel)
        actions.append(startWave)
        
        // Run the complete sequence
        scene?.run(SKAction.sequence(actions))
    }
    
    func applySpell(_ spell: Spell, at position: CGPoint) {
        // Apply spell effects to goblins
        for goblin in goblins {
            let distance = position.distance(to: goblin.sprite.position)
            if distance <= spell.aoeRadius {
                spell.applyToGoblin(goblin, in: scene!)
                
                if !goblin.isAlive {
                    goblinDied(goblin)
                }
            }
        }
    }
}