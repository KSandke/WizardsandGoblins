import Foundation
import SpriteKit

class HologramExplosionEmitter: SKEmitterNode {
    init(at position: CGPoint) {
        super.init()
        self.position = position
        
        addChild(createGlitchLines())
        addChild(createPixelExplosion())
        addChild(createDigitalRing())
        addChild(createDataFragments())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createGlitchLines() -> SKEmitterNode {
        let glitch = SKEmitterNode()
        
        glitch.particleBirthRate = 60
        glitch.numParticlesToEmit = 30
        glitch.particleLifetime = 0.3
        glitch.particleLifetimeRange = 0.1
        
        glitch.particlePositionRange = CGVector(dx: 30, dy: 30)
        glitch.emissionAngle = 0
        glitch.emissionAngleRange = .pi * 2
        glitch.particleSpeed = 100
        
        glitch.particleScale = 0.5
        glitch.particleScaleRange = 0.3
        glitch.particleAlpha = 0.7
        glitch.particleAlphaSpeed = -2.0
        
        glitch.particleColor = SKColor(red: 0, green: 1, blue: 1, alpha: 0.8)
        glitch.particleTexture = createGlitchTexture()
        glitch.particleBlendMode = .screen
        
        return glitch
    }
    
    private func createPixelExplosion() -> SKEmitterNode {
        let pixels = SKEmitterNode()
        
        pixels.particleBirthRate = 200
        pixels.numParticlesToEmit = 100
        pixels.particleLifetime = 0.5
        pixels.particleLifetimeRange = 0.2
        
        pixels.particlePositionRange = CGVector(dx: 10, dy: 10)
        pixels.emissionAngle = 0
        pixels.emissionAngleRange = .pi * 2
        pixels.particleSpeed = 150
        pixels.particleSpeedRange = 50
        
        pixels.particleScale = 0.15
        pixels.particleScaleRange = 0.05
        pixels.particleRotation = 0
        pixels.particleRotationRange = .pi * 2
        
        let colors: [SKColor] = [
            SKColor(red: 0, green: 1, blue: 1, alpha: 0.8),
            SKColor(red: 0, green: 0.5, blue: 1, alpha: 0.4),
            SKColor.clear
        ]
        pixels.particleColorSequence = SKKeyframeSequence(
            keyframeValues: colors,
            times: [0, 0.5, 1.0]
        )
        
        pixels.particleTexture = createPixelTexture()
        pixels.particleBlendMode = .add
        
        return pixels
    }
    
    private func createDigitalRing() -> SKEmitterNode {
        let ring = SKEmitterNode()
        
        ring.particleBirthRate = 1
        ring.numParticlesToEmit = 1
        ring.particleLifetime = 0.3
        
        ring.particleScale = 0.1
        ring.particleScaleSpeed = 4.0
        ring.particleAlpha = 0.8
        ring.particleAlphaSpeed = -2.0
        
        ring.particleColor = SKColor(red: 0, green: 1, blue: 1, alpha: 0.8)
        ring.particleTexture = createRingTexture()
        ring.particleBlendMode = .add
        
        return ring
    }
    
    private func createDataFragments() -> SKEmitterNode {
        let data = SKEmitterNode()
        
        data.particleBirthRate = 40
        data.numParticlesToEmit = 20
        data.particleLifetime = 0.6
        data.particleLifetimeRange = 0.2
        
        data.particlePositionRange = CGVector(dx: 20, dy: 20)
        data.emissionAngle = 0
        data.emissionAngleRange = .pi * 2
        data.particleSpeed = 80
        data.particleSpeedRange = 30
        
        data.particleScale = 0.3
        data.particleScaleRange = 0.1
        data.particleAlpha = 0.6
        data.particleAlphaSpeed = -1.0
        
        data.particleColor = SKColor(red: 0, green: 1, blue: 0.8, alpha: 0.6)
        data.particleTexture = createDataTexture()
        data.particleBlendMode = .add
        
        return data
    }
    
    // Texture creation methods...
    private func createGlitchTexture() -> SKTexture {
        let size = CGSize(width: 20, height: 2)
        UIGraphicsBeginImageContext(size)
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(UIColor.cyan.cgColor)
            context.fill(CGRect(x: 0, y: 0, width: 20, height: 2))
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return SKTexture(image: image ?? UIImage())
    }
    
    private func createPixelTexture() -> SKTexture {
        let size = CGSize(width: 2, height: 2)
        UIGraphicsBeginImageContext(size)
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(UIColor.cyan.cgColor)
            context.fill(CGRect(x: 0, y: 0, width: 2, height: 2))
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return SKTexture(image: image ?? UIImage())
    }
    
    private func createRingTexture() -> SKTexture {
        let size = CGSize(width: 32, height: 32)
        UIGraphicsBeginImageContext(size)
        if let context = UIGraphicsGetCurrentContext() {
            context.setStrokeColor(UIColor.cyan.cgColor)
            context.setLineWidth(2)
            context.strokeEllipse(in: CGRect(x: 2, y: 2, width: 28, height: 28))
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return SKTexture(image: image ?? UIImage())
    }
    
    private func createDataTexture() -> SKTexture {
        let size = CGSize(width: 8, height: 8)
        UIGraphicsBeginImageContext(size)
        if let context = UIGraphicsGetCurrentContext() {
            let binary = "10"
            context.setFillColor(UIColor.cyan.cgColor)
            (binary as NSString).draw(at: CGPoint(x: 1, y: 1), 
                withAttributes: [.font: UIFont.systemFont(ofSize: 6),
                               .foregroundColor: UIColor.cyan])
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return SKTexture(image: image ?? UIImage())
    }
} 