import Foundation
import SpriteKit

class CodeRainEmitter: SKEmitterNode {
    init(at position: CGPoint) {
        super.init()
        self.position = position
        
        // Main code rain
        addChild(createCodeDrops())
        addChild(createGlowEffect())
        addChild(createBackgroundEffect())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createCodeDrops() -> SKEmitterNode {
        let code = SKEmitterNode()
        
        code.particleBirthRate = 40
        code.particleLifetime = 3.0
        code.particleLifetimeRange = 1.0
        
        code.particlePositionRange = CGVector(dx: 200, dy: 0)
        code.emissionAngle = .pi/2
        code.emissionAngleRange = 0
        code.particleSpeed = -100
        code.particleSpeedRange = 20
        
        code.particleScale = 0.3
        code.particleScaleRange = 0.1
        code.particleAlpha = 0.8
        code.particleAlphaRange = 0.2
        
        let colors: [SKColor] = [
            SKColor(red: 0, green: 1, blue: 0, alpha: 0.8),
            SKColor(red: 0, green: 0.8, blue: 0, alpha: 0.4),
            SKColor.clear
        ]
        code.particleColorSequence = SKKeyframeSequence(
            keyframeValues: colors,
            times: [0, 0.8, 1.0]
        )
        
        code.particleTexture = createCodeTexture()
        code.particleBlendMode = .add
        
        return code
    }
    
    private func createGlowEffect() -> SKEmitterNode {
        let glow = SKEmitterNode()
        
        glow.particleBirthRate = 20
        glow.particleLifetime = 2.0
        glow.particlePositionRange = CGVector(dx: 200, dy: 0)
        glow.emissionAngle = .pi/2
        glow.particleSpeed = -80
        
        glow.particleScale = 0.5
        glow.particleAlpha = 0.3
        glow.particleAlphaSpeed = -0.1
        
        glow.particleColor = SKColor(red: 0, green: 1, blue: 0, alpha: 0.3)
        glow.particleBlendMode = .add
        
        return glow
    }
    
    private func createBackgroundEffect() -> SKEmitterNode {
        let bg = SKEmitterNode()
        
        bg.particleBirthRate = 5
        bg.particleLifetime = 4.0
        bg.particlePositionRange = CGVector(dx: 200, dy: 0)
        bg.emissionAngle = .pi/2
        bg.particleSpeed = -60
        
        bg.particleScale = 1.0
        bg.particleAlpha = 0.1
        
        bg.particleColor = SKColor(red: 0, green: 0.8, blue: 0, alpha: 0.1)
        bg.particleBlendMode = .add
        
        return bg
    }
    
    private func createCodeTexture() -> SKTexture {
        let size = CGSize(width: 8, height: 12)
        UIGraphicsBeginImageContext(size)
        if let context = UIGraphicsGetCurrentContext() {
            let characters = ["0", "1"]
            let character = characters.randomElement() ?? "0"
            (character as NSString).draw(at: CGPoint(x: 1, y: 1),
                withAttributes: [.font: UIFont.systemFont(ofSize: 10),
                               .foregroundColor: UIColor.green])
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return SKTexture(image: image ?? UIImage())
    }
} 