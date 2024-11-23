import Foundation
import SpriteKit

class CyberneticOverloadEmitter: SKEmitterNode {
    init(at position: CGPoint) {
        super.init()
        self.position = position
        
        particleBirthRate = 200
        particleLifetime = 0.5
        particleLifetimeRange = 0.2
        
        particlePositionRange = CGVector(dx: 20, dy: 20)
        emissionAngleRange = CGFloat.pi * 2
        particleSpeed = 100
        particleSpeedRange = 50
        particleAlpha = 0.8
        particleAlphaRange = 0.2
        particleScale = 0.5
        particleScaleRange = 0.2
        particleColor = SKColor.cyan
        particleBlendMode = .add

        // Create particle texture programmatically
        particleTexture = createSparkTexture()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func createSparkTexture() -> SKTexture {
        let size = CGSize(width: 8, height: 8)
        UIGraphicsBeginImageContext(size)
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(UIColor.white.cgColor)
            context.fillEllipse(in: CGRect(x: 0, y: 0, width: 8, height: 8))
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return SKTexture(image: image ?? UIImage())
    }
} 