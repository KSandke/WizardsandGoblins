import Foundation
import SpriteKit

class HologramTrapSpecial: Special {
    init() {
        super.init(
            name: "HologramTrap",
            aoeRadius: 70,
            aoeColor: .cyan,
            duration: 3.0,
            damage: 30,
            effect: HologramTrapEffect(),
            cooldown: 25.0,
            targetingMode: .global,
            rarity: .uncommon
        )
    }
}

class HologramTrapEffect: SpellEffect {
    func apply(spell: Spell, on goblin: Goblin.GoblinContainer) {
        guard let scene = goblin.sprite.scene as? GameScene else { return }

        // Create hologram projector
        let projector = SKSpriteNode(color: .blue, size: CGSize(width: 20, height: 20))
        projector.position = goblin.sprite.position
        projector.alpha = 0.7
        scene.addChild(projector)

        // Generate holographic duplicates
        let duplicateCount = 6
        var duplicates: [SKSpriteNode] = []

        for i in 0..<duplicateCount {
            let duplicate = SKSpriteNode(texture: goblin.sprite.texture)
            duplicate.size = goblin.sprite.size

            // Position in hexagonal pattern
            let angle = (CGFloat(i) / CGFloat(duplicateCount)) * 2 * .pi
            let radius: CGFloat = 60
            duplicate.position = CGPoint(
                x: projector.position.x + cos(angle) * radius,
                y: projector.position.y + sin(angle) * radius
            )

            duplicate.alpha = 0.8
            duplicate.color = .cyan
            duplicate.colorBlendFactor = 0.3
            scene.addChild(duplicate)
            duplicates.append(duplicate)

            // Hologram flicker effect
            duplicate.run(SKAction.repeatForever(SKAction.sequence([
                SKAction.fadeAlpha(to: 0.4, duration: 0.1),
                SKAction.fadeAlpha(to: 0.8, duration: 0.1)
            ])))
        }

        // Hologram behavior
        var time: CGFloat = 0
        let trapTimer = Timer.scheduledTimer(withTimeInterval: 1/60, repeats: true) { _ in
            time += 0.02

            // Rotate duplicates
            for (index, duplicate) in duplicates.enumerated() {
                let angle = time + (CGFloat(index) / CGFloat(duplicateCount)) * 2 * .pi
                let radius: CGFloat = 60 + sin(time * 2) * 10

                duplicate.position = CGPoint(
                    x: projector.position.x + cos(angle) * radius,
                    y: projector.position.y + sin(angle) * radius
                )

                // Check for enemies entering the trap
                for target in scene.goblinManager.goblinContainers {
                    if target.sprite.position.distance(to: duplicate.position) < 30 {
                        // Hologram explosion
                        let explosion = HologramExplosionEmitter(at: duplicate.position)
                        scene.addChild(explosion)

                        target.applyDamage(spell.damage)

                        // Digital disruption effect
                        target.sprite.run(SKAction.sequence([
                            SKAction.colorize(with: .cyan, colorBlendFactor: 0.8, duration: 0.2),
                            SKAction.colorize(with: .clear, colorBlendFactor: 0, duration: 0.2)
                        ]))

                        // Remove the triggered hologram
                        duplicate.removeFromParent()
                        duplicates.remove(at: index)
                        break
                    }
                }
            }
        }

        // Cleanup
        DispatchQueue.main.asyncAfter(deadline: .now() + spell.duration) {
            trapTimer.invalidate()
            projector.removeFromParent()
            for duplicate in duplicates {
                duplicate.removeFromParent()
            }
        }
    }
}