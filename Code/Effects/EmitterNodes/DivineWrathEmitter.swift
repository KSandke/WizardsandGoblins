import SpriteKit

class DivineWrathEmitter: SKNode {
    init(position: CGPoint) {
        super.init()
        self.position = position

        // Create lightning bolt
        let bolt = SKShapeNode()
        let path = CGMutablePath()
        path.move(to: CGPoint.zero)
        path.addLine(to: CGPoint(x: 0, y: -200))
        bolt.path = path
        bolt.strokeColor = SKColor.white
        bolt.lineWidth = 3
        bolt.glowWidth = 5
        bolt.zPosition = 10
        addChild(bolt)

        // Flash effect
        let flash = SKSpriteNode(color: .white, size: CGSize(width: 200, height: 200))
        flash.alpha = 0.8
        flash.position = CGPoint(x: 0, y: -100)
        flash.zPosition = 9
        addChild(flash)

        // Fade out effects
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        bolt.run(fadeOut)
        flash.run(fadeOut)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
} 