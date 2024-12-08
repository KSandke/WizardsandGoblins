import Foundation
import SpriteKit

class BlizzardSpecial: Special {
    init() {
        super.init(
            name: "Blizzard",
            aoeRadius: 150,
            aoeColor: .white,
            duration: 8.0,
            damage: 40,
            effect: BlizzardEffect(),
            cooldown: 60.0,
            targetingMode: .global,
            rarity: .epic
        )
    }
}

class BlizzardEffect: SpellEffect {
    func apply(spell: Spell, on goblin: Goblin.GoblinContainer) {
        guard let scene = goblin.sprite.scene else { return }
        
        let blizzard = BlizzardEmitter(at: goblin.sprite.position)
        scene.addChild(blizzard)
        
        // Slow and damage affected goblins
        let damagePerTick = spell.damage / CGFloat(spell.duration)
        let tickAction = SKAction.repeat(SKAction.sequence([
            SKAction.run { [weak scene] in
                guard let gameScene = scene as? GameScene else { return }
                for target in gameScene.goblinManager.goblinContainers {
                    let distance = target.sprite.position.distance(to: goblin.sprite.position)
                    if distance <= spell.aoeRadius {
                        target.sprite.speed = 0.5
                        target.applyDamage(damagePerTick)
                    }
                }
            },
            SKAction.wait(forDuration: 1.0)
        ]), count: Int(spell.duration))
        
        scene.run(tickAction)
        
        // Restore normal speed after duration
        DispatchQueue.main.asyncAfter(deadline: .now() + spell.duration) {
            guard let gameScene = scene as? GameScene else { return }
            for target in gameScene.goblinManager.goblinContainers {
                let distance = target.sprite.position.distance(to: goblin.sprite.position)
                if distance <= spell.aoeRadius {
                    target.sprite.speed = 1.0
                }
            }
        }
    }
}