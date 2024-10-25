//
//  WGGameScene.swift
//  WizardsandGoblins
//
//  Created by Kevin Sandke on 10/24/24.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var player: SKSpriteNode!
    override func didMove(to view: SKView) {
        backgroundColor = .green // Background color for the game
        
        // Game content
        player = SKSpriteNode(imageNamed: "Wizard1.png")
        player.position = CGPoint(x: size.width/2, y: 50)
        addChild(player)
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let touchLocation = touch.location(in: self)
        
        let spell = SKSpriteNode(imageNamed: "Spell.png")
        spell.position = touchLocation
        addChild(spell)
        
        
        
        let dx = touchLocation.x - player.position.x
        let dy = touchLocation.y - player.position.y
        let direction = CGVector(dx: dx, dy: dy).normalized()
        
        let distance: CGFloat = 1000.0
        let moveAction = SKAction.move(by: CGVector(dx: direction.dx * distance, dy: direction.dy * distance), duration: 1.0)
        
        spell.run(SKAction.sequence([moveAction, SKAction.removeFromParent()]))
    }
}
extension CGVector{
    func normalized() -> CGVector {
        let length = sqrt(dx * dx + dy * dy)
        return length > 0 ? CGVector(dx: dx / length, dy: dy / length) : .zero
    }
}
