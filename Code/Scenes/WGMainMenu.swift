//
//  WGMainMenu.swift
//  WizardsandGoblins
//
//  Created by Kevin Sandke on 10/24/24.
//

import SpriteKit

class WGMainMenu: SKScene {
    
    override func didMove(to view: SKView) {
        // Set up background color
        backgroundColor = .blue
        
        // Add the button label
        let startButton = SKLabelNode(text: "Start Game")
        startButton.name = "startButton"  // Set a name for easy access
        startButton.fontSize = 40
        startButton.fontColor = .white
        startButton.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(startButton)
    }
    
    // Detect touches on the screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodesAtPoint = nodes(at: location)
        
        // Check if the start button was tapped
        for node in nodesAtPoint {
            if node.name == "startButton" {
                // Transition to the game scene
                if let gameScene = SKScene(fileNamed: "GameScene") {
                    gameScene.scaleMode = .aspectFill
                    view?.presentScene(gameScene, transition: SKTransition.flipHorizontal(withDuration: 1.0))
                }
            }
        }
    }
}
