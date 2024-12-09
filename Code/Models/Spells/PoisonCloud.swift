import Foundation
import SpriteKit

class PoisonCloudSpell: Spell {
    init() {
        super.init(
            name: "PoisonCloud",
            aoeRadius: 80,
            aoeColor: .green,
            duration: 5.0,
            damage: 10,
            effect: PoisonEffect(),
            rarity: .uncommon
        )
    }
}

class PoisonEffect: SpellEffect {
    func apply(spell: Spell, on goblin: Goblin.GoblinContainer) {
        // Skip if the target is not a goblin (safety check)
        guard goblin.sprite.name?.contains("goblin") == true else { return }
        
        // Initial damage
        goblin.applyDamage(spell.damage)
        
        // Apply damage over time
        let damageInterval: TimeInterval = 1.0
        let numberOfTicks = Int(spell.duration / damageInterval)
        
        for tick in 1...numberOfTicks {
            let wait = SKAction.wait(forDuration: damageInterval * Double(tick))
            let applyDamage = SKAction.run {
                // Additional safety check before applying tick damage
                if goblin.sprite.parent != nil {  // Only apply if goblin still exists
                    goblin.applyDamage(spell.damage)
                }
            }
            goblin.sprite.run(SKAction.sequence([wait, applyDamage]))
        }
        
        // Visual effect - tint the goblin green
        goblin.sprite.color = .green
        goblin.sprite.colorBlendFactor = 0.5
        
        // Reset color after duration
        let wait = SKAction.wait(forDuration: spell.duration)
        let resetColor = SKAction.run {
            goblin.sprite.colorBlendFactor = 0
        }
        goblin.sprite.run(SKAction.sequence([wait, resetColor]))
    }
}