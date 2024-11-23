import SpriteKit

class MysticBarrierEmitter: SKShapeNode {
    init(at position: CGPoint, radius: CGFloat) {
        super.init()
        self.position = position

        // Create a circular path
        let path = CGMutablePath()
        path.addArc(center: CGPoint.zero, radius: radius, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
        self.path = path
        self.strokeColor = SKColor.purple
        self.lineWidth = 5
        self.glowWidth = 10

        // Animate the barrier
        let fadeIn = SKAction.fadeAlpha(to: 0.8, duration: 0.5)
        let fadeOut = SKAction.fadeAlpha(to: 0.4, duration: 0.5)
        let pulse = SKAction.sequence([fadeIn, fadeOut])
        self.run(SKAction.repeatForever(pulse))
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
} 