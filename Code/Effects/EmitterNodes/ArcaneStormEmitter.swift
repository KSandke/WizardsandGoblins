import SpriteKit

class ArcaneStormEmitter: SKEmitterNode {
    init(position: CGPoint, radius: CGFloat) {
        super.init()
        self.position = position

        particleBirthRate = 100
        particleLifetime = 1.0
        particleLifetimeRange = 0.5

        particlePositionRange = CGVector(dx: radius, dy: radius)
        emissionAngleRange = .pi * 2
        particleSpeed = 50
        particleSpeedRange = 20

        particleScale = 0.5
        particleScaleRange = 0.2
        particleScaleSpeed = -0.2

        particleAlpha = 0.8
        particleAlphaRange = 0.2
        particleAlphaSpeed = -0.5

        particleColor = SKColor.cyan
        particleBlendMode = .add

        particleTexture = createParticleTexture()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private func createParticleTexture() -> SKTexture {
        let size = CGSize(width: 8, height: 8)
        UIGraphicsBeginImageContext(size)
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(UIColor.cyan.cgColor)
            context.fillEllipse(in: CGRect(origin: .zero, size: size))
        }
        let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return SKTexture(image: image)
    }
} 