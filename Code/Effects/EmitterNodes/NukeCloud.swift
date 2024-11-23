import Foundation
import SpriteKit

class NukeCloudEmitter: SKEmitterNode {
    init(at position: CGPoint) {
        super.init()
        self.position = position
        
        // Create composite effect with multiple emitters
        addChild(createMushroomStem())
        addChild(createMushroomCap())
        addChild(createShockwave())
        addChild(createDebris())
        addChild(createFireCore())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createMushroomStem() -> SKEmitterNode {
        let stem = SKEmitterNode()
        
        // Base configuration
        stem.particleBirthRate = 40
        stem.numParticlesToEmit = 100
        stem.particleLifetime = 2.5
        stem.particleLifetimeRange = 0.5
        
        // Movement
        stem.particlePositionRange = CGVector(dx: 30, dy: 10)
        stem.emissionAngle = -.pi/2 // Upward
        stem.emissionAngleRange = .pi/8
        stem.particleSpeed = 250
        stem.particleSpeedRange = 50
        stem.yAcceleration = -20
        
        // Appearance
        stem.particleScale = 2.0
        stem.particleScaleRange = 0.5
        stem.particleScaleSpeed = 0.5
        
        // Color sequence
        let colors: [SKColor] = [
            .white,
            SKColor(red: 0.8, green: 0.7, blue: 0.5, alpha: 0.8),
            SKColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 0.6),
            SKColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0)
        ]
        stem.particleColorSequence = SKKeyframeSequence(
            keyframeValues: colors,
            times: [0, 0.2, 0.5, 1.0]
        )
        
        stem.particleTexture = createSmokeTexture()
        return stem
    }
    
    private func createMushroomCap() -> SKEmitterNode {
        let cap = SKEmitterNode()
        
        cap.particleBirthRate = 30
        cap.numParticlesToEmit = 60
        cap.particleLifetime = 3.0
        cap.position.y = 100 // Start above stem
        
        cap.particlePositionRange = CGVector(dx: 50, dy: 20)
        cap.emissionAngle = 0
        cap.emissionAngleRange = .pi * 2
        cap.particleSpeed = 80
        cap.particleSpeedRange = 30
        cap.xAcceleration = 0
        cap.yAcceleration = 20
        
        cap.particleScale = 3.0
        cap.particleScaleRange = 1.0
        cap.particleScaleSpeed = 0.3
        
        let colors: [SKColor] = [
            SKColor(red: 1.0, green: 0.8, blue: 0.3, alpha: 0.8),
            SKColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 0.6),
            SKColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0)
        ]
        cap.particleColorSequence = SKKeyframeSequence(
            keyframeValues: colors,
            times: [0, 0.4, 1.0]
        )
        
        cap.particleTexture = createSmokeTexture()
        return cap
    }
    
    private func createShockwave() -> SKEmitterNode {
        let wave = SKEmitterNode()
        
        wave.particleBirthRate = 1
        wave.numParticlesToEmit = 1
        wave.particleLifetime = 0.5
        
        wave.particlePositionRange = .zero
        wave.emissionAngle = 0
        wave.emissionAngleRange = .pi * 2
        wave.particleSpeed = 400
        
        wave.particleScale = 0.1
        wave.particleScaleSpeed = 8.0
        
        wave.particleAlpha = 0.8
        wave.particleAlphaSpeed = -1.6
        
        wave.particleColor = .white
        wave.particleTexture = createRingTexture()
        return wave
    }
    
    private func createDebris() -> SKEmitterNode {
        let debris = SKEmitterNode()
        
        debris.particleBirthRate = 100
        debris.numParticlesToEmit = 200
        debris.particleLifetime = 2.0
        debris.particleLifetimeRange = 0.5
        
        debris.particlePositionRange = CGVector(dx: 20, dy: 20)
        debris.emissionAngle = -.pi/2
        debris.emissionAngleRange = .pi
        debris.particleSpeed = 200
        debris.particleSpeedRange = 100
        debris.yAcceleration = 150
        
        debris.particleScale = 0.2
        debris.particleScaleRange = 0.1
        
        debris.particleColorSequence = SKKeyframeSequence(
            keyframeValues: [.orange, .red, .black],
            times: [0, 0.5, 1.0]
        )
        
        debris.particleTexture = createDebrisTexture()
        return debris
    }
    
    private func createFireCore() -> SKEmitterNode {
        let core = SKEmitterNode()
        
        core.particleBirthRate = 100
        core.numParticlesToEmit = 100
        core.particleLifetime = 0.8
        
        core.particlePositionRange = CGVector(dx: 10, dy: 10)
        core.emissionAngle = -.pi/2
        core.emissionAngleRange = .pi * 2
        core.particleSpeed = 100
        
        core.particleScale = 1.0
        core.particleScaleSpeed = 2.0
        
        let colors: [SKColor] = [.white, .yellow, .orange, .clear]
        core.particleColorSequence = SKKeyframeSequence(
            keyframeValues: colors,
            times: [0, 0.2, 0.4, 1.0]
        )
        
        core.particleTexture = createGlowTexture()
        return core
    }
    
    // Texture creation helpers...
    private func createSmokeTexture() -> SKTexture {
        let size = CGSize(width: 32, height: 32)
        UIGraphicsBeginImageContext(size)
        if let context = UIGraphicsGetCurrentContext() {
            let colors = [UIColor.white.cgColor, UIColor.clear.cgColor]
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                    colors: colors as CFArray,
                                    locations: [0, 1])!
            
            context.drawRadialGradient(gradient,
                                     startCenter: CGPoint(x: 16, y: 16),
                                     startRadius: 0,
                                     endCenter: CGPoint(x: 16, y: 16),
                                     endRadius: 16,
                                     options: [])
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return SKTexture(image: image ?? UIImage())
    }
    
    private func createRingTexture() -> SKTexture {
        let size = CGSize(width: 16, height: 16)
        UIGraphicsBeginImageContext(size)
        if let context = UIGraphicsGetCurrentContext() {
            context.setStrokeColor(UIColor.white.cgColor)
            context.setLineWidth(2)
            context.strokeEllipse(in: CGRect(x: 2, y: 2, width: 12, height: 12))
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return SKTexture(image: image ?? UIImage())
    }
    
    private func createDebrisTexture() -> SKTexture {
        let size = CGSize(width: 4, height: 4)
        UIGraphicsBeginImageContext(size)
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(UIColor.white.cgColor)
            context.fill(CGRect(x: 1, y: 1, width: 2, height: 2))
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return SKTexture(image: image ?? UIImage())
    }
    
    private func createGlowTexture() -> SKTexture {
        let size = CGSize(width: 16, height: 16)
        UIGraphicsBeginImageContext(size)
        if let context = UIGraphicsGetCurrentContext() {
            let colors = [UIColor.white.cgColor, UIColor.clear.cgColor]
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                    colors: colors as CFArray,
                                    locations: [0, 1])!
            
            // Softer glow with larger radius
            context.drawRadialGradient(gradient,
                                     startCenter: CGPoint(x: 8, y: 8),
                                     startRadius: 0,
                                     endCenter: CGPoint(x: 8, y: 8),
                                     endRadius: 8,
                                     options: [])
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return SKTexture(image: image ?? UIImage())
    }
} 