import Foundation
import SpriteKit

class FireballSpell: Spell {
    init() {
        super.init(
            name: "Fireball",
            aoeRadius: 50,
            aoeColor: .orange,
            duration: 1.0,
            damage: 25,
            effect: DefaultEffect(),
            rarity: .common
        )
    }
}