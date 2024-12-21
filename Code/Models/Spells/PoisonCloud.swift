import Foundation
import SpriteKit

class PoisonCloudSpell: Spell {
    init() {
        super.init(
            name: "PoisonCloud",
            aoeRadius: 80,
            aoeColor: .green.withAlphaComponent(0.5),
            duration: 5.0,
            damage: 10, // Damage per tick
            effect: PoisonCloudEffect(),
            rarity: .uncommon
        )
    }
}

class PoisonCloudEffect: SpellEffect {
    func apply(spell: Spell, on goblin: Goblin.GoblinContainer) {
        guard let scene = goblin.sprite.scene as? GameScene else { return }
        
        // Create poison cloud visual effect
        let poisonCloud = PoisonCloudEmitter(at: goblin.sprite.position)
        scene.addChild(poisonCloud)
        
        // Create damage tick timer
        let tickInterval = 0.5 // Damage every half second
        let damagePerTick = spell.damage / 2 // Reduced damage per tick since it's frequent
        
        let tickAction = SKAction.repeat(SKAction.sequence([
            SKAction.run { [weak scene] in
                guard let gameScene = scene as? GameScene else { return }
                
                // Check all goblins in the area and apply poison damage
                for target in gameScene.goblinManager.goblinContainers {
                    let distance = target.sprite.position.distance(to: poisonCloud.position)
                    if distance <= spell.aoeRadius {
                        // Apply poison damage
                        target.applyDamage(damagePerTick)
                        
                        // Visual feedback for poisoned state
                        target.sprite.color = .green
                        target.sprite.colorBlendFactor = 0.3
                    } else {
                        // Remove poison visual effect if goblin leaves the cloud
                        target.sprite.colorBlendFactor = 0
                    }
                }
            },
            SKAction.wait(forDuration: tickInterval)
        ]), count: Int(spell.duration / tickInterval))
        
        // Run the poison cloud effect
        scene.run(tickAction)
        
        // Remove the poison cloud after duration
        poisonCloud.run(SKAction.sequence([
            SKAction.wait(forDuration: spell.duration),
            SKAction.fadeOut(withDuration: 0.5),
            SKAction.removeFromParent()
        ]))
    }
}

class PoisonCloudEmitter: SKEmitterNode {
    init(at position: CGPoint) {
        super.init()
        
        self.position = position
        self.particleTexture = SKTexture(imageNamed: "spark") // Use existing spark texture
        self.particleBirthRate = 50
        self.numParticlesToEmit = -1 // Continuous emission
        self.particleLifetime = 2.0
        self.particlePosition = .zero
        self.particlePositionRange = CGVector(dx: 80, dy: 80)
        self.particleSpeed = 10
        self.particleSpeedRange = 5
        self.particleColor = .green
        self.particleColorBlendFactor = 1.0
        self.particleColorBlendFactorRange = 0.2
        self.particleAlpha = 0.3
        self.particleAlphaRange = 0.2
        self.particleScale = 0.5
        self.particleScaleRange = 0.2
        self.particleRotation = 0
        self.particleRotationRange = .pi * 2
        self.emissionAngle = 0
        self.emissionAngleRange = .pi * 2
        self.xAcceleration = 0
        self.yAcceleration = 0
        
        self.zPosition = 5
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
} 
