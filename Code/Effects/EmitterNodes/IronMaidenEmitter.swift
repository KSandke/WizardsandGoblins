import Foundation
import SpriteKit

class IronMaidenEmitter: SKNode {
    init(goblin: Goblin.GoblinContainer) {
        super.init()
        
        // Create Iron Maiden body
        let body = SKSpriteNode(color: .darkGray, size: CGSize(width: 50, height: 100))
        body.anchorPoint = CGPoint(x: 0.5, y: 0)
        body.position = CGPoint(x: 0, y: 0)
        addChild(body)

        // Create front door with spikes
        let door = SKSpriteNode(color: .darkGray, size: CGSize(width: 50, height: 100))
        door.anchorPoint = CGPoint(x: 0, y: 0)
        door.position = CGPoint(x: -25, y: 0)
        addChild(door)

        // Add spikes to the door
        let spikeCount = 10
        for i in 0..<spikeCount {
            let spike = SKShapeNode()
            let path = CGMutablePath()
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 5, y: 10))
            path.addLine(to: CGPoint(x: 10, y: 0))
            spike.path = path
            spike.fillColor = .red
            spike.position = CGPoint(x: CGFloat(i) * 5, y: CGFloat(i) * 8 + 10)
            door.addChild(spike)
        }

        // Close the Iron Maiden
        let closeAction = SKAction.moveBy(x: 50, y: 0, duration: 0.5)
        door.run(closeAction)

        // Add goblin inside
        goblin.sprite.position = CGPoint(x: 0, y: 0)
        addChild(goblin.sprite)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
} 