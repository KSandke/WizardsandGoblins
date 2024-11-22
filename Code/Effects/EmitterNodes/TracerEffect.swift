import Foundation
import SpriteKit

class TracerEffectEmitter: SKEmitterNode {
    init(at position: CGPoint, angle: CGFloat) {
        super.init()
        self.position = position
        
        // Base configuration
        particleBirthRate = 100
        numParticlesToEmit = 20
        particleLifetime = 0.15
        particleLifetimeRange = 0.05
        
        // Position and movement
        particlePositionRange = CGVector(dx: 1, dy: 1)
        emissionAngle = angle
        emissionAngleRange = .pi/16
        particleSpeed = 450
        particleSpeedRange = 50
        
        // Appearance
        particleSize = CGSize(width: 8, height: 2)
        particleScale = 0.25
        particleScaleRange = 0.1
        particleScaleSpeed = -0.5
        
        // Color and alpha
        let coreColor = SKColor.white
        let trailColor = SKColor(red: 1.0, green: 0.8, blue: 0.3, alpha: 0.8)
        
        particleColorSequence = SKKeyframeSequence(
            keyframeValues: [coreColor, trailColor, trailColor.withAlphaComponent(0)],
            times: [0, 0.2, 1]
        )
        
        particleAlphaSpeed = -2.0
        particleBlendMode = .add
        
        // Create and set particle texture
        let texture = createTracerTexture()
        particleTexture = texture
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createTracerTexture() -> SKTexture {
        let size = CGSize(width: 8, height: 2)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            let cgContext = context.cgContext
            
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let colors = [
                SKColor.white.cgColor,
                SKColor.white.withAlphaComponent(0).cgColor
            ]
            
            if let gradient = CGGradient(
                colorsSpace: colorSpace,
                colors: colors as CFArray,
                locations: [0, 1]
            ) {
                cgContext.drawLinearGradient(
                    gradient,
                    start: CGPoint(x: 0, y: size.height/2),
                    end: CGPoint(x: size.width, y: size.height/2),
                    options: []
                )
            }
        }
        
        return SKTexture(image: image)
    }
} 