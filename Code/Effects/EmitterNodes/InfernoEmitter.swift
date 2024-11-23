import SpriteKit

class InfernoEmitter: SKNode {
    init(at position: CGPoint) {
        super.init()
        self.position = position

        // Fire sparks
        let sparksEmitter = SKEmitterNode()
        sparksEmitter.particleBirthRate = 300
        sparksEmitter.particleLifetime = 2.0
        sparksEmitter.particleSpeed = 200
        sparksEmitter.particleSpeedRange = 100
        sparksEmitter.emissionAngle = -.pi / 2
        sparksEmitter.emissionAngleRange = .pi / 4
        sparksEmitter.particleAlpha = 0.8
        sparksEmitter.particleAlphaSpeed = -0.4
        sparksEmitter.particleScale = 0.5
        sparksEmitter.particleScaleRange = 0.3
        sparksEmitter.particleColorSequence = SKKeyframeSequence(keyframeValues: [SKColor.red, SKColor.orange, SKColor.yellow], times: [0, 0.5, 1])
        sparksEmitter.particleTexture = SKTexture(imageNamed: "spark")
        sparksEmitter.particlePositionRange = CGVector(dx: 100, dy: 0)
        addChild(sparksEmitter)

        // Smoke
        let smokeEmitter = SKEmitterNode()
        smokeEmitter.particleBirthRate = 100
        smokeEmitter.particleLifetime = 5.0
        smokeEmitter.particleSpeed = 50
        smokeEmitter.particleSpeedRange = 20
        smokeEmitter.emissionAngle = -.pi / 2
        smokeEmitter.emissionAngleRange = .pi / 8
        smokeEmitter.particleAlpha = 0.6
        smokeEmitter.particleAlphaSpeed = -0.1
        smokeEmitter.particleScale = 1.0
        smokeEmitter.particleScaleRange = 0.5
        smokeEmitter.particleScaleSpeed = 0.1
        smokeEmitter.particleColor = .gray
        smokeEmitter.particleTexture = createSmokeTexture()
        smokeEmitter.particlePositionRange = CGVector(dx: 100, dy: 0)
        addChild(smokeEmitter)

        // Flame pillars
        let flameEmitter = SKEmitterNode()
        flameEmitter.particleBirthRate = 50
        flameEmitter.particleLifetime = 1.0
        flameEmitter.particleSpeed = 150
        flameEmitter.particleSpeedRange = 50
        flameEmitter.emissionAngle = -.pi / 2
        flameEmitter.emissionAngleRange = 0
        flameEmitter.particleAlpha = 0.9
        flameEmitter.particleAlphaSpeed = -0.5
        flameEmitter.particleScale = 0.8
        flameEmitter.particleScaleRange = 0.3
        flameEmitter.particleColorSequence = SKKeyframeSequence(keyframeValues: [SKColor.yellow, SKColor.red], times: [0, 1])
        flameEmitter.particleTexture = createFlameTexture()
        flameEmitter.particlePositionRange = CGVector(dx: 50, dy: 0)
        addChild(flameEmitter)

        // Remove after duration
        run(SKAction.sequence([
            SKAction.wait(forDuration: 6.0),
            SKAction.fadeOut(withDuration: 1.0),
            SKAction.removeFromParent()
        ]))
    }

    private func createSmokeTexture() -> SKTexture {
        let size = CGSize(width: 40, height: 40)
        UIGraphicsBeginImageContext(size)
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(UIColor.darkGray.cgColor)
            context.fill(CGRect(origin: .zero, size: size))
        }
        let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return SKTexture(image: image)
    }

    private func createFlameTexture() -> SKTexture {
        let size = CGSize(width: 20, height: 40)
        UIGraphicsBeginImageContext(size)
        if let context = UIGraphicsGetCurrentContext() {
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                      colors: [UIColor.yellow.cgColor, UIColor.red.cgColor] as CFArray,
                                      locations: [0, 1])!
            context.drawLinearGradient(gradient,
                                       start: CGPoint(x: size.width / 2, y: size.height),
                                       end: CGPoint(x: size.width / 2, y: 0),
                                       options: [])
        }
        let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return SKTexture(image: image)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
} 