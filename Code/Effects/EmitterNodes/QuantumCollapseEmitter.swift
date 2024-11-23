import Foundation
import SpriteKit

class QuantumCollapseEmitter: SKEmitterNode {
    init() {
        super.init()

        particleBirthRate = 200
        particleLifetime = 0.5
        particleLifetimeRange = 0.2

        particlePositionRange = CGVector(dx: 40, dy: 40)
        emissionAngleRange = .pi * 2
        particleSpeed = 100
        particleSpeedRange = 50

        particleScale = 0.3
        particleScaleRange = 0.1
        particleScaleSpeed = -0.2

        particleAlpha = 0.8
        particleAlphaRange = 0.2
        particleAlphaSpeed = -1.0

        particleColor = .magenta
        particleBlendMode = .add

        particleTexture = createQuantumParticleTexture()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private func createQuantumParticleTexture() -> SKTexture {
        let size = CGSize(width: 8, height: 8)
        UIGraphicsBeginImageContext(size)
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(UIColor.magenta.cgColor)
            context.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return SKTexture(image: image ?? UIImage())
    }
} 