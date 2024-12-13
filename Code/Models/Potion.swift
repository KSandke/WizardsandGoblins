import SpriteKit

class Potion: SKSpriteNode {
    enum PotionType {
        case mana
        // case smallHealth
        // case largeHealth
    }
    
    let potionType: PotionType
    var isActive: Bool = true
    
    init(type: PotionType, position: CGPoint) {
        self.potionType = type
        let texture: SKTexture
        
        //switch type {
        //case .mana:
        //    texture = SKTexture(imageNamed: "mana_potion")
        // case .smallHealth:
        //     texture = SKTexture(imageNamed: "small_health_potion")
        // case .largeHealth:
        //     texture = SKTexture(imageNamed: "large_health_potion")
        //}

        texture = SKTexture(imageNamed: "mana_potion")
        
        super.init(texture: texture, color: .clear, size: CGSize(width: 80, height: 80))
        self.position = position
        self.name = "potion"
        self.zPosition = 10
        
        // Setup physics body for collision detection with spells
        self.physicsBody = SKPhysicsBody(circleOfRadius: self.size.width / 2)
        self.physicsBody?.isDynamic = false
        self.physicsBody?.categoryBitMask = GameConfig.potionCategory
        self.physicsBody?.contactTestBitMask = GameConfig.spellCategory
        self.physicsBody?.collisionBitMask = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func applyEffect(to playerState: PlayerState, in scene: SKScene) {
        guard isActive else { return }
        isActive = false
        
        // Play break animation before removing the potion
        if let gameScene = scene as? GameScene {
            gameScene.createFrameAnimation(at: self.position,
                                           framePrefix: "PotionBreak",
                                           frameCount: 4,
                                           duration: 0.6,
                                           size: self.size)
        }
        if let gameScene = scene as? GameScene {
            gameScene.createFrameAnimation(at: self.position,
                            framePrefix: "ManaPot",
                            frameCount: 4,
                            duration: 0.6,
                            size: CGSize(width: 100, height: 100))
        }
        
        // switch potionType {
        // case .mana:
        //     playerState.activateInfiniteMana(duration: GameConfig.manaPotionDuration)
        //     scene.run(SKAction.playSoundFileNamed("ManaPotionSound.wav", waitForCompletion: false))
        // case .smallHealth:
        //     playerState.restoreHealth(amount: GameConfig.smallHealthPotionAmount)
        //     scene.run(SKAction.playSoundFileNamed("HealthPotionSound.wav", waitForCompletion: false))
        //     playerState.onHealthRestored?(GameConfig.smallHealthPotionAmount)
        // case .largeHealth:
        //     playerState.restoreHealth(amount: GameConfig.largeHealthPotionAmount)
        //     scene.run(SKAction.playSoundFileNamed("HealthPotionSound.wav", waitForCompletion: false))
        //     playerState.onHealthRestored?(GameConfig.largeHealthPotionAmount)
        // }

        //only mana for now
        playerState.activateInfiniteMana(duration: GameConfig.manaPotionDuration)
        scene.run(SKAction.playSoundFileNamed("ManaPotionSound.wav", waitForCompletion: false))
        
        // Remove the potion sprite from the scene
        self.removeFromParent()
    }
}
