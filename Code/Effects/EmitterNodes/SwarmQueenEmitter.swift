import Foundation
import SpriteKit

class SwarmQueenEmitter: SKEmitterNode {
    init(at position: CGPoint) {
        super.init()
        self.position = position
        
        particleBirthRate = 60
        numParticlesToEmit = 20
        particleLifetime = 2.0
        particleLifetimeRange = 0.5
        
        particlePositionRange = CGVector(dx: 50, dy: 50)
        emissionAngle = 0
        emissionAngleRange = .pi * 2
        particleSpeed = 80
        particleSpeedRange = 30
        
        particleScale = 0.3
        particleScaleRange = 0.1
        particleRotation = 0
        particleRotationRange = .pi * 2
        
        let colors: [SKColor] = [
            .yellow,
            SKColor(red: 1, green: 0.8, blue: 0, alpha: 0.8),
            SKColor.clear
        ]
        particleColorSequence = SKKeyframeSequence(
            keyframeValues: colors,
            times: [0, 0.5, 1.0]
        )
        
        particleTexture = createSwarmlingTexture()
        particleBlendMode = .add
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createSwarmlingTexture() -> SKTexture {
        let size = CGSize(width: 10, height: 10)
        UIGraphicsBeginImageContext(size)
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(UIColor.yellow.cgColor)
            context.fill(CGRect(x: 0, y: 0, width: 10, height: 10))
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return SKTexture(image: image ?? UIImage())
    }
} 