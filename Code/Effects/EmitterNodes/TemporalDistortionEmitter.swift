import Foundation
import SpriteKit

class TemporalDistortionEmitter: SKEmitterNode {
    override init() {
        super.init()

        particleBirthRate = 50
        particleLifetime = 1.0
        particleLifetimeRange = 0.5

        particlePositionRange = CGVector(dx: 20, dy: 20)
        emissionAngleRange = .pi * 2
        particleSpeed = 30
        particleSpeedRange = 15

        particleScale = 0.5
        particleScaleRange = 0.2
        particleScaleSpeed = -0.2

        particleAlpha = 0.8
        particleAlphaRange = 0.2
        particleAlphaSpeed = -0.5

        particleColor = .purple
        particleBlendMode = .add

        particleTexture = createTimeParticleTexture()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private func createTimeParticleTexture() -> SKTexture {
        let size = CGSize(width: 10, height: 10)
        UIGraphicsBeginImageContext(size)
        if let context = UIGraphicsGetCurrentContext() {
            context.setStrokeColor(UIColor.purple.cgColor)
            context.setLineWidth(2)
            context.strokeEllipse(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return SKTexture(image: image ?? UIImage())
    }
} 
