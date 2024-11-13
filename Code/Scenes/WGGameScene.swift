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
    let goblinSpawnInterval: TimeInterval = 2.0
    
    // Mana potions
    var manaPotions: [SKSpriteNode] = []
    let manaPotionSpawnInterval: TimeInterval = 10.0  // Spawn rate
    let manaPotionManaRestore: CGFloat = 60.0  // Amount of mana restored
    let manaPotionDuration: TimeInterval = 10.0 // How long potions stay on the map
    
    // Game over properties
    var restartButton: SKLabelNode!
    var mainMenuButton: SKLabelNode!
    var currentWave: Int = 1
    var remainingGoblins: Int = 10
    var waveLabel: SKLabelNode!
    var goblinCountLabel: SKLabelNode!
    
    var isSpawningEnabled = true
    var totalGoblinsSpawned = 0
    var maxGoblinsPerWave = 10
    
    // New variables for wave management
    var isInShop = false  // To track if the shop view is active
    var isGameOver = false
    
    override func didMove(to view: SKView) {
        // Initialize Player State and View
        playerState = PlayerState()
        playerView = PlayerView(scene: self, state: playerState)
        
        setupBackground()
        waveSetup()
        goblinCounterSetup()
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        // Initialize Goblin Manager with probabilities
        let goblinProbabilities: [GoblinManager.GoblinType: Double] = [
            .normal: 70.0,
            .large: 15.0,
            .small: 15.0
        ]
        goblinManager = GoblinManager(scene: self, probabilities: goblinProbabilities)
        
        // Start the first wave
        startWave()
    }
    
    func startWave() {
        // Reset wave variables
        self.maxGoblinsPerWave = 10 + (self.currentWave - 1) * 5
        self.remainingGoblins = self.maxGoblinsPerWave
        self.totalGoblinsSpawned = 0
        self.updateGoblinCounter()
        self.playerState.playerOneMana = self.playerState.maxMana
        self.playerState.playerTwoMana = self.playerState.maxMana
        
        // Start wave actionsp
        isSpawningEnabled = true
        
        // Start mana regeneration
        let regenerateMana = SKAction.run { [weak self] in
            self?.playerState.regenerateMana()
        }
        let wait = SKAction.wait(forDuration: 1.0)
        let regenSequence = SKAction.sequence([wait, regenerateMana])
        let repeatRegen = SKAction.repeatForever(regenSequence)
        self.run(repeatRegen, withKey: "regenerateMana")
        
        // Start mana potion spawning
        let spawnPotionAction = SKAction.sequence([
            SKAction.wait(forDuration: manaPotionSpawnInterval),
            SKAction.run { [weak self] in
                self?.spawnManaPotion()
            }
        ])
        let repeatPotionSpawn = SKAction.repeatForever(spawnPotionAction)
        self.run(repeatPotionSpawn, withKey: "spawnPotion")
        
        // Start goblin spawning
        let spawnGoblin = SKAction.run { [weak self] in
            guard let self = self else { return }
            let randomX = CGFloat.random(in: 0...self.size.width)
            let spawnPosition = CGPoint(x: randomX, y: self.size.height + 50)
            self.spawnGoblin(at: spawnPosition)
        }
        let waitForNextSpawn = SKAction.wait(forDuration: goblinSpawnInterval)
        let spawnSequence = SKAction.sequence([waitForNextSpawn, spawnGoblin])
        let repeatSpawnGoblin = SKAction.repeatForever(spawnSequence)
        self.run(repeatSpawnGoblin, withKey: "spawnGoblin")
    }
    
    func spawnGoblin(at position: CGPoint) {
        guard isSpawningEnabled, totalGoblinsSpawned < maxGoblinsPerWave, !isGameOver else {
            return
        }
        
        totalGoblinsSpawned += 1
        goblinManager.spawnGoblin(at: position)
    }
    
    func applySpell(_ spell: Spell, at position: CGPoint) {
        // Apply spell effects to goblins
        goblinManager.applySpell(spell, at: position, in: self)
        
        // Check for potion hits
        for potion in manaPotions {
            if position.distance(to: potion.position) <= spell.aoeRadius {
                handlePotionHit(potion: potion, spellLocation: position)
            }
        }
    }
    
    func gameOver() {
        // Stop all wave-related processes
        endWave()
        removeAllActions()
        isGameOver = true
        
        // Remove any remaining goblins and potions
        goblinManager.removeAllGoblins(in: self)
        
        for potion in manaPotions {
            potion.removeFromParent()
        }
        manaPotions.removeAll()
        
        // Rest of your game over logic...
    }
    
    func restartGame() {
        // Reset the game over flag
        isGameOver = false
        
        // Remove all nodes and reset the scene
        removeAllChildren()
        removeAllActions()
        
        // Reset properties
        playerState.reset()
        manaPotions.removeAll()
        
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
        
        waveSetup()
        goblinCounterSetup()
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        // Re-initialize Goblin Manager
        let goblinProbabilities: [GoblinManager.GoblinType: Double] = [
            .normal: 70.0,
            .large: 15.0,
            .small: 15.0
        ]
        goblinManager = GoblinManager(scene: self, probabilities: goblinProbabilities)
        
        // Start the first wave
        startWave()
    }
    
    // Rest of your GameScene code...
}
