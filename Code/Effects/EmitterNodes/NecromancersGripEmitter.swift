import SpriteKit

class NecromancersGripEmitter: SKNode {
    override init() {
        super.init()

        // Create skeletal hands
        let hand = SKSpriteNode(imageNamed: "skeletal_hand")
        hand.position = CGPoint.zero
        hand.zPosition = 5
        hand.setScale(0.1)
        addChild(hand)

        // Animate hands rising
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.5)
        hand.run(scaleUp)

        // Pulsate effect
        let pulseUp = SKAction.scale(to: 1.1, duration: 0.5)
        let pulseDown = SKAction.scale(to: 1.0, duration: 0.5)
        let pulseSequence = SKAction.sequence([pulseUp, pulseDown])
        hand.run(SKAction.repeatForever(pulseSequence))
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
} 