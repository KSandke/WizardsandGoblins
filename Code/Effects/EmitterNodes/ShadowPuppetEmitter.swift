import Foundation
import SpriteKit

class ShadowPuppetEmitter: SKEmitterNode {
    init(at position: CGPoint) {
        super.init()
        self.position = position

        particleBirthRate = 80
        particleLifetime = 1.0
        particleLifetimeRange = 0.5

        particlePositionRange = CGVector(dx: 30, dy: 30)
        emissionAngleRange = .pi * 2
        particleSpeed = 50
        particleSpeedRange = 20

        particleScale = 0.5
        particleScaleRange = 0.2
        particleScaleSpeed = -0.3

        particleAlpha = 0.7
        particleAlphaRange = 0.2
        particleAlphaSpeed = -0.5

        particleColor = .black
        particleBlendMode = .alpha

        particleTexture = createSmokeTexture()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private func createSmokeTexture() -> SKTexture {
        let size = CGSize(width: 10, height: 10)
        UIGraphicsBeginImageContext(size)
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(UIColor.black.cgColor)
            context.fillEllipse(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return SKTexture(image: image ?? UIImage())
    }
} 