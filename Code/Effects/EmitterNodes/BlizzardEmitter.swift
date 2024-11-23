import SpriteKit

class BlizzardEmitter: SKNode {
    init(at position: CGPoint) {
        super.init()
        self.position = position

        // Snowfall
        let snowEmitter = SKEmitterNode()
        snowEmitter.particleBirthRate = 200
        snowEmitter.particleLifetime = 5.0
        snowEmitter.particleSpeed = 100
        snowEmitter.particleSpeedRange = 50
        snowEmitter.emissionAngle = .pi / 2
        snowEmitter.emissionAngleRange = .pi / 8
        snowEmitter.particleAlpha = 0.8
        snowEmitter.particleAlphaSpeed = -0.2
        snowEmitter.particleScale = 0.5
        snowEmitter.particleScaleRange = 0.3
        snowEmitter.particleColor = .white
        snowEmitter.particleTexture = SKTexture(imageNamed: "snowflake")
        snowEmitter.particlePositionRange = CGVector(dx: 800, dy: 0)
        addChild(snowEmitter)

        // Wind effect
        let windEmitter = SKEmitterNode()
        windEmitter.particleBirthRate = 100
        windEmitter.particleLifetime = 2.0
        windEmitter.particleSpeed = 200
        windEmitter.particleSpeedRange = 50
        windEmitter.emissionAngle = .pi
        windEmitter.emissionAngleRange = .pi / 8
        windEmitter.particleAlpha = 0.5
        windEmitter.particleAlphaSpeed = -0.1
        windEmitter.particleScale = 0.7
        windEmitter.particleScaleRange = 0.2
        windEmitter.particleColor = SKColor(white: 1.0, alpha: 0.2)
        windEmitter.particleTexture = createWindTexture()
        windEmitter.particlePositionRange = CGVector(dx: 0, dy: 600)
        addChild(windEmitter)

        // Remove after duration
        run(SKAction.sequence([
            SKAction.wait(forDuration: 8.0),
            SKAction.fadeOut(withDuration: 1.0),
            SKAction.removeFromParent()
        ]))
    }

    private func createWindTexture() -> SKTexture {
        let size = CGSize(width: 100, height: 10)
        UIGraphicsBeginImageContext(size)
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(UIColor.white.cgColor)
            context.fill(CGRect(origin: .zero, size: size))
        }
        let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return SKTexture(image: image)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
} 