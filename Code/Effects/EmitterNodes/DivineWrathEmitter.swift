import SpriteKit

class DivineWrathEmitter: SKNode {
    init(position: CGPoint) {
        super.init()
        self.position = position

        // Darken background
        let darken = SKSpriteNode(color: UIColor.black.withAlphaComponent(0.7), size: CGSize(width: 2000, height: 2000))
        darken.position = CGPoint.zero
        darken.zPosition = -1
        addChild(darken)

        // Create multiple lightning bolts
        for _ in 0...3 {
            let bolt = createLightningBolt(from: CGPoint(x: CGFloat.random(in: -200...200), y: 500), to: CGPoint.zero)
            addChild(bolt)
        }

        // Flash effect
        let flash = SKSpriteNode(color: .white, size: CGSize(width: 500, height: 500))
        flash.alpha = 0.8
        flash.position = CGPoint.zero
        flash.zPosition = 5
        addChild(flash)

        // Sparks at impact point
        let sparks = SKEmitterNode()
        sparks.position = CGPoint.zero
        sparks.particleBirthRate = 500
        sparks.particleLifetime = 0.5
        sparks.particleSpeed = 200
        sparks.emissionAngleRange = .pi * 2
        sparks.particleScale = 0.2
        sparks.particleColor = .yellow
        sparks.particleTexture = SKTexture(imageNamed: "spark")
        sparks.particleBlendMode = .add
        addChild(sparks)

        // Fade out effects
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        darken.run(fadeOut)
        flash.run(fadeOut)
        sparks.run(SKAction.sequence([fadeOut, .removeFromParent()]))

        // Remove node after effects
        run(SKAction.sequence([SKAction.wait(forDuration: 1.0), .removeFromParent()]))
    }

    private func createLightningBolt(from startPoint: CGPoint, to endPoint: CGPoint) -> SKShapeNode {
        let bolt = SKShapeNode()
        let path = CGMutablePath()
        path.move(to: startPoint)

        let numPoints = Int(arc4random_uniform(8) + 8)
        var prevPoint = startPoint

        for _ in 0...numPoints {
            let randomX = CGFloat(arc4random_uniform(40)) - 20
            let randomY = CGFloat(arc4random_uniform(40)) - 20
            let newPoint = CGPoint(x: ((prevPoint.x + endPoint.x) / 2) + randomX, y: ((prevPoint.y + endPoint.y) / 2) + randomY)
            path.addLine(to: newPoint)
            prevPoint = newPoint
        }

        path.addLine(to: endPoint)
        bolt.path = path
        bolt.strokeColor = .white
        bolt.lineWidth = 3
        bolt.glowWidth = 5
        bolt.zPosition = 10

        // Flicker animation
        let fadeOutIn = SKAction.sequence([.fadeOut(withDuration: 0.1), .fadeIn(withDuration: 0.1)])
        bolt.run(SKAction.repeat(fadeOutIn, count: 3), completion: { bolt.removeFromParent() })

        return bolt
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
} 