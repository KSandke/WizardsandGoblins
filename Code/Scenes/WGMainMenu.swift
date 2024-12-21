//
//  WGMainMenu.swift
//  WizardsandGoblins
//
//  Created by Kevin Sandke on 10/24/24.
//

import SpriteKit

class WGMainMenu: SKScene {
    // UI Elements
    private var startButton: SKShapeNode!
    private var titleLabel: SKLabelNode!
    private var background: SKSpriteNode!
    private var wizard: SKSpriteNode!
    
    override func didMove(to view: SKView) {
        setupBackground()
        setupTitle()
        setupButtons()
        setupWizard()
        addAnimations()
    }
    
    private func setupBackground() {
        // Add the game's background image
        background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.size = self.size
        background.zPosition = -1
        addChild(background)
        
        // Add a semi-transparent overlay for better text visibility
        let overlay = SKSpriteNode(color: .black, size: self.size)
        overlay.alpha = 0.3
        overlay.position = CGPoint(x: size.width/2, y: size.height/2)
        overlay.zPosition = 0
        addChild(overlay)
    }
    
    private func setupTitle() {
        titleLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        titleLabel.text = "Wizards & Goblins"
        titleLabel.fontSize = 48
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: size.width/2, y: size.height * 0.7)
        titleLabel.zPosition = 1
        
        // Add shadow effect
        let shadow = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        shadow.text = titleLabel.text
        shadow.fontSize = titleLabel.fontSize
        shadow.fontColor = .black
        shadow.position = CGPoint(x: 2, y: -2)
        shadow.zPosition = -1
        titleLabel.addChild(shadow)
        
        addChild(titleLabel)
    }
    
    private func setupButtons() {
        // Start Button
        startButton = SKShapeNode(rectOf: CGSize(width: 200, height: 60), cornerRadius: 10)
        startButton.fillColor = .blue
        startButton.strokeColor = .white
        startButton.position = CGPoint(x: size.width/2, y: size.height * 0.4)
        startButton.zPosition = 1
        startButton.name = "startButton"
        
        let startLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        startLabel.text = "Start Game"
        startLabel.fontSize = 30
        startLabel.fontColor = .white
        startLabel.verticalAlignmentMode = .center
        startLabel.zPosition = 1
        startButton.addChild(startLabel)
        
        // Add glow effect
        let glow = SKShapeNode(rectOf: CGSize(width: 210, height: 70), cornerRadius: 12)
        glow.strokeColor = .white
        glow.alpha = 0.5
        glow.zPosition = 0
        startButton.addChild(glow)
        
        addChild(startButton)
    }
    
    private func setupWizard() {
        wizard = SKSpriteNode(imageNamed: "Wizard")
        wizard.setScale(1.5)
        wizard.position = CGPoint(x: size.width/2, y: size.height * 0.25)
        wizard.zPosition = 1
        addChild(wizard)
    }
    
    private func addAnimations() {
        // Title floating animation
        let moveUp = SKAction.moveBy(x: 0, y: 10, duration: 1.0)
        let moveDown = moveUp.reversed()
        let sequence = SKAction.sequence([moveUp, moveDown])
        titleLabel.run(SKAction.repeatForever(sequence))
        
        // Button pulse animation
        let scaleUp = SKAction.scale(to: 1.1, duration: 0.5)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.5)
        let buttonSequence = SKAction.sequence([scaleUp, scaleDown])
        startButton.run(SKAction.repeatForever(buttonSequence))
        
        // Wizard idle animation
        let wizardFloat = SKAction.moveBy(x: 0, y: 5, duration: 1.2)
        let wizardSink = wizardFloat.reversed()
        let wizardSequence = SKAction.sequence([wizardFloat, wizardSink])
        wizard.run(SKAction.repeatForever(wizardSequence))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodesAtPoint = nodes(at: location)
        
        for node in nodesAtPoint {
            if node.name == "startButton" {
                // Play button press sound
                SoundManager.shared.playSound("button_press")
                
                // Animate button press
                startButton.run(SKAction.sequence([
                    SKAction.scale(to: 0.9, duration: 0.1),
                    SKAction.scale(to: 1.0, duration: 0.1),
                    SKAction.run { [weak self] in
                        self?.startGame()
                    }
                ]))
            }
        }
    }
    
    private func startGame() {
        // Create a fresh GameScene
        let gameScene = GameScene(size: self.size)
        gameScene.scaleMode = .aspectFill
        
        // Present the new scene with a transition
        let transition = SKTransition.doorway(withDuration: 1.0)
        view?.presentScene(gameScene, transition: transition)
    }
}
