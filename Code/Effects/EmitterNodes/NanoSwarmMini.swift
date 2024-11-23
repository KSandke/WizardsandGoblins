import Foundation
import SpriteKit

class NanoSwarmMiniEmitter: SKEmitterNode {
    init(at position: CGPoint) {
        super.init()
        self.position = position
        
        // Base configuration
        particleBirthRate = 50
        numParticlesToEmit = 100
        particleLifetime = 1.5
        particleLifetimeRange = 0.3
        
        // Movement
        particlePositionRange = CGVector(dx: 20, dy: 20)
        emissionAngle = 0
        emissionAngleRange = .pi * 2
        particleSpeed = 30
        particleSpeedRange = 10
        
        // Appearance
        particleScale = 0.1
        particleScaleRange = 0.05
        particleRotation = 0
        particleRotationRange = .pi * 2
        particleRotationSpeed = 1.5
        
        // Color and blend
        let colors: [SKColor] = [
            SKColor(red: 0, green: 1, blue: 0.8, alpha: 0.6),
            SKColor(red: 0, green: 0.8, blue: 1, alpha: 0.4),
            SKColor.clear
        ]
        particleColorSequence = SKKeyframeSequence(
            keyframeValues: colors,
            times: [0, 0.5, 1.0]
        )
        
        particleTexture = createMiniNaniteTexture()
        particleBlendMode = .add
        
        // Add glow effect
        addChild(createGlowEffect())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createGlowEffect() -> SKEmitterNode {
        let glow = SKEmitterNode()
        
        glow.particleBirthRate = 30
        glow.particleLifetime = 0.3
        glow.particlePositionRange = CGVector(dx: 15, dy: 15)
        glow.particleScale = 0.2
        glow.particleAlpha = 0.3
        glow.particleAlphaSpeed = -1.0
        glow.particleColor = SKColor(red: 0, green: 1, blue: 0.8, alpha: 0.3)
        glow.particleBlendMode = .add
        
        return glow
    }
    
    private func createMiniNaniteTexture() -> SKTexture {
        let size = CGSize(width: 3, height: 3)
        UIGraphicsBeginImageContext(size)
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(UIColor.cyan.cgColor)
            context.fill(CGRect(x: 1, y: 1, width: 1, height: 1))
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return SKTexture(image: image ?? UIImage())
    }
} 