import SpriteKit

class ArcaneStormEmitter: SKNode {
    init(position: CGPoint, radius: CGFloat) {
        super.init()
        self.position = position

        // Rotating arcane circles
        for i in 1...3 {
            let circle = SKShapeNode(circleOfRadius: radius * CGFloat(i) / 3)
            circle.strokeColor = SKColor(hue: 0.6, saturation: 1.0, brightness: 1.0, alpha: 1.0)
            circle.lineWidth = 2
            circle.zPosition = CGFloat(i)
            let rotateAction = SKAction.rotate(byAngle: .pi * 2, duration: 5.0 / CGFloat(i))
            circle.run(SKAction.repeatForever(rotateAction))
            addChild(circle)
        }

        // Arcane particles
        let particles = SKEmitterNode()
        particles.particleBirthRate = 300
        particles.particleLifetime = 1.5
        particles.particlePositionRange = CGVector(dx: radius * 2, dy: radius * 2)
        particles.emissionAngleRange = .pi * 2
        particles.particleSpeed = 150
        particles.particleSpeedRange = 50
        particles.particleScale = 0.6
        particles.particleScaleRange = 0.3
        particles.particleAlpha = 0.9
        particles.particleAlphaSpeed = -0.6
        particles.particleColorSequence = SKKeyframeSequence(keyframeValues: [SKColor.magenta, SKColor.cyan], times: [0, 1])
        particles.particleBlendMode = .add
        particles.particleTexture = createParticleTexture()
        addChild(particles)

        // Random lightning strikes
        run(SKAction.repeatForever(SKAction.sequence([
            SKAction.wait(forDuration: 0.5),
            SKAction.run {
                let lightning = self.createLightning(at: self.randomPoint(in: radius))
                self.addChild(lightning)
            }
        ])))
    }

    private func randomPoint(in radius: CGFloat) -> CGPoint {
        let angle = CGFloat.random(in: 0...(.pi * 2))
        let r = CGFloat.random(in: 0...radius)
        return CGPoint(x: r * cos(angle), y: r * sin(angle))
    }

    private func createLightning(at position: CGPoint) -> SKShapeNode {
        let startPoint = CGPoint(x: position.x, y: position.y + 100)
        let endPoint = position
        let bolt = SKShapeNode()
        let path = CGMutablePath()
        path.move(to: startPoint)

        let numSegments = Int.random(in: 5...10)
        var prevPoint = startPoint
        for _ in 0..<numSegments {
            let randomX = CGFloat.random(in: -15...15)
            let randomY = CGFloat.random(in: -15...15)
            let newPoint = CGPoint(
                x: prevPoint.x + (endPoint.x - startPoint.x) / CGFloat(numSegments) + randomX,
                y: prevPoint.y + (endPoint.y - startPoint.y) / CGFloat(numSegments) + randomY
            )
            path.addLine(to: newPoint)
            prevPoint = newPoint
        }

        bolt.path = path
        bolt.strokeColor = .cyan
        bolt.lineWidth = 2
        bolt.glowWidth = 3
        bolt.zPosition = 4

        bolt.run(SKAction.sequence([.fadeOut(withDuration: 0.3), .removeFromParent()]))

        return bolt
    }

    private func createParticleTexture() -> SKTexture {
        let size = CGSize(width: 12, height: 12)
        UIGraphicsBeginImageContext(size)
        UIColor.white.setFill()
        UIBezierPath(ovalIn: CGRect(origin: .zero, size: size)).fill()
        let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return SKTexture(image: image)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
} 