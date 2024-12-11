import SpriteKit

class MeteorShowerEmitter: SKNode {
    var completionHandler: (() -> Void)?
    
    init(at position: CGPoint) {
        super.init()
        self.position = position
        
        // Create falling meteor
        let meteor = SKSpriteNode(imageNamed: "meteor")
        meteor.size = CGSize(width: 20, height: 20)
        meteor.position = CGPoint(x: 0, y: 600) // Start high above
        addChild(meteor)
        
        // Add trail effect to meteor
        let trail = SKEmitterNode()
        trail.particleBirthRate = 30
        trail.particleLifetime = 0.5
        trail.particleSpeed = 0
        trail.particleAlpha = 0.6
        trail.particleAlphaSpeed = -1.0
        trail.particleScale = 0.3
        trail.particleScaleRange = 0.2
        trail.particleColorSequence = SKKeyframeSequence(keyframeValues: [SKColor.orange, SKColor.red, SKColor.yellow], times: [0, 0.5, 1])
        trail.targetNode = self
        meteor.addChild(trail)
        
        // Animate meteor falling
        let fallDuration: TimeInterval = 0.8
        let fallAction = SKAction.sequence([
            SKAction.move(to: .zero, duration: fallDuration),
            SKAction.removeFromParent()
        ])
        
        // Create impact effect when meteor lands
        let createImpact = SKAction.run { [weak self] in
            // Create impact circle
            let impact = SKShapeNode(circleOfRadius: 40)
            impact.fillColor = .red
            impact.strokeColor = .clear
            impact.alpha = 0.6
            self?.addChild(impact)
            
            // Fade out and remove impact
            let fadeOut = SKAction.sequence([
                SKAction.fadeOut(withDuration: 0.3),
                SKAction.removeFromParent()
            ])
            impact.run(fadeOut)
            
            // Call completion handler
            self?.completionHandler?()
            
            // Remove emitter after impact fades
            self?.run(SKAction.sequence([
                SKAction.wait(forDuration: 0.3),
                SKAction.removeFromParent()
            ]))
        }
        
        meteor.run(SKAction.sequence([fallAction, createImpact]))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
} 