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
    var goblinManager: GoblinManager!
    
    // Mana potions
    var manaPotions: [SKSpriteNode] = []
    let manaPotionSpawnInterval: TimeInterval = 10.0  // Spawn rate
    let manaPotionManaRestore: CGFloat = 60.0  // Amount of mana restored
    let manaPotionDuration: TimeInterval = 10.0 // How long potions stay on the map
    
    // Game over properties
    var restartButton: SKLabelNode!
    var mainMenuButton: SKLabelNode!
    
    override func didMove(to view: SKView) {
        // Initialize Player State and View
        playerState = PlayerState()
        playerView = PlayerView(scene: self, state: playerState)
        
        setupBackground()
        
        // Initialize GoblinManager
        goblinManager = GoblinManager(scene: self, castlePosition: playerView.castlePosition)
        goblinManager.castleTakeDamage = { [weak self] damage in
            self?.castleTakeDamage(damage: damage)
        }
        goblinManager.goblinKilled = { [weak self] position in
            guard let self = self else { return }
            // Add coins when goblin is killed (50% chance of 5 coins)
            if Bool.random() {
                self.playerState.addCoins(5) // 50% chance of 5 coins
            }
            // Add points when goblin is eliminated
            self.playerState.addScore(points: 10)
            self.createCoinEffect(at: position)
        }
        
        let regenerateMana = SKAction.run { [weak self] in
            self?.playerState.regenerateMana()
        }
        let wait = SKAction.wait(forDuration: 1.0)
        let regenSequence = SKAction.sequence([wait, regenerateMana])
        run(SKAction.repeatForever(regenSequence))
        
        // Setup mana potion spawning
        let spawnPotionAction = SKAction.sequence([
            SKAction.wait(forDuration: manaPotionSpawnInterval),
            SKAction.run { [weak self] in
                self?.spawnManaPotion()
            }
        ])
        run(SKAction.repeatForever(spawnPotionAction))
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        // Setup goblin spawning
        let spawnGoblin = SKAction.run { [weak self] in
            guard let self = self else { return }
            let randomX = CGFloat.random(in: 0...self.size.width)
            let spawnPosition = CGPoint(x: randomX, y: self.size.height + 50)
            self.spawnGoblin(at: spawnPosition)
        }
        let waitForNextSpawn = SKAction.wait(forDuration: goblinSpawnInterval)
        let spawnSequence = SKAction.sequence([waitForNextSpawn, spawnGoblin])
        run(SKAction.repeatForever(spawnSequence))
    }
    
    func spawnManaPotion() {
        // Only spawn if the wave is active
        guard isSpawningEnabled else { return }
        
        // Create random position within playable area
        let randomX = CGFloat.random(in: 100...size.width-100)
        let randomY = CGFloat.random(in: 200...size.height-100)
        let position = CGPoint(x: randomX, y: randomY)
        
        // Create mana potion sprite
        let potion = SKSpriteNode(color: .blue, size: CGSize(width: 30, height: 30))
        potion.position = position
        potion.name = "manaPotion"
        
        // Add some visual effects
        potion.alpha = 0.8
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.5),
            SKAction.scale(to: 1.0, duration: 0.5)
        ])
        potion.run(SKAction.repeatForever(pulse))
        
        // Add automatic removal after duration
        let removeSequence = SKAction.sequence([
            SKAction.wait(forDuration: manaPotionDuration),
            SKAction.fadeOut(withDuration: 1.0),
            SKAction.removeFromParent()
        ])
        potion.run(removeSequence)
        
        addChild(potion)
        manaPotions.append(potion)
    }
    
    func setupBackground() {
        background = SKSpriteNode(imageNamed: "Background")
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.size = self.size
        background.zPosition = -1
        addChild(background)
    }
    
    func handlePotionHit(potion: SKSpriteNode, spellLocation: CGPoint) {
        // Find the closest wizard to the spell location
        let distanceToPlayerOne = spellLocation.distance(to: playerView.playerOnePosition)
        let distanceToPlayerTwo = spellLocation.distance(to: playerView.playerTwoPosition)
        
        // Determine which wizard gets the mana
        if distanceToPlayerOne < distanceToPlayerTwo {
            playerState.playerOneMana = min(playerState.maxMana, playerState.playerOneMana + manaPotionManaRestore)
        } else {
            playerState.playerTwoMana = min(playerState.maxMana, playerState.playerTwoMana + manaPotionManaRestore)
        }
        
        // Create mana restore effect
        createManaRestoreEffect(at: potion.position)
        
        // Remove the potion
        if let index = manaPotions.firstIndex(of: potion) {
            manaPotions.remove(at: index)
        }
        potion.removeFromParent()
    }
    
    func createManaRestoreEffect(at position: CGPoint) {
        // Create a visual effect for mana restoration
        let effect = SKEmitterNode()
        effect.particleTexture = SKTexture(imageNamed: "spark") // Add a spark image to assets
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
        
        // Remove effect after duration
        let wait = SKAction.wait(forDuration: 0.5)
        let remove = SKAction.removeFromParent()
        effect.run(SKAction.sequence([wait, remove]))
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
        // Only spawn if spawning is enabled and we haven't reached the wave's goblin limit
        if !isSpawningEnabled || totalGoblinsSpawned >= maxGoblinsPerWave {
            return
        }
        
        totalGoblinsSpawned += 1
        
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
        
        addChild(goblin)
        
        // Create container and store it
        let container = GoblinContainer(sprite: goblin, healthBar: healthBar, healthFill: healthFill)
        goblinContainers.append(container)
        
        let moveAction = SKAction.move(to: playerView.castlePosition, duration: TimeInterval(position.distance(to: playerView.castlePosition) / goblinSpeed))
        let damageAction = SKAction.run { [weak self] in
            self?.castleTakeDamage(damage: self?.goblinDamage ?? 10)
            
            // Remove from containers array
            if let self = self {
                self.goblinContainers.removeAll(where: { $0.sprite == goblin })
            }
            goblin.removeFromParent()
            
            // Only decrease if counter is greater than 0
            if let remainingGoblins = self?.remainingGoblins, remainingGoblins > 0 {
                self?.remainingGoblins -= 1
                self?.updateGoblinCounter()
                
                // Check if wave is complete when counter reaches 0
                if self?.remainingGoblins == 0 {
                    self?.startNextWave()
                }
            }
        }
        
        let sequence = SKAction.sequence([moveAction, damageAction])
        goblin.run(sequence)
    }
    
    func castleTakeDamage(damage: CGFloat) {
        if playerState.takeDamage(damage) {
            gameOver()
        }
    }
    
    func gameOver() {
        removeAllActions()
        
        let gameOverLabel = SKLabelNode(text: "Game Over!")
        gameOverLabel.fontSize = 50
        gameOverLabel.fontColor = .red
        gameOverLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.7)
        addChild(gameOverLabel)
        
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
        let touchedNode = nodes(at: touchLocation).first
        
        // Handle button taps
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
        
        // Determine which wizard is casting based on proximity
        let p1Position = playerView.playerOnePosition
        let p2Position = playerView.playerTwoPosition
        
        // Calculate distances to each wizard
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
        // Check if the wave is active
        guard isSpawningEnabled else { return false }
        // Get caster's position
        let casterPosition = isPlayerOne ? playerView.playerOnePosition : playerView.playerTwoPosition
        
        // Get the player's spell
        let spell = playerState.getSpell(isPlayerOne: isPlayerOne)
        
        // Cast the spell
        let success = spell.cast(from: casterPosition, to: location, by: playerState, isPlayerOne: isPlayerOne, in: self)
        return success
    }

    func applySpell(_ spell: Spell, at position: CGPoint) {
        // Apply spell effects to enemies
        goblinContainers.forEach { container in
            let distance = position.distance(to: container.sprite.position)
            if distance <= spell.aoeRadius {
                spell.applyToGoblin(container: container, in: self)
            }
        }
        
        // Check for potion hits
        for potion in manaPotions {
            if position.distance(to: potion.position) <= spell.aoeRadius {
                handlePotionHit(potion: potion, spellLocation: position)
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
    
    func restartGame() {
        // Remove all nodes and reset the scene
        removeAllChildren()
        removeAllActions()
        
        // Reset properties
        playerState.reset()
        goblins.removeAll()
        goblinContainers.removeAll()
        manaPotions.removeAll()
        
        // Reset wave and goblin counters
        currentWave = 1
        remainingGoblins = 10
        
        // Reset spawning properties
        isSpawningEnabled = true
        totalGoblinsSpawned = 0
        
        // Setup all components
        setupBackground()
        
        // Re-initialize PlayerView with the reset state
        playerView = PlayerView(scene: self, state: playerState)
        
        waveSetup()
        goblinCounterSetup()
    
        let regenerateMana = SKAction.run { [weak self] in
            self?.playerState.regenerateMana()
        }
        let wait = SKAction.wait(forDuration: 1.0)
        let regenSequence = SKAction.sequence([wait, regenerateMana])
        run(SKAction.repeatForever(regenSequence))
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        // Restart goblin spawning
        let spawnGoblin = SKAction.run { [weak self] in
            guard let self = self else { return }
            let randomX = CGFloat.random(in: 0...self.size.width)
            let spawnPosition = CGPoint(x: randomX, y: self.size.height + 50)
            self.spawnGoblin(at: spawnPosition)
        }
        let waitForNextSpawn = SKAction.wait(forDuration: goblinSpawnInterval)
        let spawnSequence = SKAction.sequence([waitForNextSpawn, spawnGoblin])
        run(SKAction.repeatForever(spawnSequence))
    }
    
    func goToMainMenu() {
        let mainMenuScene = WGMainMenu(size: self.size)
        mainMenuScene.scaleMode = SKSceneScaleMode.aspectFill
        view?.presentScene(mainMenuScene, transition: SKTransition.fade(withDuration: 0.5))
    }
    
    func waveSetup() {
        waveLabel = SKLabelNode(text: "Wave: \(currentWave)")
        waveLabel.fontSize = 24
        waveLabel.fontColor = .black
        waveLabel.position = CGPoint(x: 80, y: size.height - 60)
        addChild(waveLabel)
    }
    
    func goblinCounterSetup() {
        goblinCountLabel = SKLabelNode(text: "Goblins: \(remainingGoblins)")
        goblinCountLabel.fontSize = 24
        goblinCountLabel.fontColor = .black
        goblinCountLabel.position = CGPoint(x: size.width - 100, y: size.height - 60)
        addChild(goblinCountLabel)
    }
    
    func updateWaveLabel() {
        waveLabel.text = "Wave: \(currentWave)"
    }
    
    func updateGoblinCounter() {
        goblinCountLabel.text = "Goblins: \(remainingGoblins)"
    }
    
    func startNextWave() {
        isSpawningEnabled = false
        
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
        let startWave = SKAction.run { [weak self] in
            guard let self = self else { return }
            self.currentWave += 1
            self.remainingGoblins = 10 + (self.currentWave - 1) * 5
            self.maxGoblinsPerWave = self.remainingGoblins
            self.totalGoblinsSpawned = 0
            self.isSpawningEnabled = true
            self.updateWaveLabel()
            self.updateGoblinCounter()
            self.playerState.playerOneMana = self.playerState.maxMana
            self.playerState.playerTwoMana = self.playerState.maxMana
        }
        
        // Add the remove label and start wave actions to the sequence
        actions.append(removeLabel)
        actions.append(startWave)
        
        // Run the complete sequence
        run(SKAction.sequence(actions))
    }
}
