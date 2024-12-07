import Foundation
import SpriteKit

class PredatorMissile: Special {
    init() {
        super.init(
            name: "PredatorMissile",
            aoeRadius: 60,
            aoeColor: .red,
            duration: 2.0,
            damage: 45,
            effect: PredatorMissileEffect(),
            cooldown: 30.0,  // 30 second cooldown
            targetingMode: .direct,
            rarity: .epic
        )
    }
}

class PredatorMissileEffect: SpellEffect {
    func apply(spell: Spell, on goblin: Goblin.GoblinContainer) {
        guard let scene = goblin.sprite.scene as? GameScene else { return }

        // Drone camera view
        let cameraView = SKShapeNode(rect: CGRect(x: -150, y: -150, width: 300, height: 300))
        cameraView.strokeColor = .white
        cameraView.lineWidth = 2
        scene.addChild(cameraView)

        // HUD elements
        let crosshair = SKSpriteNode(imageNamed: "predator_crosshair")
        crosshair.position = goblin.sprite.position
        crosshair.setScale(0.5)
        scene.addChild(crosshair)

        // Missile launch
        let missile = SKSpriteNode(color: .gray, size: CGSize(width: 30, height: 8))
        missile.position = CGPoint(x: scene.frame.maxX, y: scene.frame.maxY)
        scene.addChild(missile)

        // Target tracking
        var targetPos = goblin.sprite.position
        var trackingTimer: Timer?
        trackingTimer = Timer.scheduledTimer(withTimeInterval: 1/60, repeats: true) { _ in
            targetPos = goblin.sprite.position
            crosshair.position = targetPos

            // Update missile direction
            let direction = CGPoint(
                x: targetPos.x - missile.position.x,
                y: targetPos.y - missile.position.y
            ).normalized()
            missile.zRotation = atan2(direction.y, direction.x)

            // Move missile
            let speed: CGFloat = 15
            missile.position = CGPoint(
                x: missile.position.x + direction.x * speed,
                y: missile.position.y + direction.y * speed
            )

            // Check for impact
            if missile.position.distance(to: targetPos) < 10 {
                trackingTimer?.invalidate()

                // Explosion
                let explosion = MissileExplosionEmitter(at: missile.position)
                scene.addChild(explosion)

                // Area damage
                for target in scene.goblinManager.goblinContainers {
                    if target.sprite.position.distance(to: missile.position) < spell.aoeRadius {
                        let distance = target.sprite.position.distance(to: missile.position)
                        let falloff = 1 - (distance / spell.aoeRadius)
                        target.applyDamage(spell.damage * falloff)
                    }
                }

                // Cleanup explosion
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    explosion.run(SKAction.sequence([
                        SKAction.fadeOut(withDuration: 0.3),
                        SKAction.removeFromParent()
                    ]))
                }

                missile.removeFromParent()
                crosshair.removeFromParent()
                cameraView.removeFromParent()
            }
        }

        // Failsafe cleanup
        DispatchQueue.main.asyncAfter(deadline: .now() + spell.duration) {
            trackingTimer?.invalidate()
            missile.removeFromParent()
            crosshair.removeFromParent()
            cameraView.removeFromParent()
        }
    }
}