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
        
        // Initialize Goblin Manager
        goblinManager = Goblin(scene: self, playerState: playerState, playerView: playerView)
        
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
    }
    
    func setupBackground() {
        background = SKSpriteNode(imageNamed: "Background")
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.size = self.size
        background.zPosition = -1
        addChild(background)
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
        // Existing touch handling code...
    }
    
    func applySpell(_ spell: Spell, at position: CGPoint) {
        // Apply spell effects to goblins
        for container in goblinManager.goblinContainers {
            let distance = position.distance(to: container.sprite.position)
            if distance <= spell.aoeRadius {
                spell.applyToGoblin(container: container, in: self)
                if let health = container.sprite.userData?["health"] as? CGFloat, health <= 0 {
                    goblinManager.goblinDied(container: container)
                }
            }
        }
        
        // Check for potion hits
        for potion in manaPotions {
            if position.distance(to: potion.position) <= spell.aoeRadius {
                handlePotionHit(potion: potion, spellLocation: position)
            }
        }
    }
    
    func spawnManaPotion() {
        // Existing code...
    }
    
    func handlePotionHit(potion: SKSpriteNode, spellLocation: CGPoint) {
        // Existing code...
    }
    
    func restartGame() {
        // Restart the game and reinitialize goblinManager
        removeAllChildren()
        removeAllActions()
        
        playerState.reset()
        playerView = PlayerView(scene: self, state: playerState)
        
        setupBackground()
        
        goblinManager = Goblin(scene: self, playerState: playerState, playerView: playerView)
        
        // Re-run the mana regeneration and potion spawning actions
        let regenerateMana = SKAction.run { [weak self] in
            self?.playerState.regenerateMana()
        }
        let wait = SKAction.wait(forDuration: 1.0)
        let regenSequence = SKAction.sequence([wait, regenerateMana])
        run(SKAction.repeatForever(regenSequence))
        
        let spawnPotionAction = SKAction.sequence([
            SKAction.wait(forDuration: manaPotionSpawnInterval),
            SKAction.run { [weak self] in
                self?.spawnManaPotion()
            }
        ])
        run(SKAction.repeatForever(spawnPotionAction))
    }
}
