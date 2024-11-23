import SpriteKit

class MysticBarrierEmitter: SKNode {
    init(at position: CGPoint, radius: CGFloat) {
        super.init()
        self.position = position

        // Concentric magic circles
        for i in 1...3 {
            let circle = SKShapeNode(circleOfRadius: radius * CGFloat(i) / 3)
            circle.strokeColor = SKColor(hue: 0.8, saturation: 1.0, brightness: 1.0, alpha: 1.0)
            circle.lineWidth = 3
            circle.glowWidth = 10
            circle.zPosition = CGFloat(i)
            addChild(circle)

            // Rotating animation
            let rotation = SKAction.rotate(byAngle: (i % 2 == 0 ? 1 : -1) * .pi * 2, duration: 6.0)
            circle.run(SKAction.repeatForever(rotation))
        }

        // Floating runes
        let runes = SKEmitterNode()
        runes.particleBirthRate = 30
        runes.particleLifetime = 4.0
        runes.particlePositionRange = CGVector(dx: radius * 2, dy: radius * 2)
        runes.emissionAngleRange = .pi * 2
        runes.particleSpeed = 20
        runes.particleSpeedRange = 10
        runes.particleAlpha = 0.8
        runes.particleAlphaSpeed = -0.2
        runes.particleScale = 0.5
        runes.particleScaleRange = 0.2
        runes.particleColor = .purple
        runes.particleTexture = createRuneTexture()
        runes.zPosition = 0
        addChild(runes)

        // Remove after duration
        run(SKAction.sequence([
            SKAction.wait(forDuration: 8.0),
            SKAction.fadeOut(withDuration: 1.0),
            .removeFromParent()
        ]))
    }

    private func createRuneTexture() -> SKTexture {
        let size = CGSize(width: 20, height: 20)
        UIGraphicsBeginImageContext(size)
        UIColor.white.setStroke()
        let path = UIBezierPath()
        path.move(to: CGPoint(x: size.width / 2, y: 0))
        path.addLine(to: CGPoint(x: size.width, y: size.height))
        path.addLine(to: CGPoint(x: 0, y: size.height))
        path.close()
        path.lineWidth = 2
        path.stroke()
        let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        return SKTexture(image: image)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
} 