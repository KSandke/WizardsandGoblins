import Foundation
import SpriteKit

class BloodDripEmitter: SKEmitterNode {
    init(at position: CGPoint) {
        super.init()
        self.position = position
        
        // Base configuration
        particleBirthRate = 4
        numParticlesToEmit = 0 // Continuous
        particleLifetime = 2.0
        particleLifetimeRange = 0.5
        
        // Position and movement
        particlePositionRange = CGVector(dx: 2, dy: 0)
        emissionAngle = -.pi/2 // Downward
        emissionAngleRange = .pi/8
        particleSpeed = 40
        particleSpeedRange = 10
        yAcceleration = -20
        
        // Appearance
        particleSize = CGSize(width: 3, height: 6)
        particleScale = 1.0
        particleScaleRange = 0.2
        particleScaleSpeed = -0.1
        
        // Color and alpha
        let bloodColor = SKColor(red: 0.7, green: 0, blue: 0, alpha: 0.7)
        particleColor = bloodColor
        
        particleColorSequence = SKKeyframeSequence(
            keyframeValues: [bloodColor, bloodColor.withAlphaComponent(0)],
            times: [0, 1]
        )
        
        particleAlphaSpeed = -0.3
        particleBlendMode = .alpha
        
        // Create and set particle texture
        let texture = createDripTexture()
        particleTexture = texture
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createDripTexture() -> SKTexture {
        let size = CGSize(width: 3, height: 6)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            let cgContext = context.cgContext
            
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let colors = [
                SKColor(red: 0.7, green: 0, blue: 0, alpha: 0.7).cgColor,
                SKColor(red: 0.7, green: 0, blue: 0, alpha: 0).cgColor
            ]
            
            if let gradient = CGGradient(
                colorsSpace: colorSpace,
                colors: colors as CFArray,
                locations: [0, 1]
            ) {
                cgContext.drawLinearGradient(
                    gradient,
                    start: CGPoint(x: size.width/2, y: 0),
                    end: CGPoint(x: size.width/2, y: size.height),
                    options: []
                )
            }
        }
        
        return SKTexture(image: image)
    }
} 