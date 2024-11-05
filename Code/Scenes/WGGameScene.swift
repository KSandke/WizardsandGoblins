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

extension CGVector {
    func normalized() -> CGVector {
        let length = sqrt(dx * dx + dy * dy)
        return length > 0 ? CGVector(dx: dx / length, dy: dy / length) : .zero
    }
}

extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        let dx = self.x - point.x
        let dy = self.y - point.y
        return sqrt(dx * dx + dy * dy)
    }
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // Wizards
    var playerOne: SKSpriteNode!
    var playerTwo: SKSpriteNode!
    
    // Castle
    var castle: SKSpriteNode!
    var castleHealth: CGFloat = 100
    let maxCastleHealth: CGFloat = 100
    
    // Castle Health Bar
    var castleHealthBar: SKShapeNode!
    var castleHealthFill: SKShapeNode!
    
    // Mana Info
    var playerOneMana: CGFloat = 100
    var playerTwoMana: CGFloat = 100
    let maxMana: CGFloat = 100
    let spellCost: CGFloat = 20
    let manaRegenRate: CGFloat = 5
    
    // AOE Effect
    let aoeRadius: CGFloat = 50
    let aoeDuration: TimeInterval = 1.0
    
    // Mana bars
    var playerOneManaBar: SKShapeNode!
    var playerTwoManaBar: SKShapeNode!
    var playerOneManaFill: SKShapeNode!
    var playerTwoManaFill: SKShapeNode!
    
    // Goblin Properties
    var goblins: [SKSpriteNode] = []
    let goblinSpeed: CGFloat = 100
    let goblinDamage: CGFloat = 10
    let goblinSpawnInterval: TimeInterval = 2.0
    let goblinHealth: CGFloat = 50
    
    // Add these properties near the top of the GameScene class
    var restartButton: SKLabelNode!
    var mainMenuButton: SKLabelNode!
    var currentWave: Int = 1
    var remainingGoblins: Int = 10
    var waveLabel: SKLabelNode!
    var goblinCountLabel: SKLabelNode!
    
    // Add these properties at the top of the class
    var isSpawningEnabled = true
    var totalGoblinsSpawned = 0
    var maxGoblinsPerWave = 10
    
    override func didMove(to view: SKView) {
        backgroundColor = .green
        
        castleSetup()
        wizardSetup()
        manaSetup()
        waveSetup()
        goblinCounterSetup()
        
        let regenerateMana = SKAction.run { [weak self] in
            self?.regenerateMana()
        }
        let wait = SKAction.wait(forDuration: 1.0)
        let regenSequence = SKAction.sequence([wait, regenerateMana])
        run(SKAction.repeatForever(regenSequence))
        
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
    
    func createAOEEffect(at position: CGPoint) {
        // Create the AOE circle
        let aoeCircle = SKShapeNode(circleOfRadius: aoeRadius)
        aoeCircle.fillColor = .orange
        aoeCircle.strokeColor = .clear
        aoeCircle.alpha = 0.5
        aoeCircle.position = position
        aoeCircle.zPosition = 1 // Ensure it appears above the background but below other elements
        addChild(aoeCircle)
        
        // Damage goblins in AOE radius
        goblins.forEach { goblin in
            let distance = position.distance(to: goblin.position)
            if distance <= aoeRadius {
                if var health = goblin.userData?.value(forKey: "health") as? CGFloat {
                    health -= 25 // Spell damage
                    if health <= 0 {
                        goblin.removeFromParent()
                        goblins.removeAll(where: { $0 == goblin })
                        
                        // Only decrease if counter is greater than 0
                        if remainingGoblins > 0 {
                            remainingGoblins -= 1
                            updateGoblinCounter()
                            
                            // Check if wave is complete when counter reaches 0
                            if remainingGoblins == 0 {
                                startNextWave()
                            }
                        }
                    } else {
                        goblin.userData?.setValue(health, forKey: "health")
                    }
                }
            }
        }
        
        // Create fade out and remove sequence
        let fadeOut = SKAction.fadeOut(withDuration: aoeDuration)
        let remove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([fadeOut, remove])
        
        // Run the sequence
        aoeCircle.run(sequence)
    }
    
    func castleSetup() {
        // Create castle as grey rectangle
        castle = SKSpriteNode(color: .gray, size: CGSize(width: size.width, height: 100))
        castle.position = CGPoint(x: size.width/2, y: 50) // Position at bottom
        addChild(castle)
        
        // Castle Health Bar
        castleHealthBar = SKShapeNode(rectOf: CGSize(width: 200, height: 20))
        castleHealthBar.fillColor = .gray
        castleHealthBar.strokeColor = .black
        castleHealthBar.position = CGPoint(x: size.width/2, y: 20)
        addChild(castleHealthBar)
        
        castleHealthFill = SKShapeNode(rectOf: CGSize(width: 200, height: 20))
        castleHealthFill.fillColor = .red
        castleHealthFill.strokeColor = .clear
        castleHealthFill.position = castleHealthBar.position
        addChild(castleHealthFill)
        
        updateCastleHealthBar()
    }
    
    func wizardSetup() {
        // Left Wizard - on castle
        playerOne = SKSpriteNode(imageNamed: "Wizard1")
        playerOne.size = CGSize(width: 75, height: 75)
        playerOne.position = CGPoint(x: size.width * 0.25, y: 100) // Position on top of castle
        addChild(playerOne)
        
        // Right Wizard - on castle
        playerTwo = SKSpriteNode(imageNamed: "Wizard2")
        playerTwo.size = CGSize(width: 75, height: 75)
        playerTwo.position = CGPoint(x: size.width * 0.75, y: 100) // Position on top of castle
        addChild(playerTwo)
    }
    
    func manaSetup() {
        // Player One Mana Bar (Background)
        playerOneManaBar = SKShapeNode(rectOf: CGSize(width: 100, height: 10))
        playerOneManaBar.fillColor = .gray
        playerOneManaBar.strokeColor = .black
        playerOneManaBar.position = CGPoint(x: playerOne.position.x, y: playerOne.position.y - 50)
        addChild(playerOneManaBar)
        
        // Player One Mana Fill
        playerOneManaFill = SKShapeNode(rectOf: CGSize(width: 100, height: 10))
        playerOneManaFill.fillColor = .blue
        playerOneManaFill.strokeColor = .clear
        playerOneManaFill.position = playerOneManaBar.position
        addChild(playerOneManaFill)
        
        // Player Two Mana Bar (Background)
        playerTwoManaBar = SKShapeNode(rectOf: CGSize(width: 100, height: 10))
        playerTwoManaBar.fillColor = .gray
        playerTwoManaBar.strokeColor = .black
        playerTwoManaBar.position = CGPoint(x: playerTwo.position.x, y: playerTwo.position.y - 50)
        addChild(playerTwoManaBar)
        
        // Player Two Mana Fill
        playerTwoManaFill = SKShapeNode(rectOf: CGSize(width: 100, height: 10))
        playerTwoManaFill.fillColor = .blue
        playerTwoManaFill.strokeColor = .clear
        playerTwoManaFill.position = playerTwoManaBar.position
        addChild(playerTwoManaFill)
        
        updateManaBars()
    }
    
    func regenerateMana() {
        playerOneMana = min(maxMana, playerOneMana + manaRegenRate)
        playerTwoMana = min(maxMana, playerTwoMana + manaRegenRate)
        updateManaBars()
    }
    
    func updateManaBars() {
        playerOneManaFill.xScale = playerOneMana / maxMana
        playerTwoManaFill.xScale = playerTwoMana / maxMana
    }
    
    func updateCastleHealthBar() {
        castleHealthFill.xScale = castleHealth / maxCastleHealth
    }
    
    func castSpell(from castingPlayer: SKSpriteNode, to location: CGPoint) -> Bool {
        // Check which player is casting and get their mana
        let playerMana = castingPlayer == playerOne ? playerOneMana : playerTwoMana
        
        // Check if enough mana
        if playerMana < spellCost {
            return false
        }
        
        // Deduct mana
        if castingPlayer == playerOne {
            playerOneMana -= spellCost
        } else {
            playerTwoMana -= spellCost
        }
        
        // Create spell
        let spell = SKSpriteNode(imageNamed: "spell1")
        spell.size = CGSize(width: 50, height: 50)
        spell.position = castingPlayer.position
        addChild(spell)
        
        // Calculate direction
        let dx = location.x - castingPlayer.position.x
        let dy = location.y - castingPlayer.position.y
        
        // Calculate rotation angle (in radians)
        let angle = atan2(dy, dx)
        
        // Rotate spell to face movement direction
        spell.zRotation = angle + .pi/2 + .pi
        
        // Create completion handler for when spell reaches target
        let createAOE = SKAction.run { [weak self] in
            self?.createAOEEffect(at: location)
        }
        
        // Move spell and create AOE
        let moveAction = SKAction.move(to: location, duration: 1.0)
        let sequence = SKAction.sequence([moveAction, createAOE, SKAction.removeFromParent()])
        spell.run(sequence)
        
        // Update mana display
        updateManaBars()
        return true
    }
    
    func spawnGoblin(at position: CGPoint) {
        // Only spawn if spawning is enabled and we haven't reached the wave's goblin limit
        if !isSpawningEnabled || totalGoblinsSpawned >= maxGoblinsPerWave {
            return
        }
        
        totalGoblinsSpawned += 1
        
        let goblin = SKSpriteNode(imageNamed: "Goblin1") // Add goblin image to assets
        goblin.size = CGSize(width: 50, height: 50)
        goblin.position = position
        goblin.name = "goblin"
        
        let physicsBody = SKPhysicsBody(rectangleOf: goblin.size)
        physicsBody.isDynamic = true
        physicsBody.affectedByGravity = false
        physicsBody.categoryBitMask = 1
        physicsBody.contactTestBitMask = 2
        goblin.physicsBody = physicsBody
        
        goblin.userData = NSMutableDictionary()
        goblin.userData?.setValue(goblinHealth, forKey: "health")
        
        addChild(goblin)
        goblins.append(goblin)
        
        let moveAction = SKAction.move(to: castle.position, duration: TimeInterval(position.distance(to: castle.position) / goblinSpeed))
        let damageAction = SKAction.run { [weak self] in
            self?.castleTakeDamage(damage: self?.goblinDamage ?? 10)
            goblin.removeFromParent()
            self?.goblins.removeAll(where: { $0 == goblin })
            
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
        castleHealth = max(0, castleHealth - damage)
        updateCastleHealthBar()
        
        if castleHealth <= 0 {
            gameOver()
        }
    }
    
    func gameOver() {
        removeAllActions()
        
        let gameOverLabel = SKLabelNode(text: "Game Over!")
        gameOverLabel.fontSize = 50
        gameOverLabel.fontColor = .red
        gameOverLabel.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(gameOverLabel)
        
        // Add Restart Button
        restartButton = SKLabelNode(text: "Restart")
        restartButton.fontSize = 30
        restartButton.fontColor = .white
        restartButton.position = CGPoint(x: size.width/2, y: size.height/2 - 50)
        restartButton.name = "restartButton"
        addChild(restartButton)
        
        // Add Main Menu Button
        mainMenuButton = SKLabelNode(text: "Main Menu")
        mainMenuButton.fontSize = 30
        mainMenuButton.fontColor = .white
        mainMenuButton.position = CGPoint(x: size.width/2, y: size.height/2 - 100)
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
        
        // Existing spell casting logic
        guard let p1 = playerOne,
              let p2 = playerTwo else { return }
        
        // Calculate distances to each wizard
        let dx1 = touchLocation.x - p1.position.x
        let dy1 = touchLocation.y - p1.position.y
        let dx2 = touchLocation.x - p2.position.x
        let dy2 = touchLocation.y - p2.position.y
        
        let distance1 = sqrt(dx1 * dx1 + dy1 * dy1)
        let distance2 = sqrt(dx2 * dx2 + dy2 * dy2)
        
        // Determine primary and backup casters based on distance
        let (primaryCaster, backupCaster) = distance1 < distance2 ?
        (p1, p2) : (p2, p1)
        
        // Try to cast with primary caster, if fails try backup caster
        if !castSpell(from: primaryCaster, to: touchLocation) {
            _ = castSpell(from: backupCaster, to: touchLocation)
        }
    }
    
    func restartGame() {
        // Remove all nodes and reset the scene
        removeAllChildren()
        removeAllActions()
        
        // Reset properties
        castleHealth = maxCastleHealth
        playerOneMana = maxMana
        playerTwoMana = maxMana
        goblins.removeAll()
        
        // Reset wave and goblin counters
        currentWave = 1
        remainingGoblins = 10
        
        // Reset spawning properties
        isSpawningEnabled = true
        totalGoblinsSpawned = 0
        
        // Setup all components
        castleSetup()
        wizardSetup()
        manaSetup()
        waveSetup()
        goblinCounterSetup()
        
        let regenerateMana = SKAction.run { [weak self] in
            self?.regenerateMana()
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
        // Assuming you have a main menu scene called WGMainMenuScene
        if let mainMenuScene = SKScene(fileNamed: "WGMainMenuScene") {
            mainMenuScene.scaleMode = .aspectFill
            view?.presentScene(mainMenuScene, transition: SKTransition.fade(withDuration: 0.5))
        }
    }
    
    // Add these new setup functions
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
    
    // Add these new functions
    func updateWaveLabel() {
        waveLabel.text = "Wave: \(currentWave)"
    }
    
    func updateGoblinCounter() {
        goblinCountLabel.text = "Goblins: \(remainingGoblins)"
    }
    
    func startNextWave() {
        isSpawningEnabled = false
        
        let waitAction = SKAction.wait(forDuration: 5.0)
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
        
        run(SKAction.sequence([waitAction, startWave]))
    }
}
