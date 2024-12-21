import Foundation
import SpriteKit

class DivineHealingSpecial: Special {
    init() {
        super.init(
            name: "DivineHealing",
            aoeRadius: 100,
            aoeColor: .green,
            duration: 2.0,
            damage: 0,  // Healing special doesn't do damage
            effect: DivineHealingEffect(),
            cooldown: 60.0,  // Long cooldown since it's powerful
            targetingMode: .global,
            rarity: .legendary
        )
    }
}

class DivineHealingEffect: SpecialEffect {
    func apply(spell: Special, on goblin: Goblin.GoblinContainer) {
        guard let scene = goblin.sprite.scene as? GameScene,
              let playerState = scene.playerState else { return }
        
        // Calculate healing amount (50% of max health)
        let healAmount = playerState.maxHealth * 0.5
        let newHealth = playerState.castleHealth + healAmount
        
        // Set health to either max health or current health + 50% of max health
        playerState.castleHealth = min(playerState.maxHealth, newHealth)
        
        // Create healing visual effect
        let healingEffect = SKEmitterNode()
        healingEffect.particleColor = .green
        healingEffect.particleColorBlendFactor = 1.0
        healingEffect.particleLifetime = 2.0
        healingEffect.particleBirthRate = 50
        healingEffect.position = scene.castlePosition
        scene.addChild(healingEffect)
        
        // Remove effect after duration
        healingEffect.run(SKAction.sequence([
            SKAction.wait(forDuration: 2.0),
            SKAction.removeFromParent()
        ]))
    }
} 