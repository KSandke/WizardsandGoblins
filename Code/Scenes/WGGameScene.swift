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
    
    // MARK: - Dependencies
    var playerState: PlayerState!
    var playerView: PlayerView!
    var goblinManager: Goblin!
    private var tutorialManager: TutorialManager!
    
    // MARK: - Game State
    private(set) var currentWave: Int = 1
    private(set) var isGameOver = false
    private(set) var isInShop = false
    private(set) var isSpawningEnabled = true
    private(set) var hasTutorialBeenShown = false
    
    // MARK: - Wave Management
    private var waveConfigs: [Int: WaveConfig] = [:]
    private var totalGoblinsSpawned = 0
    private var remainingGoblins = GameConfig.defaultMaxGoblinsPerWave
    private var maxGoblinsPerWave = GameConfig.defaultMaxGoblinsPerWave
    private var goblinSpawnInterval: TimeInterval = GameConfig.defaultGoblinSpawnInterval
    private var currentWaveDamageTaken: CGFloat = 0
    
    // MARK: - UI Elements
    private var background: SKSpriteNode!
    private var restartButton: SKLabelNode!
    private var mainMenuButton: SKLabelNode!
    
    // MARK: - Combat Properties
    private var manaPotionDropChance: Double = GameConfig.manaPotionDropChance
    private var spellChargeRestoreAmount: Int = GameConfig.spellChargeRestoreAmount
    
    // MARK: - Input Handling
    private var touchStartLocation: CGPoint?
    private var touchStartTime: TimeInterval?
    private let swipeThreshold: CGFloat = GameConfig.swipeThreshold
    private let swipeTimeThreshold: TimeInterval = GameConfig.swipeTimeThreshold
    
    var castlePosition: CGPoint {
        return CGPoint(x: size.width / 2, y: GameConfig.defaultCastlePosition.y)
    }
    
    override func didMove(to view: SKView) {
        // Initialize Player State and View
        playerState = PlayerState()
        playerView = PlayerView(scene: self, state: playerState)
        
        setupBackground()
        setupWaves()
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        // Initialize Goblin Manager with initial probabilities
        goblinManager = Goblin(scene: self)
        
        // Initialize tutorial manager
        tutorialManager = TutorialManager(scene: self)
        if !hasTutorialBeenShown {
            tutorialManager.startTutorial { [weak self] in
                // Start the game after tutorial completes
                self?.startGame()
            }
            hasTutorialBeenShown = true
        } else {
            // Only start the game if tutorial has been shown
            startGame()
        }
    }
    
    // Add new method to start the game
    private func startGame() {
        startWave()
    }
    
    func setupWaves() {
        waveConfigs = WaveConfig.createWaveConfigs()
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
        
        // Reset spell charges
        self.playerState.spellCharges = self.playerState.maxSpellCharges
        
        // Update wave label in PlayerView
        playerView.updateWaveLabel(wave: currentWave)
        
        // Start wave actions
        isSpawningEnabled = true
        
        // Start spell charge regeneration
        let regenerateCharges = SKAction.run { [weak self] in
            self?.playerState.regenerateSpellCharges()
        }
        let regenInterval = 1.0 / TimeInterval(playerState.manaRegenRate)
        let wait = SKAction.wait(forDuration: regenInterval)
        let regenSequence = SKAction.sequence([wait, regenerateCharges])
        let repeatRegen = SKAction.repeatForever(regenSequence)
        self.run(repeatRegen, withKey: "regenerateCharges")
        
        // Start goblin spawning
        startSpawnPatterns(with: waveConfig)
        
        // Add this line with other reset operations
        currentWaveDamageTaken = 0
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
        return WaveConfig.createDefaultConfig(forWave: wave)
    }
    
    func endWave() {
        // Stop the actions
        self.removeAction(forKey: "regenerateCharges")
        self.removeAction(forKey: "spawnPattern")
        
        isSpawningEnabled = false
        
        // Reset combo at end of wave
        playerState.currentCombo = 0
    }
    
    func setupBackground() {
        background = SKSpriteNode(imageNamed: "Background")
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.size = self.size
        background.zPosition = -1
        addChild(background)
        
        // Add path visualization
        createGoblinPath()
    }
    
    private func createGoblinPath() {
        // Calculate path points using same logic as Goblin.swift
        let startY = size.height + 50
        let endY: CGFloat = 200
        let segmentHeight = (startY - endY) / 2
        
        let pathPoints = [
            CGPoint(x: size.width * 0.2, y: startY),
            CGPoint(x: size.width * 0.8, y: startY - segmentHeight),
            CGPoint(x: size.width * 0.2, y: startY - segmentHeight * 1.3),
            CGPoint(x: size.width * 0.8, y: endY + segmentHeight * 0.5),
            CGPoint(x: size.width * 0.5, y: endY)
        ]
        
        // Create bezier path
        let path = UIBezierPath()
        path.move(to: pathPoints[0])
        
        // Create curved path through points
        for i in 1..<pathPoints.count {
            let point = pathPoints[i]
            if i <= 4 {  // Handle first 4 points with curves
                let cp1: CGPoint
                let cp2: CGPoint
                
                // Calculate control points based on position in sequence
                switch i {
                    case 1:  // First curve
                        cp1 = CGPoint(x: pathPoints[0].x, y: pathPoints[0].y - segmentHeight * 0.5)
                        cp2 = CGPoint(x: point.x, y: point.y + segmentHeight * 0.5)
                    case 2:  // Second curve
                        cp1 = CGPoint(x: pathPoints[1].x, y: pathPoints[1].y - segmentHeight * 0.4)
                        cp2 = CGPoint(x: point.x, y: point.y + segmentHeight * 0.4)
                    case 3:  // Third curve
                        cp1 = CGPoint(x: pathPoints[2].x, y: pathPoints[2].y - segmentHeight * 0.3)
                        cp2 = CGPoint(x: point.x, y: point.y + segmentHeight * 0.3)
                    case 4:  // Fourth curve
                        cp1 = CGPoint(x: pathPoints[3].x, y: pathPoints[3].y - segmentHeight * 0.2)
                        cp2 = CGPoint(x: point.x, y: point.y + segmentHeight * 0.2)
                    default:
                        cp1 = point
                        cp2 = point
                }
                
                path.addCurve(to: point, controlPoint1: cp1, controlPoint2: cp2)
            } else {
                // Use quad curve for final point
                path.addQuadCurve(to: point, controlPoint: CGPoint(
                    x: (pathPoints[i-1].x + point.x) / 2,
                    y: (pathPoints[i-1].y + point.y) / 2
                ))
            }
        }
        
        // Create shape node from path
        let pathNode = SKShapeNode(path: path.cgPath)
        pathNode.strokeColor = .white
        pathNode.lineWidth = 2
        pathNode.alpha = 0.3
        pathNode.zPosition = -0.5  // Between background and game elements
        pathNode.name = "goblinPath"
        
        // Add dots at path points for visual reference
        for point in pathPoints {
            let dot = SKShapeNode(circleOfRadius: 3)
            dot.fillColor = .white
            dot.strokeColor = .clear
            dot.alpha = 0.3
            dot.position = point
            dot.zPosition = -0.5
            addChild(dot)
        }
        
        addChild(pathNode)
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
        currentWaveDamageTaken += damage
        
        // Create damage number at castle position with isCastleDamage set to true
        self.playerView.createDamageNumber(
            damage: Int(damage),
            at: CGPoint(x: castlePosition.x, y: castlePosition.y + 50),
            isCritical: false,
            isCastleDamage: true
        )
        
        // Add screen shake with intensity based on damage
        let shakeIntensity = min(damage * 0.5, 12.0) // Cap maximum shake intensity
        playerView.shakeScreen(intensity: shakeIntensity)
        
        // Only call gameOver if castle health reaches 0
        if playerState.takeDamage(damage) && playerState.castleHealth <= 0 {
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        touchStartLocation = touch.location(in: self)
        touchStartTime = touch.timestamp
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first,
              let startLocation = touchStartLocation,
              let startTime = touchStartTime else { return }
        
        let location = touch.location(in: self)
        // Calculate swipe distance and time
        let dx = location.x - startLocation.x
        let timeDelta = touch.timestamp - startTime
        
        // Only process swipe if it was quick enough
        if timeDelta <= swipeTimeThreshold {
            if abs(dx) >= swipeThreshold {
                // Swipe detected
                if dx > 0 {
                    // Swipe right
                    playerState.cycleSpellBackwards()
                } else {
                    // Swipe left - cycle backwards
                    playerState.cycleSpell()
                }
                return
            }
        }
        
        // Handle tutorial taps first
        if tutorialManager.isTutorialActive {
            tutorialManager.handleTap(touch)
            return
        }
        
        // Handle score screen taps
        if let scoreScreen = self.children.first(where: { $0 is ScoreScreen }) as? ScoreScreen {
            scoreScreen.handleTap(at: location)
            return
        }
        
        if isInShop {
            // Forward touch to shop view if it exists
            if let shopView = self.children.first(where: { $0 is ShopView }) as? ShopView {
                shopView.handleTap(at: location)
            }
            return
        }
        
        // Handle spell cycling via touch on spell icon
        for node in nodes(at: location) {
            if node.name == "cycleSpell" {
                playerView.handleSpellCycleTouch(node)
                return
            }
        }
        
        // Handle button taps
        let touchedNode = nodes(at: location).first
        if let name = touchedNode?.name {
            switch name {
            case "restartButton":
                restartGame()
                return
            case "mainMenuButton":
                goToMainMenu()
                return
            default:
                if let node = touchedNode, 
                   node.name?.hasPrefix("specialButton") == true,
                   let index = Int(node.name?.dropFirst("specialButton".count) ?? "") {
                    if !playerView.handleSpecialButtonTap(node, touch.timestamp) {
                        // Get the special for this specific button index
                        let specialSlots = playerState.getSpecialSlots()
                        if let special = specialSlots[index], special.canUse() {
                            playerState.selectSpecialSlot(index)
                            useSpecial(at: location)
                        }
                    }
                    return  // Add return here to prevent spell casting
                }
                break
            }
        }
        
        // Only cast spell if spawning is enabled and game is not over
        if !isSpawningEnabled || isGameOver {
            return
        }
        
        castSpell(to: location)
    }
    
    func castSpell(to location: CGPoint) {
        let casterPosition = playerView.playerPosition
        let spell = playerState.getCurrentSpell()

        if(spell.cast(from: casterPosition, to: location, by: playerState, in: self)) {
            playerView.animateSpellCast()
        }
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
        // Simply add charges up to max for single wizard
        playerState.spellCharges = min(
            playerState.maxSpellCharges,
            playerState.spellCharges + spellChargeRestoreAmount
        )
        
        // Create collection effect
        createFrameAnimation(at: position,
                            framePrefix: "ManaPot",
                            frameCount: 4,
                            duration: 0.6,
                            size: CGSize(width: 100, height: 100))
    }
    
    func goblinDied(container: Goblin.GoblinContainer, goblinKilled: Bool) {
        if goblinKilled {
            // Increment combo when goblin is killed by player
            playerState.incrementCombo()
            
            // Calculate combo multiplier with a cap of 5.0
            let comboMultiplier = min(5.0, 1.0 + Double(playerState.currentCombo - 1) * 0.1)
            
            // Update score with capped combo multiplier
            let basePoints = 10
            let points = Int(Double(basePoints) * comboMultiplier)
            playerState.addScore(points: points)
            
            // Apply capped multiplier to coins as well
            let baseCoins = container.goldValue
            let multipliedCoins = Int(floor(Double(baseCoins) * comboMultiplier))
            playerState.addCoins(multipliedCoins)

            // Add logic for potion drop
            let dropChance = 0.1 // 10% chance to drop a potion
            if Double.random(in: 0...1) < dropChance {
                dropManaPotion(at: container.sprite.position)
            }
        }
        
        // Only decrease if counter is greater than 0
        if remainingGoblins > 0 {
            remainingGoblins -= 1
            
            // Check if wave is complete when counter reaches 0
            if remainingGoblins == 0 {
                waveCompleted()
            }
        }
    }
    
    func dropManaPotion(at position: CGPoint) {
        // Immediately restore mana and show effect
        playerState.spellCharges = min(
            playerState.maxSpellCharges,
            playerState.spellCharges + spellChargeRestoreAmount
        )
        
        // Create collection effect
        createFrameAnimation(at: position,
                            framePrefix: "ManaPot",
                            frameCount: 4,
                            duration: 0.6,
                            size: CGSize(width: 100, height: 100))
    }
    
    func waveCompleted() {
        guard !isGameOver else { return }
        
        endWave()
        
        // Pause special cooldowns when showing score screen
        if let special = playerState.getCurrentSpecial() {
            special.pauseCooldown()
        }
        
        // Check for perfect wave bonus
        let perfectWaveBonus = currentWaveDamageTaken == 0
        if perfectWaveBonus {
            playerState.addScore(points: 50)
            playerState.addCoins(10)
        }
        
        // Show score screen first
        let scoreScreen = ScoreScreen(
            size: self.size,
            playerState: playerState,
            waveNumber: currentWave,
            damageTaken: currentWaveDamageTaken,
            perfectWaveBonus: perfectWaveBonus,  // Pass the bonus status
            onContinue: { [weak self] in
                self?.showShopView()
                // Remove score screen
                self?.children.first(where: { $0 is ScoreScreen })?.removeFromParent()
            }
        )
        scoreScreen.zPosition = 1000
        addChild(scoreScreen)
    }
    
    func showShopView() {
        // Special cooldown is already paused from score screen
        
        let shopView = ShopView(
            size: self.size, 
            playerState: playerState,
            playerView: playerView,
            config: nextWaveConfig,
            currentWave: currentWave,
            onClose: { [weak self] in
                self?.closeShopView()
            }
        )
        shopView.zPosition = 1000
        addChild(shopView)
        isInShop = true
    }
    
    func closeShopView() {
        if let shopView = self.children.first(where: { $0 is ShopView }) {
            shopView.removeFromParent()
        }
        isInShop = false
        
        // Resume special cooldowns when closing shop
        if let special = playerState.getCurrentSpecial() {
            special.resumeCooldown()
        }
        
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
        remainingGoblins = GameConfig.defaultMaxGoblinsPerWave
        
        // Reset spawning properties
        isSpawningEnabled = false
        totalGoblinsSpawned = 0
        isInShop = false
        
        // Setup all components
        setupBackground()
        
        // Re-initialize PlayerView with the reset state
        playerView = PlayerView(scene: self, state: playerState)
        
        setupWaves()
        
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
    
    func startNextWave() {
        // Create countdown label
        let countdownLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        countdownLabel.fontSize = 72
        countdownLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        countdownLabel.zPosition = 1000 // Ensure it appears above other nodes
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
        // Add new cases
        case .vFormation(let count):
            spawnVFormation(count: count)
        case .circle(let count, let radius):
            spawnCircleFormation(count: count, radius: radius)
        case .crossFormation(let count):
            spawnCrossFormation(count: count)
        case .spiral(let count, let radius):
            spawnSpiralFormation(count: count, radius: radius)
        case .random(let count, let spread):
            spawnRandomFormation(count: count, spread: spread)
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
    
    func spawnVFormation(count: Int) {
        let spacing: CGFloat = 50
        let angleInRadians: CGFloat = .pi / 4 // 45 degrees
        
        // Calculate starting position at top center
        let startX = size.width / 2
        let startY = size.height + 50
        
        for i in 0..<count {
            let offset = CGFloat(i) * spacing
            
            // Left wing
            if i > 0 {
                let leftX = startX - (offset * cos(angleInRadians))
                let leftY = startY - (offset * sin(angleInRadians))
                spawnGoblin(at: CGPoint(x: leftX, y: leftY))
            }
            
            // Right wing
            if i > 0 {
                let rightX = startX + (offset * cos(angleInRadians))
                let rightY = startY - (offset * sin(angleInRadians))
                spawnGoblin(at: CGPoint(x: rightX, y: rightY))
            }
            
            // Leader
            if i == 0 {
                spawnGoblin(at: CGPoint(x: startX, y: startY))
            }
        }
    }
    
    func spawnCircleFormation(count: Int, radius: CGFloat) {
        let centerX = size.width / 2
        let centerY = size.height + radius
        
        for i in 0..<count {
            let angle = (CGFloat.pi * 2 * CGFloat(i)) / CGFloat(count)
            let x = centerX + radius * cos(angle)
            let y = centerY + radius * sin(angle)
            spawnGoblin(at: CGPoint(x: x, y: y))
        }
    }
    
    func spawnCrossFormation(count: Int) {
        let centerX = size.width / 2
        let centerY = size.height + 50
        let spacing: CGFloat = 50
        
        // Spawn center goblin
        spawnGoblin(at: CGPoint(x: centerX, y: centerY))
        
        // Spawn in four directions
        for i in 1...count {
            let offset = CGFloat(i) * spacing
            
            // Up
            spawnGoblin(at: CGPoint(x: centerX, y: centerY + offset))
            // Down
            spawnGoblin(at: CGPoint(x: centerX, y: centerY - offset))
            // Left
            spawnGoblin(at: CGPoint(x: centerX - offset, y: centerY))
            // Right
            spawnGoblin(at: CGPoint(x: centerX + offset, y: centerY))
        }
    }
    
    func spawnSpiralFormation(count: Int, radius: CGFloat) {
        let centerX = size.width / 2
        let centerY = size.height + radius
        let radiusIncrement = radius / CGFloat(count)
        
        for i in 0..<count {
            let currentRadius = radiusIncrement * CGFloat(i + 1)
            let angle = CGFloat(i) * .pi / 2
            let x = centerX + currentRadius * cos(angle)
            let y = centerY + currentRadius * sin(angle)
            spawnGoblin(at: CGPoint(x: x, y: y))
        }
    }
    
    func spawnRandomFormation(count: Int, spread: CGFloat) {
        let centerX = size.width / 2
        let centerY = size.height + 50
        
        for _ in 0..<count {
            let randomX = centerX + CGFloat.random(in: -spread...spread)
            let randomY = centerY + CGFloat.random(in: -spread...spread)
            spawnGoblin(at: CGPoint(x: randomX, y: randomY))
        }
    }
    
    func createFrameAnimation(at position: CGPoint, 
                            framePrefix: String, 
                            frameCount: Int, 
                            duration: TimeInterval,
                            size: CGSize) {
        // Create sprite with first frame
        let animationNode = SKSpriteNode(imageNamed: "\(framePrefix)1")
        animationNode.position = position
        animationNode.size = size
        addChild(animationNode)
        
        // Create array of textures
        var textures: [SKTexture] = []
        for i in 1...frameCount {
            let texture = SKTexture(imageNamed: "\(framePrefix)\(i)")
            textures.append(texture)
        }
        
        // Create animation action
        let animate = SKAction.animate(with: textures, 
                                     timePerFrame: duration/Double(frameCount))
        let remove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([animate, remove])
        
        // Run animation once
        animationNode.run(sequence)
    }
    
    func useSpecial(at location: CGPoint) {
        guard let special = playerState.getCurrentSpecial(),
              special.canUse() else {
            if let special = playerState.getCurrentSpecial() {
                print("❌ Cannot use special \(special.name) - on cooldown")
            } else {
                print("❌ No special ability selected")
            }
            return
        }
        
        print("🎯 Using special \(special.name) at position: \(location)")
        let casterPosition = playerView.playerPosition
        
        if special.use(from: casterPosition, to: location, by: playerState, in: self) {
            print("✨ Special \(special.name) successfully used")
            playerView.updateSpecialCooldown(at: playerState.currentSpecialIndex)
        } else {
            print("❌ Special \(special.name) failed to activate")
        }
    }
    
    private var nextWaveConfig: WaveConfig {
        let nextWaveNumber = currentWave + 1
        
        // Try to get specific config for next wave
        if let config = waveConfigs[nextWaveNumber] {
            return config
        }
        
        // If no specific config exists, check for default config (-1)
        if let defaultConfig = waveConfigs[-1] {
            // Modify default config based on wave number
            var modifiedConfig = defaultConfig
            modifiedConfig.maxGoblins = (nextWaveNumber - 1) * 5
            modifiedConfig.baseSpawnInterval = max(2.0 - 0.1 * Double(nextWaveNumber - 1), 0.5)
            return modifiedConfig
        }
        
        // If no configs found, create a new default config
        return WaveConfig.createDefaultConfig(forWave: nextWaveNumber)
    }
}
