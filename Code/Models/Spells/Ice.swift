import Foundation
import SpriteKit

class IceSpell: Spell {
    init() {
        super.init(
            name: "IceSpell",
            aoeRadius: 50,
            aoeColor: .cyan,
            duration: 1.0,
            damage: 20,
            effect: IceEffect(),
            rarity: .common
        )
    }
}

class IceEffect: SpellEffect {
    func apply(spell: Spell, on goblin: Goblin.GoblinContainer) {
        goblin.applyDamage(spell.damage)
        goblin.sprite.speed = 0.5
        let wait = SKAction.wait(forDuration: 5.0)
        let resetSpeed = SKAction.run {
            goblin.sprite.speed = 1.0
        }
        goblin.sprite.run(SKAction.sequence([wait, resetSpeed]))
    }
}