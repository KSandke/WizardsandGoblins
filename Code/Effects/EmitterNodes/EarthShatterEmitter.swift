import SpriteKit

class EarthShatterEmitter: SKEmitterNode {
    init(at position: CGPoint) {
        super.init()
        self.position = position

        particleBirthRate = 80
        particleLifetime = 1.0
        particleLifetimeRange = 0.3

        particlePositionRange = CGVector(dx: 50, dy: 10)
        emissionAngle = .pi / 2
        emissionAngleRange = .pi / 4
        particleSpeed = 100
        particleSpeedRange = 30

        particleScale = 0.5
        particleScaleRange = 0.2
        particleScaleSpeed = -0.2

        particleAlpha = 0.8
        particleAlphaRange = 0.2
        particleAlphaSpeed = -0.4

        particleColor = .brown
        particleBlendMode = .alpha

        particleTexture = createParticleTexture()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private func createParticleTexture() -> SKTexture {
        let size = CGSize(width: 8, height: 8)
        UIGraphicsBeginImageContext(size)
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(UIColor.brown.cgColor)
            context.fill(CGRect(origin: .zero, size: size))
        }
        let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return SKTexture(image: image)
    }
} 