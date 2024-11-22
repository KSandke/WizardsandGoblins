import Foundation
import SpriteKit

class BloodParticleEmitter: SKEmitterNode {
    init(at position: CGPoint) {
        super.init()
        self.position = position
        
        // Base configuration
        particleBirthRate = 300
        numParticlesToEmit = 50
        particleLifetime = 0.8
        particleLifetimeRange = 0.3
        
        // Position and movement
        particlePositionRange = CGVector(dx: 10, dy: 10)
        emissionAngle = 0
        emissionAngleRange = .pi * 2
        particleSpeed = 120
        particleSpeedRange = 40
        yAcceleration = -150
        
        // Appearance
        particleSize = CGSize(width: 4, height: 4)
        particleScale = 0.4
        particleScaleRange = 0.2
        particleScaleSpeed = -0.3
        
        // Color and alpha
        let startColor = SKColor(red: 0.7, green: 0, blue: 0, alpha: 0.8)
        let endColor = SKColor(red: 0.4, green: 0, blue: 0, alpha: 0)
        
        particleColorSequence = SKKeyframeSequence(
            keyframeValues: [startColor, endColor],
            times: [0, 1]
        )
        
        particleAlphaSpeed = -1.0
        particleBlendMode = .add
        
        // Create and set particle texture
        let texture = createBloodTexture()
        particleTexture = texture
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createBloodTexture() -> SKTexture {
        let size = CGSize(width: 4, height: 4)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            let cgContext = context.cgContext
            
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let colors = [
                SKColor(red: 0.7, green: 0, blue: 0, alpha: 0.8).cgColor,
                SKColor(red: 0.7, green: 0, blue: 0, alpha: 0).cgColor
            ]
            
            if let gradient = CGGradient(
                colorsSpace: colorSpace,
                colors: colors as CFArray,
                locations: [0, 1]
            ) {
                let center = CGPoint(x: size.width/2, y: size.height/2)
                cgContext.drawRadialGradient(
                    gradient,
                    startCenter: center,
                    startRadius: 0,
                    endCenter: center,
                    endRadius: size.width/2,
                    options: []
                )
            }
        }
        
        return SKTexture(image: image)
    }
} 