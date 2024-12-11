import SpriteKit

class MeteorShowerEmitter: SKNode {
    var completionHandler: (() -> Void)?
    
    init(at position: CGPoint) {
        super.init()
        self.position = position

        // Starfield background
        let starfield = SKEmitterNode()
        starfield.particleBirthRate = 5
        starfield.particleLifetime = 20.0
        starfield.particleSpeed = 0
        starfield.emissionAngleRange = .pi * 2
        starfield.particleAlpha = 0.5
        starfield.particleScale = 0.5
        starfield.particleScaleRange = 0.3
        starfield.particleColor = .white
        starfield.particlePositionRange = CGVector(dx: 800, dy: 600)
        starfield.particleTexture = SKTexture(imageNamed: "meteor")
        addChild(starfield)

        // Meteors
        let meteorEmitter = SKEmitterNode()
        meteorEmitter.particleBirthRate = 10
        meteorEmitter.particleLifetime = 3.0
        meteorEmitter.particleSpeed = 400
        meteorEmitter.emissionAngle = .pi / 4
        meteorEmitter.emissionAngleRange = .pi / 8
        meteorEmitter.particleAlpha = 0.9
        meteorEmitter.particleAlphaSpeed = -0.3
        meteorEmitter.particleScale = 0.7
        meteorEmitter.particleScaleRange = 0.2
        meteorEmitter.particleColorSequence = SKKeyframeSequence(keyframeValues: [SKColor.orange, SKColor.red, SKColor.yellow], times: [0, 0.5, 1])
        meteorEmitter.particlePositionRange = CGVector(dx: 0, dy: 600)
        meteorEmitter.particleTexture = createMeteorTexture()
        meteorEmitter.particleBlendMode = .add
        addChild(meteorEmitter)

        // Remove after duration and call completion handler
        run(SKAction.sequence([
            SKAction.wait(forDuration: 5.0),
            SKAction.run { [weak self] in
                self?.completionHandler?()
            },
            SKAction.fadeOut(withDuration: 1.0),
            SKAction.removeFromParent()
        ]))
    }

    private func createMeteorTexture() -> SKTexture {
        let size = CGSize(width: 10, height: 30)
        UIGraphicsBeginImageContext(size)
        if let context = UIGraphicsGetCurrentContext() {
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                      colors: [UIColor.white.cgColor, UIColor.clear.cgColor] as CFArray,
                                      locations: [0, 1])!
            context.drawLinearGradient(gradient,
                                       start: CGPoint(x: size.width / 2, y: 0),
                                       end: CGPoint(x: size.width / 2, y: size.height),
                                       options: [])
        }
        let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return SKTexture(image: image)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
} 