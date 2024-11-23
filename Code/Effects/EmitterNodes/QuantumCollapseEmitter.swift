import Foundation
import SpriteKit

class QuantumCollapseEmitter: SKEmitterNode {
    init() {
        super.init()
        
        // Core emission properties
        particleBirthRate = 400
        particleLifetime = 0.8
        particleLifetimeRange = 0.4
        
        // Movement and spread
        particlePositionRange = CGVector(dx: 20, dy: 20)
        emissionAngleRange = .pi * 2
        particleSpeed = 150
        particleSpeedRange = 80
        
        // Rotation for more quantum-like behavior
        particleRotationRange = .pi * 2
        particleRotationSpeed = 4.0
        
        // Size variation
        particleScale = 0.4
        particleScaleRange = 0.3
        particleScaleSpeed = -0.3
        
        // Opacity with pulse effect
        particleAlpha = 1.0
        particleAlphaRange = 0.3
        particleAlphaSpeed = -0.8
        
        // Color and blending
        let colors: [UIColor] = [.magenta, .cyan, .purple]
        particleColorSequence = SKKeyframeSequence(
            keyframeValues: colors,
            times: [0, 0.5, 1.0]
        )
        particleBlendMode = .add
        
        // Custom texture
        particleTexture = createQuantumParticleTexture()
        
        // Physics behavior
        xAcceleration = 0
        yAcceleration = -50
        particleAction = createParticleAction()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func createQuantumParticleTexture() -> SKTexture {
        let size = CGSize(width: 16, height: 16)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            let bounds = CGRect(origin: .zero, size: size)
            let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [UIColor.white.cgColor, UIColor.clear.cgColor] as CFArray,
                locations: [0, 1]
            )!
            
            context.cgContext.drawRadialGradient(
                gradient,
                startCenter: CGPoint(x: size.width/2, y: size.height/2),
                startRadius: 0,
                endCenter: CGPoint(x: size.width/2, y: size.height/2),
                endRadius: size.width/2,
                options: []
            )
        }
        
        return SKTexture(image: image)
    }
    
    private func createParticleAction() -> SKAction {
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.2)
        let scaleDown = SKAction.scale(to: 0.8, duration: 0.2)
        let sequence = SKAction.sequence([scaleUp, scaleDown])
        return SKAction.repeatForever(sequence)
    }
} 