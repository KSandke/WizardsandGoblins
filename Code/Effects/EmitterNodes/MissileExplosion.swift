import Foundation
import SpriteKit

class MissileExplosionEmitter: SKEmitterNode {
    init(at position: CGPoint) {
        super.init()
        self.position = position
        
        // Create composite explosion
        addChild(createFireball())
        addChild(createShockwave())
        addChild(createSparks())
        addChild(createSmoke())
        addChild(createDebris())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createFireball() -> SKEmitterNode {
        let fire = SKEmitterNode()
        
        fire.particleBirthRate = 200
        fire.numParticlesToEmit = 50
        fire.particleLifetime = 0.5
        fire.particleLifetimeRange = 0.2
        
        fire.particlePositionRange = CGVector(dx: 10, dy: 10)
        fire.emissionAngle = 0
        fire.emissionAngleRange = .pi * 2
        fire.particleSpeed = 150
        fire.particleSpeedRange = 50
        
        fire.particleScale = 1.0
        fire.particleScaleSpeed = -1.0
        
        let colors: [SKColor] = [.white, .yellow, .orange, .clear]
        fire.particleColorSequence = SKKeyframeSequence(
            keyframeValues: colors,
            times: [0, 0.2, 0.4, 1.0]
        )
        
        fire.particleTexture = createFireballTexture()
        fire.particleBlendMode = .add
        
        return fire
    }
    
    private func createShockwave() -> SKEmitterNode {
        let wave = SKEmitterNode()
        
        wave.particleBirthRate = 1
        wave.numParticlesToEmit = 1
        wave.particleLifetime = 0.2
        
        wave.particlePositionRange = .zero
        wave.emissionAngle = 0
        wave.emissionAngleRange = .pi * 2
        wave.particleSpeed = 300
        
        wave.particleScale = 0.1
        wave.particleScaleSpeed = 6.0
        
        wave.particleAlpha = 0.8
        wave.particleAlphaSpeed = -4.0
        
        wave.particleColor = .white
        wave.particleTexture = createRingTexture()
        wave.particleBlendMode = .add
        
        return wave
    }
    
    private func createSparks() -> SKEmitterNode {
        let sparks = SKEmitterNode()
        
        sparks.particleBirthRate = 300
        sparks.numParticlesToEmit = 100
        sparks.particleLifetime = 0.4
        sparks.particleLifetimeRange = 0.2
        
        sparks.particlePositionRange = CGVector(dx: 5, dy: 5)
        sparks.emissionAngle = 0
        sparks.emissionAngleRange = .pi * 2
        sparks.particleSpeed = 200
        sparks.particleSpeedRange = 100
        
        sparks.particleScale = 0.2
        sparks.particleScaleRange = 0.1
        sparks.particleScaleSpeed = -0.5
        
        let colors: [SKColor] = [.white, .yellow, .orange, .clear]
        sparks.particleColorSequence = SKKeyframeSequence(
            keyframeValues: colors,
            times: [0, 0.2, 0.4, 1.0]
        )
        
        sparks.particleTexture = createSparkTexture()
        sparks.particleBlendMode = .add
        
        return sparks
    }
    
    private func createSmoke() -> SKEmitterNode {
        let smoke = SKEmitterNode()
        
        smoke.particleBirthRate = 50
        smoke.numParticlesToEmit = 30
        smoke.particleLifetime = 1.0
        smoke.particleLifetimeRange = 0.5
        
        smoke.particlePositionRange = CGVector(dx: 20, dy: 20)
        smoke.emissionAngle = -.pi/2
        smoke.emissionAngleRange = .pi/4
        smoke.particleSpeed = 50
        smoke.particleSpeedRange = 20
        smoke.yAcceleration = -20
        
        smoke.particleScale = 1.0
        smoke.particleScaleRange = 0.5
        smoke.particleScaleSpeed = 1.0
        
        smoke.particleColor = SKColor(white: 0.3, alpha: 0.5)
        smoke.particleAlphaSpeed = -0.5
        
        smoke.particleTexture = createSmokeTexture()
        smoke.particleBlendMode = .alpha
        
        return smoke
    }
    
    private func createDebris() -> SKEmitterNode {
        let debris = SKEmitterNode()
        
        debris.particleBirthRate = 100
        debris.numParticlesToEmit = 50
        debris.particleLifetime = 0.8
        debris.particleLifetimeRange = 0.3
        
        debris.particlePositionRange = CGVector(dx: 10, dy: 10)
        debris.emissionAngle = 0
        debris.emissionAngleRange = .pi * 2
        debris.particleSpeed = 150
        debris.particleSpeedRange = 80
        debris.yAcceleration = 200
        
        debris.particleScale = 0.15
        debris.particleScaleRange = 0.05
        
        debris.particleColor = .gray
        debris.particleColorBlendFactor = 1.0
        debris.particleBlendMode = .alpha
        
        debris.particleTexture = createDebrisTexture()
        
        return debris
    }
    
    // Texture creation methods
    private func createFireballTexture() -> SKTexture {
        let size = CGSize(width: 16, height: 16)
        UIGraphicsBeginImageContext(size)
        if let context = UIGraphicsGetCurrentContext() {
            let colors = [UIColor.white.cgColor, UIColor.clear.cgColor]
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                    colors: colors as CFArray,
                                    locations: [0, 1])!
            
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
    
    private func createRingTexture() -> SKTexture {
        let size = CGSize(width: 32, height: 32)
        UIGraphicsBeginImageContext(size)
        if let context = UIGraphicsGetCurrentContext() {
            context.setStrokeColor(UIColor.white.cgColor)
            context.setLineWidth(2)
            context.strokeEllipse(in: CGRect(x: 2, y: 2, width: 28, height: 28))
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return SKTexture(image: image ?? UIImage())
    }
    
    private func createSparkTexture() -> SKTexture {
        let size = CGSize(width: 4, height: 4)
        UIGraphicsBeginImageContext(size)
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(UIColor.white.cgColor)
            context.fill(CGRect(x: 0, y: 0, width: 4, height: 4))
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return SKTexture(image: image ?? UIImage())
    }
    
    private func createSmokeTexture() -> SKTexture {
        let size = CGSize(width: 32, height: 32)
        UIGraphicsBeginImageContext(size)
        if let context = UIGraphicsGetCurrentContext() {
            let colors = [UIColor.gray.cgColor, UIColor.clear.cgColor]
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
    
    private func createDebrisTexture() -> SKTexture {
        let size = CGSize(width: 4, height: 4)
        UIGraphicsBeginImageContext(size)
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(UIColor.darkGray.cgColor)
            context.fill(CGRect(x: 1, y: 1, width: 2, height: 2))
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return SKTexture(image: image ?? UIImage())
    }
} 