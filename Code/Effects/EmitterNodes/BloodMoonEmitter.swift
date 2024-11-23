import SpriteKit

class BloodMoonEmitter: SKEmitterNode {
    init(at position: CGPoint) {
        super.init()
        self.position = position

        particleBirthRate = 100
        particleLifetime = 1.0
        particleLifetimeRange = 0.5

        particlePositionRange = CGVector(dx: 100, dy: 100)
        emissionAngleRange = .pi * 2
        particleSpeed = 50
        particleSpeedRange = 25

        particleScale = 0.6
        particleScaleRange = 0.3
        particleScaleSpeed = -0.3

        particleAlpha = 0.9
        particleAlphaRange = 0.1
        particleAlphaSpeed = -0.5

        particleColor = .red
        particleBlendMode = .add

        particleTexture = createParticleTexture()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private func createParticleTexture() -> SKTexture {
        let size = CGSize(width: 10, height: 10)
        UIGraphicsBeginImageContext(size)
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(UIColor.red.cgColor)
            context.fillEllipse(in: CGRect(origin: .zero, size: size))
        }
        let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return SKTexture(image: image)
    }
} 