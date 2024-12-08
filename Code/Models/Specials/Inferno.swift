import Foundation
import SpriteKit

class InfernoSpecial: Special {
    init() {
        super.init(
            name: "Inferno",
            aoeRadius: 100,
            aoeColor: .red,
            duration: 6.0,
            damage: 60,
            effect: InfernoEffect(),
            cooldown: 40.0,
            targetingMode: .global,
            rarity: .epic
        )
    }
}

class InfernoEffect: SpellEffect {
    func apply(spell: Spell, on goblin: Goblin.GoblinContainer) {
        guard let scene = goblin.sprite.scene else { return }
        
        let inferno = InfernoEmitter(at: goblin.sprite.position)
        scene.addChild(inferno)
        
        // High damage over time in area
        let damagePerTick = spell.damage / CGFloat(spell.duration)
        let tickAction = SKAction.repeat(SKAction.sequence([
            SKAction.run { [weak scene] in
                guard let gameScene = scene as? GameScene else { return }
                for target in gameScene.goblinManager.goblinContainers {
                    let distance = target.sprite.position.distance(to: goblin.sprite.position)
                    if distance <= spell.aoeRadius {
                        target.applyDamage(damagePerTick)
                        // Apply burning effect
                        target.applyDamage(damagePerTick * 0.2) // Additional burn damage
                    }
                }
            },
            SKAction.wait(forDuration: 0.5) // Faster damage ticks
        ]), count: Int(spell.duration * 2)) // Double the ticks due to faster interval
        
        scene.run(tickAction)
    }
}
