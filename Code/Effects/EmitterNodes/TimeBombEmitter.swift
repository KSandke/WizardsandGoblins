import Foundation
import SpriteKit

class TimeBombEmitter: SKNode {
    override init() {
        super.init()
        
        // Create bomb body
        let bombBody = SKSpriteNode(color: .brown, size: CGSize(width: 20, height: 20))
        bombBody.position = CGPoint(x: 0, y: 0)
        addChild(bombBody)

        // Add clock hands
        let clockHand = SKShapeNode(rect: CGRect(x: -1, y: 0, width: 2, height: 8))
        clockHand.fillColor = .black
        clockHand.position = CGPoint(x: 0, y: 0)
        clockHand.zPosition = 1
        bombBody.addChild(clockHand)

        // Rotate clock hand
        let rotateAction = SKAction.rotate(byAngle: -.pi * 2, duration: 1.0)
        clockHand.run(SKAction.repeatForever(rotateAction))

        // Ticking animation
        let tickAction = SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.1),
            SKAction.scale(to: 1.0, duration: 0.1),
            SKAction.wait(forDuration: 0.8)
        ])
        bombBody.run(SKAction.repeatForever(tickAction))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
} 