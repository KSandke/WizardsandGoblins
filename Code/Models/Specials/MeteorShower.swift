import Foundation
import SpriteKit

class MeteorShowerSpecial: Special {
    init() {
        super.init(
            name: "Meteor Shower",
            aoeRadius: 200,
            aoeColor: .orange,
            duration: 5.0,
            damage: 80,
            effect: MeteorShowerEffect(),
            cooldown: 90.0,
            targetingMode: .global,
            rarity: .legendary
        )
    }
}

class MeteorShowerEffect: SpellEffect {
    func apply(spell: Spell, on goblin: Goblin.GoblinContainer) {
        guard let scene = goblin.sprite.scene else { return }
        
        let meteor = MeteorShowerEmitter(at: goblin.sprite.position)
        scene.addChild(meteor)
        
        // Area damage over time
        let damagePerTick = spell.damage / CGFloat(spell.duration)
        let tickAction = SKAction.repeat(SKAction.sequence([
            SKAction.run { [weak scene] in
                guard let gameScene = scene as? GameScene else { return }
                for target in gameScene.goblinManager.goblinContainers {
                    let distance = target.sprite.position.distance(to: goblin.sprite.position)
                    if distance <= spell.aoeRadius {
                        target.applyDamage(damagePerTick)
                    }
                }
            },
            SKAction.wait(forDuration: 1.0)
        ]), count: Int(spell.duration))
        
        scene.run(tickAction)
    }
}
