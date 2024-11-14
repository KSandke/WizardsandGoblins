//
//  WGGameScene.swift
//  WizardsandGoblins
//
//  Created by Kevin Sandke on 10/24/24.
//

import SpriteKit
import GameplayKit
import Foundation
import CoreGraphics

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // Player State and View
    var playerState: PlayerState!
    var playerView: PlayerView!
    
    // Background
    var background: SKSpriteNode!
    
    // Goblin Manager
    var goblinManager: Goblin!
    var goblinSpawnInterval: TimeInterval = 2.0  // Changed to variable
    
    // Game over properties
    var restartButton: SKLabelNode!
    var mainMenuButton: SKLabelNode!
    var currentWave: Int = 1
    var remainingGoblins: Int = 10
    var goblinCountLabel: SKLabelNode!
    
    var isSpawningEnabled = true
    var totalGoblinsSpawned = 0
    var maxGoblinsPerWave = 10
    
    // New variables for wave management
    var isInShop = false  // To track if the shop view is active
    var isGameOver = false

    enum SpawnPattern {
        case single
        case line(count: Int)
        case surrounded(centerCount: Int, surroundCount: Int)
        case stream(count: Int, interval: TimeInterval)
        
        var goblinCount: Int {
            switch self {
            case .single:
                return 1
            case .line(let count):
                return count
            case .surrounded(let centerCount, let surroundCount):
                return centerCount + surroundCount
            case .stream(let count, _):
                return count
            }
        }
    }

    // Add spawn pattern probability struct
    struct SpawnPatternConfig {
        let pattern: SpawnPattern
        let probability: Double
    }
    
    // Define the WaveConfig struct
    struct WaveConfig {
        var goblinTypeProbabilities: [Goblin.GoblinType: Double]
        var maxGoblins: Int
        var baseSpawnInterval: TimeInterval
        var spawnPatterns: [SpawnPatternConfig]
    }
    
    // Update the property declaration
    var waveConfigs: [Int: WaveConfig] = [:]  // Changed from array to dictionary

    // Add properties for mana potion drop chance and spell charge restore amount
    var manaPotionDropChance: Double = 0.1  // 10% chance by default
    var spellChargeRestoreAmount: Int = 2
    
    // Add properties for spell icons
    private var playerOneSpellIcon: SKSpriteNode!
    private var playerTwoSpellIcon: SKSpriteNode!
    
    override func didMove(to view: SKView) {
        // Initialize Player State and View
        playerState = PlayerState()
        playerView = PlayerView(scene: self, state: playerState)
        
        setupBackground()
        setupWaves()
        goblinCounterSetup()
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        // Initialize Goblin Manager with initial probabilities
        goblinManager = Goblin(scene: self)
        
        // Start the first wave
        startWave()
        
        // Setup spell icons
        setupSpellIcons()
    }
    
    func setupWaves() {
        waveConfigs = [ // Default wave configuration
            -1: WaveConfig( 
                goblinTypeProbabilities: [.normal: 60.0, .small: 20.0, .large: 20.0],
                maxGoblins: 7,  // Will be modified based on wave number
                baseSpawnInterval: 2.0,  // Will be modified based on wave number
                spawnPatterns: [
                    SpawnPatternConfig(pattern: .single, probability: 70.0),
                    SpawnPatternConfig(pattern: .line(count: 3), probability: 30.0)
                ]
            ),
            1: WaveConfig( //use this config for testing
                goblinTypeProbabilities: [.normal: 50.0, .ranged: 50.0],
                maxGoblins: 10,
                baseSpawnInterval: 2.0,
                spawnPatterns: [
                    SpawnPatternConfig(pattern: .single, probability: 70.0),
                    SpawnPatternConfig(pattern: .line(count: 3), probability: 30.0)
                ]
            ),
            2: WaveConfig(
                goblinTypeProbabilities: [.normal: 100.0],
                maxGoblins: 10,
                baseSpawnInterval: 2.0,
                spawnPatterns: [
                    SpawnPatternConfig(pattern: .single, probability: 70.0),
                    SpawnPatternConfig(pattern: .line(count: 3), probability: 30.0)
                ]
            ),
            3: WaveConfig(
                goblinTypeProbabilities: [.normal: 70.0, .small: 15.0, .large: 15.0],
                maxGoblins: 15,
                baseSpawnInterval: 1.8,
                spawnPatterns: [
                    SpawnPatternConfig(pattern: .single, probability: 50.0),
                    SpawnPatternConfig(pattern: .line(count: 3), probability: 30.0),
                    SpawnPatternConfig(pattern: .surrounded(centerCount: 1, surroundCount: 4), probability: 20.0)
                ]
            ),
            4: WaveConfig(
                goblinTypeProbabilities: [.small: 100.0],
                maxGoblins: 20,
                baseSpawnInterval: 1.5,
                spawnPatterns: [
                    SpawnPatternConfig(pattern: .single, probability: 70.0),
                    SpawnPatternConfig(pattern: .line(count: 3), probability: 30.0)
                ]
            ),
            5: WaveConfig(
                goblinTypeProbabilities: [.normal: 40.0, .small: 25.0, .large: 25.0, .ranged: 10.0],
                maxGoblins: 25,
                baseSpawnInterval: 1.5,
                spawnPatterns: [
                    SpawnPatternConfig(pattern: .single, probability: 60.0),
                    SpawnPatternConfig(pattern: .line(count: 3), probability: 30.0),
                    SpawnPatternConfig(pattern: .surrounded(centerCount: 1, surroundCount: 4), probability: 10.0)
                ]
            ),
            6: WaveConfig(
                goblinTypeProbabilities: [.large: 100.0],
                maxGoblins: 30,
                baseSpawnInterval: 1.2,
                spawnPatterns: [
                    SpawnPatternConfig(pattern: .single, probability: 80.0),
                    SpawnPatternConfig(pattern: .line(count: 3), probability: 20.0)
                ]
            ),
            7: WaveConfig(
                goblinTypeProbabilities: [.ranged: 100.0],
                maxGoblins: 30,
                baseSpawnInterval: 1.2,
                spawnPatterns: [SpawnPatternConfig(pattern: .single, probability: 100.0)]
            )
        ]
    }
    
    func startWave() {
        let waveConfig = getWaveConfig(forWave: currentWave)

        // Update goblin manager probabilities
        goblinManager.goblinTypeProbabilities = waveConfig.goblinTypeProbabilities

        // Reset wave variables
        self.maxGoblinsPerWave = waveConfig.maxGoblins
        self.remainingGoblins = self.maxGoblinsPerWave
        self.totalGoblinsSpawned = 0
        self.goblinSpawnInterval = waveConfig.baseSpawnInterval
        self.updateGoblinCounter()
        
        // Reset spell charges instead of mana
        self.playerState.playerOneSpellCharges = self.playerState.maxSpellCharges
        self.playerState.playerTwoSpellCharges = self.playerState.maxSpellCharges
        
        // Update wave label in PlayerView
        playerView.updateWaveLabel(wave: currentWave)
        
        // Start wave actions
        isSpawningEnabled = true
        
        // Start spell charge regeneration
        let regenerateCharges = SKAction.run { [weak self] in
            self?.playerState.regenerateSpellCharges()
        }
        let wait = SKAction.wait(forDuration: 1.0)
        let regenSequence = SKAction.sequence([wait, regenerateCharges])
        let repeatRegen = SKAction.repeatForever(regenSequence)
        self.run(repeatRegen, withKey: "regenerateCharges")
        
        // Start goblin spawning
        startSpawnPatterns(with: waveConfig)
    }
    
    func getWaveConfig(forWave wave: Int) -> WaveConfig {
        // Check if we have a custom config for this wave
        if let customConfig = waveConfigs[wave] {
            print("Using custom config for wave \(wave)")
            return customConfig
        }
        if let defaultConfig = waveConfigs[-1] {
            // Modify default config based on wave number
            print("Using default config for wave \(wave)")
            var modifiedConfig = defaultConfig
            modifiedConfig.maxGoblins = (wave - 1) * 5
            modifiedConfig.baseSpawnInterval = max(2.0 - 0.1 * Double(wave - 1), 0.5)
            return modifiedConfig
        }
// If no config found, create a basic default config
        return WaveConfig(
            goblinTypeProbabilities: [.normal: 100.0],
            maxGoblins: 10,
            baseSpawnInterval: 2.0,
            spawnPatterns: [
                SpawnPatternConfig(pattern: .single, probability: 100.0)
            ]
        )
    }
    
    func endWave() {
        // Stop the actions
        self.removeAction(forKey: "regenerateCharges")
        self.removeAction(forKey: "spawnPattern")
        
        isSpawningEnabled = false
    }
    
    func setupBackground() {
        background = SKSpriteNode(imageNamed: "Background")
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.size = self.size
        background.zPosition = -1
        addChild(background)
    }
    
    
    func createCoinEffect(at position: CGPoint) {
        let coinSprite = SKSpriteNode(imageNamed: "coin") // Make sure to add a coin image to assets
        coinSprite.size = CGSize(width: 20, height: 20)
        coinSprite.position = position
        addChild(coinSprite)
        
        let moveUp = SKAction.moveBy(x: 0, y: 50, duration: 0.5)
        let fade = SKAction.fadeOut(withDuration: 0.3)
        let remove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([moveUp, fade, remove])
        
        coinSprite.run(sequence)
    }
    
    func spawnGoblin(at position: CGPoint) {
        // Check if spawning is enabled and if the game is not over
        if !isSpawningEnabled || totalGoblinsSpawned >= maxGoblinsPerWave || isGameOver {
            return
        }

        // Increment the total goblins spawned
        totalGoblinsSpawned += 1

        // Use goblinManager to spawn a goblin at the position
        goblinManager.spawnGoblin(at: position)
    }
    
    func castleTakeDamage(damage: CGFloat) {
        if playerState.takeDamage(damage) {
            gameOver()
        }
    }
    
    func gameOver() {
        // Stop all wave-related processes
        endWave()
        removeAllActions()
        isGameOver = true
        
        // Remove any remaining goblins
        goblinManager.removeAllGoblins(in: self)
        
        let gameOverLabel = SKLabelNode(text: "Game Over!")
        gameOverLabel.fontSize = 50
        gameOverLabel.fontColor = .red
        gameOverLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.7)
        addChild(gameOverLabel)
        
        // Remove all nodes and reset the scene
        removeAllChildren()
        
        // Add final score label
        let finalScoreLabel = SKLabelNode(text: "Final Score: \(playerState.score)")
        finalScoreLabel.fontSize = 40
        finalScoreLabel.fontColor = .white
        finalScoreLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(finalScoreLabel)
        
        // Add final coins label
        let finalCoinsLabel = SKLabelNode(text: "Total Coins: \(playerState.coins)")
        finalCoinsLabel.fontSize = 40
        finalCoinsLabel.fontColor = .yellow
        finalCoinsLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.6)
        addChild(finalCoinsLabel)
        
        // Add Restart Button
        restartButton = SKLabelNode(text: "Restart")
        restartButton.fontSize = 30
        restartButton.fontColor = .white
        restartButton.position = CGPoint(x: size.width / 2, y: size.height / 2 - 50)
        restartButton.name = "restartButton"
        addChild(restartButton)
        
        // Add Main Menu Button
        mainMenuButton = SKLabelNode(text: "Main Menu")
        mainMenuButton.fontSize = 30
        mainMenuButton.fontColor = .white
        mainMenuButton.position = CGPoint(x: size.width / 2, y: size.height / 2 - 100)
        mainMenuButton.name = "mainMenuButton"
        addChild(mainMenuButton)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        
        if isInShop {
            // Forward touch to shop view if it exists
            if let shopView = self.children.first(where: { $0 is ShopView }) as? ShopView {
                shopView.handleTap(at: touchLocation)
            }
            return
        }
        
        // Handle button taps
        let touchedNode = nodes(at: touchLocation).first
        if let name = touchedNode?.name {
            switch name {
            case "restartButton":
                restartGame()
                return
            case "mainMenuButton":
                goToMainMenu()
                return
            default:
                break
            }
        }
        
        // Get wizard positions
        let p1Position = playerView.playerOnePosition
        let p2Position = playerView.playerTwoPosition
        
        // Check if either wizard was tapped
        if touchLocation.distance(to: p1Position) < 30 { // Adjust radius as needed
            playerState.swapSpells(isPlayerOne: true)
            updateSpellIcons()
            return
        } else if touchLocation.distance(to: p2Position) < 30 { // Adjust radius as needed
            playerState.swapSpells(isPlayerOne: false)
            updateSpellIcons()
            return
        }
        
        // Calculate distances for spell casting
        let distance1 = touchLocation.distance(to: p1Position)
        let distance2 = touchLocation.distance(to: p2Position)
        
        // Determine primary and backup casters based on distance
        let isPlayerOnePrimary = distance1 < distance2

        // Try to cast with primary caster, if fails try backup caster
        if !castSpell(isPlayerOne: isPlayerOnePrimary, to: touchLocation) {
            _ = castSpell(isPlayerOne: !isPlayerOnePrimary, to: touchLocation)
        }
    }
    
    func castSpell(isPlayerOne: Bool, to location: CGPoint) -> Bool {
        // Check if the wave is active and game is not over
        guard isSpawningEnabled && !isGameOver else { return false }
        // Get caster's position
        let casterPosition = isPlayerOne ? playerView.playerOnePosition : playerView.playerTwoPosition
        
        // Get the player's spell
        let spell = playerState.getSpell(isPlayerOne: isPlayerOne)
        
        // Cast the spell
        let success = spell.cast(from: casterPosition, to: location, by: playerState, isPlayerOne: isPlayerOne, in: self)
        return success
    }
    
    func applySpell(_ spell: Spell, at position: CGPoint) {
        // Apply spell effects to goblins only
        goblinManager.applySpell(spell, at: position, in: self)
    }

    func createSpellChargeRestoreEffect(at position: CGPoint) {
    let effect = SKEmitterNode()
    effect.particleTexture = SKTexture(imageNamed: "spark") // Add spark image to assets
    effect.position = position
    effect.particleBirthRate = 100
    effect.numParticlesToEmit = 50
    effect.particleLifetime = 0.5
    effect.particleColor = .blue
    effect.particleColorBlendFactor = 1.0
    effect.particleScale = 0.5
    effect.particleScaleSpeed = -1.0
    effect.emissionAngle = 0.0
    effect.emissionAngleRange = .pi * 2
    effect.particleSpeed = 100
    effect.xAcceleration = 0
    effect.yAcceleration = 0
    addChild(effect)
    
    let wait = SKAction.wait(forDuration: 0.5)
    let remove = SKAction.removeFromParent()
    effect.run(SKAction.sequence([wait, remove]))
    }
    
    func handlePotionCollection(at position: CGPoint) {
        // Determine which wizard has fewer charges
        let playerOneCharges = playerState.playerOneSpellCharges
        let playerTwoCharges = playerState.playerTwoSpellCharges
        
        // Give charges to the wizard with fewer charges
        // If equal, give to player one
        if playerOneCharges <= playerTwoCharges {
            playerState.playerOneSpellCharges = min(
                playerState.maxSpellCharges,
                playerState.playerOneSpellCharges + spellChargeRestoreAmount
            )
        } else {
            playerState.playerTwoSpellCharges = min(
                playerState.maxSpellCharges,
                playerState.playerTwoSpellCharges + spellChargeRestoreAmount
            )
        }
        
        // Create collection effect
        createSpellChargeRestoreEffect(at: position)
    }
    
    func goblinDied(container: Goblin.GoblinContainer, goblinKilled: Bool) {
        // Add coins when goblin is killed (50% chance of 5 coins)
        if goblinKilled {
            if Bool.random() {
                playerState.addCoins(5)
                
                // Create coin particle effect
                createCoinEffect(at: container.sprite.position)
            }
            // Add points when goblin is eliminated
            playerState.addScore(points: 10)

            // Check for mana potion drop and auto-collect
            if Double.random(in: 0...1) < manaPotionDropChance {
                handlePotionCollection(at: container.sprite.position)
            }

        }
        
        // Only decrease if counter is greater than 0
        if remainingGoblins > 0 {
            remainingGoblins -= 1
            updateGoblinCounter()
            
            // Check if wave is complete when counter reaches 0
            if remainingGoblins == 0 {
                waveCompleted()
            }
        }
    }
    
    func waveCompleted() {
        // Add guard to prevent shop from showing if game is over
        guard !isGameOver else { return }
        
        endWave()
        showShopView()
    }
    
    func showShopView() {
        let shopView = ShopView(size: self.size, playerState: playerState) { [weak self] in
            self?.closeShopView()
        }
        shopView.zPosition = 200
        addChild(shopView)
        isInShop = true
    }
    
    func closeShopView() {
        if let shopView = self.children.first(where: { $0 is ShopView }) {
            shopView.removeFromParent()
        }
        isInShop = false
        startNextWave()
    }
    
    func restartGame() {
        // Reset the game over flag
        isGameOver = false
        
        // Remove all nodes and reset the scene
        removeAllChildren()
        removeAllActions()
        
        // Reset properties
        playerState.reset()
        
        // Reset wave and goblin counters
        currentWave = 1
        remainingGoblins = 10
        
        // Reset spawning properties
        isSpawningEnabled = false
        totalGoblinsSpawned = 0
        isInShop = false
        
        // Setup all components
        setupBackground()
        
        // Re-initialize PlayerView with the reset state
        playerView = PlayerView(scene: self, state: playerState)
        
        setupWaves()
        goblinCounterSetup()
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        // Initialize Goblin Manager
        goblinManager = Goblin(scene: self)
        
        // Update wave label in PlayerView
        playerView.updateWaveLabel(wave: currentWave)
        
        // Start the first wave
        startWave()
    }
    
    func goToMainMenu() {
        let mainMenuScene = WGMainMenu(size: self.size)
        mainMenuScene.scaleMode = SKSceneScaleMode.aspectFill
        view?.presentScene(mainMenuScene, transition: SKTransition.fade(withDuration: 0.5))
    }
    
    func goblinCounterSetup() {
        goblinCountLabel = SKLabelNode(text: "Goblins: \(remainingGoblins)")
        goblinCountLabel.fontSize = 24
        goblinCountLabel.fontColor = .black
        goblinCountLabel.position = CGPoint(x: size.width - 100, y: size.height - 60)
        addChild(goblinCountLabel)
    }
    
    func updateGoblinCounter() {
        goblinCountLabel.text = "Goblins: \(remainingGoblins)"
    }
    
    func startNextWave() {
        // Create countdown label
        let countdownLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        countdownLabel.fontSize = 72
        countdownLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        countdownLabel.zPosition = 100 // Ensure it appears above other nodes
        addChild(countdownLabel)
        
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
        let startWaveAction = SKAction.run { [weak self] in
            guard let self = self else { return }
            self.currentWave += 1
            //self.playerView.updateWaveLabel(wave: self.currentWave) // Update wave label
            self.startWave()
        }
        
        // Add the remove label and start wave actions to the sequence
        actions.append(removeLabel)
        actions.append(startWaveAction)
        
        // Run the complete sequence
        run(SKAction.sequence(actions))
    }
    
    func selectSpawnPattern(from config: WaveConfig) -> SpawnPattern? {
        // Check remaining goblin capacity
        let remainingGoblins = maxGoblinsPerWave - totalGoblinsSpawned
        
        // Filter patterns that would exceed remaining goblin count
        let validPatterns = config.spawnPatterns.filter { 
            $0.pattern.goblinCount <= remainingGoblins 
        }
        
        guard !validPatterns.isEmpty else { return nil }
        
        // Calculate total probability of valid patterns
        let totalProbability = validPatterns.reduce(0.0) { $0 + $1.probability }
        
        // Generate random value
        var random = Double.random(in: 0..<totalProbability)
        
        // Select pattern based on probability
        for patternConfig in validPatterns {
            random -= patternConfig.probability
            if random <= 0 {
                return patternConfig.pattern
            }
        }
        
        return validPatterns.first?.pattern
    }
    
    func startSpawnPatterns(with config: WaveConfig) {
        let spawnAction = SKAction.run { [weak self] in
            guard let self = self else { return }
            
            if self.totalGoblinsSpawned >= self.maxGoblinsPerWave {
                return
            }
            
            if let pattern = self.selectSpawnPattern(from: config) {
                self.executeSpawnPattern(pattern)
            }
        }
        
        let wait = SKAction.wait(forDuration: config.baseSpawnInterval)
        let sequence = SKAction.sequence([wait, spawnAction])
        run(SKAction.repeatForever(sequence), withKey: "spawnPattern")
    }
    
    func executeSpawnPattern(_ pattern: SpawnPattern) {
        // Verify we have enough remaining capacity
        let remainingCapacity = maxGoblinsPerWave - totalGoblinsSpawned
        guard pattern.goblinCount <= remainingCapacity else { return }
        
        switch pattern {
        case .single:
            spawnSingleGoblin()
            
        case .line(let count):
            spawnLineOfGoblins(count: count)
            
        case .surrounded(let centerCount, let surroundCount):
            spawnSurroundedGoblins(centerCount: centerCount, surroundCount: surroundCount)
            
        case .stream(let count, let interval):
            spawnStreamOfGoblins(count: count, interval: interval)
        }
    }
    
    func spawnSingleGoblin() {
        let randomX = CGFloat.random(in: 0...size.width)
        let spawnPosition = CGPoint(x: randomX, y: size.height + 50)
        spawnGoblin(at: spawnPosition)
    }
    
    func spawnLineOfGoblins(count: Int) {
        let spacing: CGFloat = 50
        let totalWidth = spacing * CGFloat(count - 1)
        let startX = (size.width - totalWidth) / 2
        
        for i in 0..<count {
            let xPos = startX + spacing * CGFloat(i)
            let spawnPosition = CGPoint(x: xPos, y: size.height + 50)
            spawnGoblin(at: spawnPosition)
        }
    }
    
    func spawnSurroundedGoblins(centerCount: Int, surroundCount: Int) {
        let centerX = size.width / 2
        let centerY = size.height + 50
        
        // Spawn center goblins
        for _ in 0..<centerCount {
            spawnGoblin(at: CGPoint(x: centerX, y: centerY))
        }
        
        // Spawn surrounding goblins in a circle
        let radius: CGFloat = 50
        for i in 0..<surroundCount {
            let angle = (CGFloat.pi * 2 * CGFloat(i)) / CGFloat(surroundCount)
            let x = centerX + radius * cos(angle)
            let y = centerY + radius * sin(angle)
            spawnGoblin(at: CGPoint(x: x, y: y))
        }
    }
    
    func spawnStreamOfGoblins(count: Int, interval: TimeInterval) {
        let randomX = CGFloat.random(in: 0...size.width)
        
        for i in 0..<count {
            let spawnAction = SKAction.run { [weak self] in
                let spawnPosition = CGPoint(x: randomX, y: self?.size.height ?? 0 + 50)
                self?.spawnGoblin(at: spawnPosition)
            }
            let wait = SKAction.wait(forDuration: interval * Double(i))
            run(SKAction.sequence([wait, spawnAction]))
        }
    }
    
    func setupSpellIcons() {
        // Create spell icons
        playerOneSpellIcon = SKSpriteNode(imageNamed: playerState.getCurrentSpellName())
        playerTwoSpellIcon = SKSpriteNode(imageNamed: playerState.getCurrentSpellName())
        
        // Set size for icons
        let iconSize = CGSize(width: 30, height: 30) // Adjust size as needed
        playerOneSpellIcon.size = iconSize
        playerTwoSpellIcon.size = iconSize
        
        // Position icons next to wizards
        playerOneSpellIcon.position = CGPoint(
            x: playerView.playerOnePosition.x + 40, // Adjust offset as needed
            y: playerView.playerOnePosition.y
        )
        playerTwoSpellIcon.position = CGPoint(
            x: playerView.playerTwoPosition.x + 40, // Adjust offset as needed
            y: playerView.playerTwoPosition.y
        )
        
        // Add to scene
        addChild(playerOneSpellIcon)
        addChild(playerTwoSpellIcon)
    }
    
    // Update the spell icons when spells are swapped
    func updateSpellIcons() {
        let spellTexture = SKTexture(imageNamed: playerState.getCurrentSpellName())
        playerOneSpellIcon.texture = spellTexture
        playerTwoSpellIcon.texture = spellTexture
    }
}

