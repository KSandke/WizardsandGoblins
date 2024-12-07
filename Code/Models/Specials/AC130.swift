import Foundation
import SpriteKit

class AC130Special: Special {
    init() {
        super.init(
            name: "AC130",
            aoeRadius: 80,
            aoeColor: .darkGray,
            duration: 6.0,
            damage: 35,
            effect: AC130Effect(),
            cooldown: 45.0,
            targetingMode: .area,
            rarity: .legendary
        )
    }
}

class AC130Effect: SpellEffect {
    func apply(spell: Special, on goblin: Goblin.GoblinContainer) {
        guard let scene = goblin.sprite.scene as? GameScene else { return }

        // Create AC130 sprite
        let ac130 = SKSpriteNode(color: .darkGray, size: CGSize(width: 120, height: 40))
        ac130.position = CGPoint(x: scene.frame.maxX + 100, y: scene.frame.maxY - 100)
        ac130.zRotation = -.pi / 12
        scene.addChild(ac130)

        // Thermal vision overlay
        let thermalOverlay = SKShapeNode(rect: scene.frame)
        thermalOverlay.fillColor = .black
        thermalOverlay.alpha = 0.3
        scene.addChild(thermalOverlay)

        // Different weapon systems
        let weapons = [
            ("25mm", 0.2, spell.damage * 0.3, 10.0),  // Fast, light damage
            ("40mm", 0.5, spell.damage * 0.6, 20.0),  // Medium
            ("105mm", 1.0, spell.damage, 40.0)        // Slow, heavy damage
        ]

        var currentWeapon = 0

        // Circling behavior
        let radius: CGFloat = 300
        var angle: CGFloat = 0

        let flightTimer = Timer.scheduledTimer(withTimeInterval: 1/60, repeats: true) { _ in
            angle += 0.01
            let center = goblin.sprite.position
            ac130.position = CGPoint(
                x: center.x + cos(angle) * radius,
                y: center.y + sin(angle) * radius + 200
            )
            ac130.zRotation = angle - .pi / 2
        }

        // Firing sequence
        let fireTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            let (_, fireRate, damage, shellSize) = weapons[currentWeapon]

            // Create shell
            let shell = SKShapeNode(circleOfRadius: shellSize/2)
            shell.fillColor = .yellow
            shell.position = ac130.position
            scene.addChild(shell)

            // Add tracer effect
            let tracer = TracerEffectEmitter(at: shell.position, angle: atan2(
                goblin.sprite.position.y - shell.position.y,
                goblin.sprite.position.x - shell.position.x
            ))
            scene.addChild(tracer)

            // Calculate impact point with spread
            let spread = CGFloat.random(in: -20...20)
            let impactPoint = CGPoint(
                x: goblin.sprite.position.x + spread,
                y: goblin.sprite.position.y + spread
            )

            shell.run(SKAction.sequence([
                SKAction.move(to: impactPoint, duration: fireRate),
                SKAction.run {
                    // Explosion
                    let explosion = SKShapeNode(circleOfRadius: shellSize * 2)
                    explosion.fillColor = .orange
                    explosion.strokeColor = .red
                    explosion.position = impactPoint
                    scene.addChild(explosion)

                    // Area damage
                    for target in scene.goblinManager.goblinContainers {
                        if target.sprite.position.distance(to: impactPoint) < shellSize * 2 {
                            target.applyDamage(damage)
                        }
                    }

                    // Crater effect
                    let crater = SKShapeNode(circleOfRadius: shellSize)
                    crater.fillColor = .black
                    crater.alpha = 0.3
                    crater.position = impactPoint
                    scene.addChild(crater)

                    explosion.run(SKAction.sequence([
                        SKAction.fadeOut(withDuration: 0.3),
                        SKAction.removeFromParent()
                    ]))

                    tracer.removeFromParent()
                },
                SKAction.removeFromParent()
            ]))

            // Cycle weapons
            currentWeapon = (currentWeapon + 1) % weapons.count
        }

        // Cleanup
        DispatchQueue.main.asyncAfter(deadline: .now() + spell.duration) {
            flightTimer.invalidate()
            fireTimer.invalidate()
            ac130.removeFromParent()
            thermalOverlay.removeFromParent()
        }
    }
}
