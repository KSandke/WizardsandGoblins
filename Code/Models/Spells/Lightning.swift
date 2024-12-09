import Foundation
import SpriteKit

class LightningSpell: Spell {
    init() {
        super.init(
            name: "LightningSpell",
            aoeRadius: 40,
            aoeColor: .yellow,
            duration: 1.0,
            damage: 30,
            effect: LightningEffect(),
            rarity: .rare
        )
    }
}

class LightningEffect: SpellEffect {
    func apply(spell: Spell, on goblin: Goblin.GoblinContainer) {
        let chainRange: CGFloat = 100.0
        let chainDamage = spell.damage * 0.5
        let effectDuration: TimeInterval = 0.5

        if let gameScene = goblin.sprite.scene as? GameScene {
            // Find all affected goblins first
            let nearbyGoblins = gameScene.goblinManager.goblinContainers.filter { otherGoblin in
                return otherGoblin !== goblin &&
                    otherGoblin.sprite.position.distance(to: goblin.sprite.position) <= chainRange
            }

            // Apply initial strike to main target
            createLightningStrike(at: goblin.sprite.position, in: gameScene) {
                // After initial strike, create chain effects to nearby targets
                for (index, targetGoblin) in nearbyGoblins.enumerated() {
                    let chainDelay = 0.1 * Double(index)
                    DispatchQueue.main.asyncAfter(deadline: .now() + chainDelay) {
                        self.createLightningBolt(
                            from: goblin.sprite.position,
                            to: targetGoblin.sprite.position,
                            in: gameScene
                        ) {
                            self.createLightningStrike(
                                at: targetGoblin.sprite.position,
                                in: gameScene,
                                completion: nil
                            )
                        }
                    }
                }
            }

            // Apply gameplay effects to all targets
            let affectedGoblins = [goblin] + nearbyGoblins
            for affectedGoblin in affectedGoblins {
                // First, stop ALL current actions and attacks
                affectedGoblin.sprite.removeAllActions()  // This ensures all movement stops
                affectedGoblin.pauseAttacks()
                affectedGoblin.stopAttacking()

                // Apply damage
                if affectedGoblin === goblin {
                    affectedGoblin.applyDamage(spell.damage)
                } else {
                    affectedGoblin.applyDamage(chainDamage)
                }

                // Add visual feedback for stun
                let stunEffect = SKAction.sequence([
                    SKAction.colorize(with: .yellow, colorBlendFactor: 0.5, duration: 0.1),
                    SKAction.wait(forDuration: effectDuration - 0.2),
                    SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.1)
                ])
                affectedGoblin.sprite.run(stunEffect, withKey: "stunEffect")  // Add specific key for stun effect

                // Resume movement and attacks after stun duration
                DispatchQueue.main.asyncAfter(deadline: .now() + effectDuration) {
                    guard affectedGoblin.sprite.parent != nil else { return }
                    
                    let currentPos = affectedGoblin.sprite.position
                    let targetPosition = CGPoint(x: gameScene.size.width / 2, y: 100)
                    let remainingDistance = currentPos.distance(to: targetPosition)
                    
                    if remainingDistance > 0 {
                        let speed = gameScene.goblinManager.goblinSpeed(for: affectedGoblin.type)
                        let remainingDuration = TimeInterval(remainingDistance / speed)
                        
                        let moveAction = SKAction.move(to: targetPosition, duration: remainingDuration)
                        let startAttackAction = SKAction.run {
                            affectedGoblin.resumeAttacks()
                            affectedGoblin.startAttacking()
                        }
                        
                        let sequence = SKAction.sequence([moveAction, startAttackAction])
                        affectedGoblin.sprite.run(sequence, withKey: "movement")
                    } else {
                        // If already at target position, just resume attacks
                        affectedGoblin.resumeAttacks()
                        affectedGoblin.startAttacking()
                    }
                }
            }
        }
    }

    private func createLightningStrike(at position: CGPoint, in scene: SKScene, completion: (() -> Void)?) {
        if let strikeEffect = SKEmitterNode(fileNamed: "LightningStrike") {
            strikeEffect.position = position
            scene.addChild(strikeEffect)

            // Remove effect after duration
            let wait = SKAction.wait(forDuration: 0.2)
            let cleanup = SKAction.run {
                strikeEffect.removeFromParent()
                completion?()
            }
            strikeEffect.run(SKAction.sequence([wait, cleanup]))
        }
    }

    private func createLightningBolt(from start: CGPoint, to end: CGPoint, in scene: SKScene, completion: @escaping () -> Void) {
        // Create the emitter node for the bolt
        if let boltEffect = SKEmitterNode(fileNamed: "LightningBolt") {
            // Calculate the angle and distance
            let dx = end.x - start.x
            let dy = end.y - start.y
            let angle = atan2(dy, dx)
            let distance = sqrt(dx * dx + dy * dy)

            // Configure the emitter
            boltEffect.position = start
            boltEffect.emissionAngle = angle
            boltEffect.particlePositionRange = CGVector(dx: distance, dy: 2)
            scene.addChild(boltEffect)

            // Remove after short duration
            let wait = SKAction.wait(forDuration: 0.1)
            let cleanup = SKAction.run {
                boltEffect.removeFromParent()
                completion()
            }
            boltEffect.run(SKAction.sequence([wait, cleanup]))
        }
    }
}