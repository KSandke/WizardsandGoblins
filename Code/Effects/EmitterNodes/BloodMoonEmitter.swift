import SpriteKit

class BloodMoonEmitter: SKNode {
    init(at position: CGPoint) {
        super.init()
        self.position = position

        // large, ominous blood moon
        let moon = SKShapeNode(circleOfRadius: 150)
        moon.fillColor = .red
        moon.strokeColor = .darkGray
        moon.lineWidth = 5
        moon.zPosition = -1
        moon.alpha = 0
        addChild(moon)

        let appear = SKAction.fadeIn(withDuration: 1.0)
        moon.run(appear)

        // eerie mist
        let mist = SKEmitterNode()
        mist.particleBirthRate = 80
        mist.particleLifetime = 4.0
        mist.particlePositionRange = CGVector(dx: 400, dy: 200)
        mist.emissionAngle = .pi / 2
        mist.emissionAngleRange = .pi / 4
        mist.particleSpeed = 20
        mist.particleAlpha = 0.5
        mist.particleAlphaSpeed = -0.1
        mist.particleScale = 1.0
        mist.particleScaleRange = 0.5
        mist.particleColor = .red
        mist.particleTexture = createMistTexture()
        mist.zPosition = -2
        addChild(mist)

        // dripping blood
        let blood = SKEmitterNode()
        blood.particleBirthRate = 60
        blood.particleLifetime = 2.0
        blood.particlePositionRange = CGVector(dx: 300, dy: 0)
        blood.emissionAngle = -.pi / 2
        blood.emissionAngleRange = .pi / 8
        blood.particleSpeed = 150
        blood.particleAlpha = 0.9
        blood.particleAlphaSpeed = -0.4
        blood.particleScale = 0.7
        blood.particleScaleRange = 0.3
        blood.particleColor = .red
        blood.particleTexture = createDropletTexture()
        addChild(blood)

        // Remove after duration
        run(SKAction.sequence([
            SKAction.wait(forDuration: 5.0),
            SKAction.fadeOut(withDuration: 1.0),
            .removeFromParent()
        ]))
    }

    private func createMistTexture() -> SKTexture {
        let size = CGSize(width: 50, height: 50)
        UIGraphicsBeginImageContext(size)
        UIColor.red.withAlphaComponent(0.5).setFill()
        UIBezierPath(ovalIn: CGRect(origin: .zero, size: size)).fill()
        let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        return SKTexture(image: image)
    }

    private func createDropletTexture() -> SKTexture {
        let size = CGSize(width: 6, height: 12)
        UIGraphicsBeginImageContext(size)
        UIColor.red.setFill()
        let path = UIBezierPath()

        path.move(to: CGPoint(x: size.width / 2, y: 0))
        path.addCurve(to: CGPoint(x: 0, y: size.height),
                      controlPoint1: CGPoint(x: size.width * 0.1, y: size.height * 0.3),
                      controlPoint2: CGPoint(x: 0, y: size.height * 0.6))
        path.addCurve(to: CGPoint(x: size.width, y: size.height),
                      controlPoint1: CGPoint(x: size.width, y: size.height * 0.6),
                      controlPoint2: CGPoint(x: size.width * 0.9, y: size.height * 0.3))
        path.close()
        path.fill()

        let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        return SKTexture(image: image)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
} 