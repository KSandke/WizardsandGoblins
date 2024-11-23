import Foundation
import SpriteKit

class NanoSwarmEmitter: SKEmitterNode {
    init(at position: CGPoint) {
        super.init()
        self.position = position
        
        // Create main swarm effect
        addChild(createNanites())
        addChild(createDigitalField())
        addChild(createGlitchEffect())
        addChild(createEnergyField())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createNanites() -> SKEmitterNode {
        let nanites = SKEmitterNode()
        
        nanites.particleBirthRate = 100
        nanites.particleLifetime = 2.0
        nanites.particleLifetimeRange = 0.5
        
        nanites.particlePositionRange = CGVector(dx: 40, dy: 40)
        nanites.emissionAngle = 0
        nanites.emissionAngleRange = .pi * 2
        nanites.particleSpeed = 60
        nanites.particleSpeedRange = 20
        
        nanites.particleScale = 0.15
        nanites.particleScaleRange = 0.05
        nanites.particleRotation = 0
        nanites.particleRotationRange = .pi * 2
        nanites.particleRotationSpeed = 2.0
        
        let colors: [SKColor] = [
            SKColor(red: 0, green: 1, blue: 1, alpha: 0.8),
            SKColor(red: 0, green: 0.8, blue: 1, alpha: 0.6),
            SKColor.clear
        ]
        nanites.particleColorSequence = SKKeyframeSequence(
            keyframeValues: colors,
            times: [0, 0.5, 1.0]
        )
        
        nanites.particleTexture = createNaniteTexture()
        nanites.particleBlendMode = .add
        
        return nanites
    }
    
    private func createDigitalField() -> SKEmitterNode {
        let field = SKEmitterNode()
        
        field.particleBirthRate = 20
        field.particleLifetime = 0.8
        field.particleLifetimeRange = 0.2
        
        field.particlePositionRange = CGVector(dx: 60, dy: 60)
        field.emissionAngle = 0
        field.emissionAngleRange = .pi * 2
        field.particleSpeed = 10
        
        field.particleScale = 0.5
        field.particleScaleRange = 0.2
        field.particleAlpha = 0.4
        field.particleAlphaRange = 0.2
        
        field.particleColor = SKColor(red: 0, green: 1, blue: 0.8, alpha: 0.3)
        field.particleTexture = createDigitalTexture()
        field.particleBlendMode = .add
        
        return field
    }
    
    private func createGlitchEffect() -> SKEmitterNode {
        let glitch = SKEmitterNode()
        
        glitch.particleBirthRate = 15
        glitch.particleLifetime = 0.3
        glitch.particleLifetimeRange = 0.1
        
        glitch.particlePositionRange = CGVector(dx: 50, dy: 50)
        glitch.particleScale = 0.8
        glitch.particleScaleRange = 0.3
        glitch.particleAlpha = 0.6
        
        glitch.particleColor = SKColor(red: 1, green: 1, blue: 1, alpha: 0.7)
        glitch.particleTexture = createGlitchTexture()
        glitch.particleBlendMode = .screen
        
        return glitch
    }
    
    private func createEnergyField() -> SKEmitterNode {
        let energy = SKEmitterNode()
        
        energy.particleBirthRate = 30
        energy.particleLifetime = 1.0
        energy.particleLifetimeRange = 0.3
        
        energy.particlePositionRange = CGVector(dx: 30, dy: 30)
        energy.emissionAngle = 0
        energy.emissionAngleRange = .pi * 2
        energy.particleSpeed = 40
        energy.particleSpeedRange = 20
        
        energy.particleScale = 0.3
        energy.particleScaleRange = 0.1
        energy.particleScaleSpeed = -0.2
        
        let colors: [SKColor] = [
            SKColor(red: 0.2, green: 1, blue: 1, alpha: 0.8),
            SKColor(red: 0, green: 0.8, blue: 1, alpha: 0.4),
            SKColor.clear
        ]
        energy.particleColorSequence = SKKeyframeSequence(
            keyframeValues: colors,
            times: [0, 0.5, 1.0]
        )
        
        energy.particleTexture = createEnergyTexture()
        energy.particleBlendMode = .add
        
        return energy
    }
    
    private func createNaniteTexture() -> SKTexture {
        return SKTexture(size: CGSize(width: 4, height: 4)) { context in
            context.setFillColor(UIColor.cyan.cgColor)
            context.fill(CGRect(x: 1, y: 1, width: 2, height: 2))
            
            // Add detail lines
            context.setStrokeColor(UIColor.white.cgColor)
            context.setLineWidth(0.5)
            context.move(to: CGPoint(x: 0, y: 2))
            context.addLine(to: CGPoint(x: 4, y: 2))
            context.strokePath()
        }
    }
    
    private func createDigitalTexture() -> SKTexture {
        return SKTexture(size: CGSize(width: 8, height: 8)) { context in
            let binary = "10"
            context.setFillColor(UIColor.cyan.cgColor)
            context.setFont(UIFont.systemFont(ofSize: 6))
            binary.draw(at: CGPoint(x: 1, y: 1), withAttributes: [
                .foregroundColor: UIColor.cyan
            ])
        }
    }
    
    private func createGlitchTexture() -> SKTexture {
        return SKTexture(size: CGSize(width: 20, height: 4)) { context in
            context.setFillColor(UIColor.white.cgColor)
            context.fill(CGRect(x: 0, y: 0, width: 20, height: 4))
        }
    }
    
    private func createEnergyTexture() -> SKTexture {
        return SKTexture(size: CGSize(width: 8, height: 8)) { context in
            let rect = CGRect(x: 0, y: 0, width: 8, height: 8)
            let colors = [UIColor.white.cgColor, UIColor.clear.cgColor]
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                    colors: colors as CFArray,
                                    locations: [0, 1])!
            
            context.drawRadialGradient(gradient,
                                     startCenter: CGPoint(x: 4, y: 4),
                                     startRadius: 0,
                                     endCenter: CGPoint(x: 4, y: 4),
                                     endRadius: 4,
                                     options: [])
        }
    }
} 