import SpriteKit

class NecromancersGripEmitter: SKNode {
    override init() {
        super.init()

        // Create skeletal hand programmatically
        let hand = SKShapeNode()
        let path = CGMutablePath()

        // Palm
        let palmWidth: CGFloat = 30
        let palmHeight: CGFloat = 40
        path.addRect(CGRect(x: -palmWidth / 2, y: 0, width: palmWidth, height: palmHeight))

        // Fingers
        let fingerLength: CGFloat = 30
        let fingerWidth: CGFloat = 4
        let fingerSpacing: CGFloat = 12

        for i in -2...2 {
            let x = CGFloat(i) * fingerSpacing
            path.addRect(CGRect(x: x - fingerWidth / 2, y: palmHeight, width: fingerWidth, height: fingerLength))
        }

        hand.path = path
        hand.fillColor = .gray
        hand.strokeColor = .white
        hand.lineWidth = 1.0
        hand.position = CGPoint.zero
        hand.zPosition = 5
        hand.setScale(0.1)
        addChild(hand)

        // Animate hand rising
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.5)
        hand.run(scaleUp)

        // Pulsate effect
        let pulseUp = SKAction.scale(to: 1.05, duration: 0.5)
        let pulseDown = SKAction.scale(to: 1.0, duration: 0.5)
        let pulseSequence = SKAction.sequence([pulseUp, pulseDown])
        hand.run(SKAction.repeatForever(pulseSequence))
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
} 