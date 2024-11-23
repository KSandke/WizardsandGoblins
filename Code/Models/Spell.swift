import Foundation
import SpriteKit

class Spell {
    let name: String
    var aoeRadius: CGFloat
    var duration: TimeInterval
    var damage: CGFloat
    let effect: SpellEffect?

    init(name: String, aoeRadius: CGFloat, duration: TimeInterval, damage: CGFloat, effect: SpellEffect?) {
        self.name = name
        self.aoeRadius = aoeRadius
        self.duration = duration
        self.damage = damage
        self.effect = effect
    }

    func cast(from casterPosition: CGPoint, to targetPosition: CGPoint, by playerState: PlayerState, isPlayerOne: Bool, in scene: SKScene) -> Bool {
        if !playerState.useSpell(isPlayerOne: isPlayerOne, cost: 1) {
            return false
        }

        let spellNode = SKSpriteNode(imageNamed: name)
        spellNode.size = CGSize(width: 50, height: 50)
        spellNode.position = casterPosition
        scene.addChild(spellNode)

        let dx = targetPosition.x - casterPosition.x
        let dy = targetPosition.y - casterPosition.y
        let angle = atan2(dy, dx)
        spellNode.zRotation = angle + .pi / 2 + .pi

        let distance = casterPosition.distance(to: targetPosition)
        let baseSpeed: CGFloat = 400
        let travelDuration = TimeInterval(distance / baseSpeed)

        let moveAction = SKAction.move(to: targetPosition, duration: travelDuration)
        let applyEffect = SKAction.run { [weak self, weak scene] in
            guard let self = self, let scene = scene else { return }
            self.applyEffect(at: targetPosition, in: scene)
        }
        let removeSpell = SKAction.removeFromParent()

        let sequence = SKAction.sequence([moveAction, applyEffect, removeSpell])
        spellNode.run(sequence)

        return true
    }

    func applyEffect(at position: CGPoint, in scene: SKScene) {
        let aoeCircle = SKShapeNode(circleOfRadius: aoeRadius)
        aoeCircle.fillColor = .orange
        aoeCircle.strokeColor = .clear
        aoeCircle.alpha = 0.5
        aoeCircle.position = position
        aoeCircle.zPosition = 1
        scene.addChild(aoeCircle)

        if let gameScene = scene as? GameScene {
            let modifiedSpell = Spell(
                name: self.name,
                aoeRadius: self.aoeRadius,
                duration: self.duration,
                damage: self.damage * gameScene.playerState.spellPowerMultiplier,
                effect: self.effect
            )
            gameScene.applySpell(modifiedSpell, at: position)
        }

        let fadeOut = SKAction.fadeOut(withDuration: duration)
        let remove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([fadeOut, remove])

        aoeCircle.run(sequence)
    }

    func applySpecialEffect(on goblin: Goblin.GoblinContainer) {
        if let effect = effect {
            effect.apply(spell: self, on: goblin)
        } else {
            // Default action: apply damage
            goblin.applyDamage(self.damage)
        }
    }
}

protocol SpellEffect {
    func apply(spell: Spell, on goblin: Goblin.GoblinContainer)
}

// Predefined Spell Classes

class FireballSpell: Spell {
    init() {
        super.init(
            name: "Fireball",
            aoeRadius: 50,
            duration: 1.0,
            damage: 25,
            effect: DefaultEffect()
        )
    }
}

class IceSpell: Spell {
    init() {
        super.init(
            name: "IceSpell",
            aoeRadius: 50,
            duration: 1.0,
            damage: 20,
            effect: IceEffect()
        )
    }
}

class LightningSpell: Spell {
    init() {
        super.init(
            name: "LightningSpell",
            aoeRadius: 40,
            duration: 1.0,
            damage: 30,
            effect: LightningEffect()
        )
    }
}

class PoisonCloudSpell: Spell {
    init() {
        super.init(
            name: "PoisonCloud",
            aoeRadius: 80,
            duration: 5.0,
            damage: 10,
            effect: PoisonEffect()
        )
    }
}

class AC130Spell: Spell {
    init() {
        super.init(
            name: "AC130",
            aoeRadius: 80,
            duration: 6.0,
            damage: 35,
            effect: AC130Effect()
        )
    }
}

class TacticalNukeSpell: Spell {
    init() {
        super.init(
            name: "TacticalNuke",
            aoeRadius: 200,
            duration: 3.0,
            damage: 100,
            effect: TacticalNukeEffect()
        )
    }
}

class PredatorMissileSpell: Spell {
    init() {
        super.init(
            name: "PredatorMissile",
            aoeRadius: 60,
            duration: 2.0,
            damage: 45,
            effect: PredatorMissileEffect()
        )
    }
}

class DriveBySpell: Spell {
    init() {
        super.init(
            name: "DriveBy",
            aoeRadius: 40,
            duration: 3.0,
            damage: 15,
            effect: DriveByEffect()
        )
    }
}

class DroneSwarmSpell: Spell {
    init() {
        super.init(
            name: "DroneSwarm",
            aoeRadius: 150,
            duration: 5.0,
            damage: 20,
            effect: DroneSwarmEffect()
        )
    }
}

class CrucifixionSpell: Spell {
    init() {
        super.init(
            name: "Crucifixion",
            aoeRadius: 60,
            duration: 4.0,
            damage: 40,
            effect: CrucifixionEffect()
        )
    }
}

// class MindControlSpell: Spell {
//     init() {
//         super.init(
//             name: "MindControlSpell",
//             aoeRadius: 60,
//             duration: 8.0,
//             damage: 0,
//             effect: MindControlEffect()
//         )
//     }
// }

class RiftWalkerSpell: Spell {
    init() {
        super.init(
            name: "RiftWalkerSpell",
            aoeRadius: 40,
            duration: 0.5,
            damage: 15,
            effect: RiftWalkerEffect()
        )
    }
}

class SwarmQueenSpell: Spell {
    init() {
        super.init(
            name: "SwarmQueenSpell",
            aoeRadius: 120,
            duration: 6.0,
            damage: 5,
            effect: SwarmQueenEffect()
        )
    }
}

class NanoSwarmSpell: Spell {
    init() {
        super.init(
            name: "NanoSwarm",
            aoeRadius: 100,
            duration: 5.0,
            damage: 25,
            effect: NanoSwarmEffect()
        )
    }
}

class HologramTrapSpell: Spell {
    init() {
        super.init(
            name: "HologramTrap",
            aoeRadius: 70,
            duration: 3.0,
            damage: 30,
            effect: HologramTrapEffect()
        )
    }
}

class SystemOverrideSpell: Spell {
    init() {
        super.init(
            name: "SystemOverride",
            aoeRadius: 120,
            duration: 4.0,
            damage: 15,
            effect: SystemOverrideEffect()
        )
    }
}

class CyberneticOverloadSpell: Spell {
    init() {
        super.init(
            name: "Cybernetic Overload",
            damage: 30,
            aoeRadius: 100,
            duration: 5.0,
            effect: CyberneticOverloadEffect()
        )
    }
}

class SteampunkTimeBombSpell: Spell {
    init() {
        super.init(
            name: "Steampunk Time Bomb",
            damage: 50,
            aoeRadius: 150,
            duration: 3.0,
            effect: SteampunkTimeBombEffect()
        )
    }
}

class IronMaidenSpell: Spell {
    init() {
        super.init(
            name: "Iron Maiden",
            damage: 35,
            aoeRadius: 15,
            duration: 8.0,
            effect: IronMaidenEffect()
        )
    }
}

class ShadowPuppetSpell: Spell {
    init() {
        super.init(
            name: "Shadow Puppet",
            damage: 0,
            aoeRadius: 0,
            duration: 10.0,
            effect: ShadowPuppetEffect()
        )
    }
}

class TemporalDistortionSpell: Spell {
    init() {
        super.init(
            name: "Temporal Distortion",
            damage: 0,
            aoeRadius: 120,
            duration: 5.0,
            effect: TemporalDistortionEffect()
        )
    }
}

class QuantumCollapseSpell: Spell {
    init() {
        super.init(
            name: "Quantum Collapse",
            damage: 50,
            aoeRadius: 100,
            duration: 3.0,
            effect: QuantumCollapseEffect()
        )
    }
}

class BloodMoonSpell: Spell {
    init() {
        super.init(
            name: "Blood Moon",
            damage: 35,
            aoeRadius: 120,
            duration: 5.0,
            effect: BloodMoonEffect()
        )
    }
}

class EarthShatterSpell: Spell {
    init() {
        super.init(
            name: "Earth Shatter",
            damage: 40,
            aoeRadius: 100,
            duration: 0,
            effect: EarthShatterEffect()
        )
    }
}

class MysticBarrierSpell: Spell {
    init() {
        super.init(
            name: "Mystic Barrier",
            damage: 20,
            aoeRadius: 80,
            duration: 8.0,
            effect: MysticBarrierEffect()
        )
    }
}

// Spell Effect Implementations

class DefaultEffect: SpellEffect {
    func apply(spell: Spell, on goblin: Goblin.GoblinContainer) {
        goblin.applyDamage(spell.damage)
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
                    // Small delay between each chain
                    let chainDelay = 0.1 * Double(index)
                    DispatchQueue.main.asyncAfter(deadline: .now() + chainDelay) {
                        // Create lightning bolt to next target
                        self.createLightningBolt(
                            from: goblin.sprite.position,
                            to: targetGoblin.sprite.position,
                            in: gameScene
                        ) {
                            // Create strike effect on chained target
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
                // Stop the goblin movement and attacks
                let originalSpeed = affectedGoblin.sprite.speed
                affectedGoblin.sprite.speed = 0
                affectedGoblin.pauseAttacks()

                // Apply damage
                if affectedGoblin === goblin {
                    affectedGoblin.applyDamage(spell.damage)
                } else {
                    affectedGoblin.applyDamage(chainDamage)
                }

                // Reset after duration
                DispatchQueue.main.asyncAfter(deadline: .now() + effectDuration) {
                    affectedGoblin.sprite.speed = originalSpeed
                    affectedGoblin.resumeAttacks()
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

class PoisonEffect: SpellEffect {
    func apply(spell: Spell, on goblin: Goblin.GoblinContainer) {
        // Initial damage
        goblin.applyDamage(spell.damage)

        // Apply damage over time
        let damageInterval: TimeInterval = 1.0
        let numberOfTicks = Int(spell.duration / damageInterval)

        for tick in 1...numberOfTicks {
            let wait = SKAction.wait(forDuration: damageInterval * Double(tick))
            let applyDamage = SKAction.run {
                goblin.applyDamage(spell.damage)
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

class AC130Effect: SpellEffect {
    func apply(spell: Spell, on goblin: Goblin.GoblinContainer) {
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

class TacticalNukeEffect: SpellEffect {
    func apply(spell: Spell, on goblin: Goblin.GoblinContainer) {
        guard let scene = goblin.sprite.scene as? GameScene else { return }

        // Warning siren
        let warning = SKAudioNode(fileNamed: "nuclear_siren.mp3")
        scene.addChild(warning)

        // Create targeting reticle
        let reticle = SKShapeNode(circleOfRadius: spell.aoeRadius)
        reticle.strokeColor = .red
        reticle.position = goblin.sprite.position
        reticle.lineWidth = 2
        scene.addChild(reticle)

        reticle.run(SKAction.sequence([
            SKAction.repeatForever(SKAction.sequence([
                SKAction.fadeOut(withDuration: 0.5),
                SKAction.fadeIn(withDuration: 0.5)
            ])),
            SKAction.wait(forDuration: 2.0),
            SKAction.removeFromParent()
        ]))

        // Launch sequence
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // Initial flash
            let whiteout = SKSpriteNode(color: .white, size: scene.frame.size)
            whiteout.position = CGPoint(x: scene.frame.midX, y: scene.frame.midY)
            whiteout.zPosition = 100
            scene.addChild(whiteout)

            // Mushroom cloud
            let cloud = NukeCloudEmitter(at: goblin.sprite.position)
            scene.addChild(cloud)

            // Shockwave
            let shockwave = SKShapeNode(circleOfRadius: 1)
            shockwave.position = goblin.sprite.position
            shockwave.strokeColor = .white
            shockwave.lineWidth = 4
            scene.addChild(shockwave)

            shockwave.run(SKAction.sequence([
                SKAction.scale(to: spell.aoeRadius * 2, duration: 1.0),
                SKAction.removeFromParent()
            ]))

            // Apply damage in waves
            for radius in stride(from: 0, to: spell.aoeRadius, by: 20) {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(radius)/200.0) {
                    for target in scene.goblinManager.goblinContainers {
                        let distance = target.sprite.position.distance(to: goblin.sprite.position)
                        if distance < radius {
                            let falloff = 1 - (distance / spell.aoeRadius)
                            target.applyDamage(spell.damage * falloff)

                            // Radiation effect
                            target.sprite.color = .green
                            target.sprite.colorBlendFactor = 0.3
                            target.damage *= 0.8 // Weakened by radiation
                        }
                    }
                }
            }

            // Cleanup
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                whiteout.removeFromParent()
                cloud.run(SKAction.sequence([
                    SKAction.fadeOut(withDuration: 0.5),
                    SKAction.removeFromParent()
                ]))
                warning.removeFromParent()
            }
        }
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

class DriveByEffect: SpellEffect {
    func apply(spell: Spell, on goblin: Goblin.GoblinContainer) {
        guard let scene = goblin.sprite.scene as? GameScene else { return }

        // Create the "car"
        let car = SKSpriteNode(color: .black, size: CGSize(width: 60, height: 30))
        car.position = CGPoint(x: -100, y: goblin.sprite.position.y)
        scene.addChild(car)

        // Create muzzle flash effect
        let flash = SKSpriteNode(color: .yellow, size: CGSize(width: 20, height: 10))
        flash.position = CGPoint(x: car.frame.maxX, y: car.position.y)
        flash.alpha = 0
        scene.addChild(flash)

        // Drive-by sequence
        let driveAction = SKAction.sequence([
            SKAction.moveTo(x: scene.frame.maxX + 100, duration: spell.duration),
            SKAction.removeFromParent()
        ])

        // Shooting logic
        var shotsFired = 0
        var shootTimer: Timer?
        shootTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            // Muzzle flash
            flash.position.x = car.position.x + 35
            flash.position.y = car.position.y
            flash.run(SKAction.sequence([
                SKAction.fadeIn(withDuration: 0.05),
                SKAction.fadeOut(withDuration: 0.05)
            ]))

            // Create bullet
            let bullet = SKShapeNode(circleOfRadius: 2)
            bullet.fillColor = .yellow
            bullet.position = car.position
            scene.addChild(bullet)

            // Random spread
            let spread = CGFloat.random(in: -10...10)
            let bulletSpeed: CGFloat = 500
            let bulletVector = CGVector(dx: bulletSpeed, dy: spread)

            bullet.run(SKAction.sequence([
                SKAction.move(by: bulletVector, duration: 0.5),
                SKAction.removeFromParent()
            ]))

            // Damage check
            for target in scene.goblinManager.goblinContainers {
                if target.sprite.position.distance(to: bullet.position) < spell.aoeRadius {
                    target.applyDamage(spell.damage)

                    // Blood particle effect
                    let blood = BloodParticleEmitter(at: target.sprite.position)
                    scene.addChild(blood)
                    blood.run(SKAction.sequence([
                        SKAction.wait(forDuration: 0.2),
                        SKAction.removeFromParent()
                    ]))
                }
            }

            shotsFired += 1
            if shotsFired > 30 { // Limit total shots
                shootTimer?.invalidate()
            }
        }

        car.run(driveAction)
    }
}

class DroneSwarmEffect: SpellEffect {
    func apply(spell: Spell, on goblin: Goblin.GoblinContainer) {
        guard let scene = goblin.sprite.scene as? GameScene else { return }

        let droneCount = 8
        var drones: [SKSpriteNode] = []

        // Spawn drones in formation
        for i in 0..<droneCount {
            let drone = SKSpriteNode(color: .darkGray, size: CGSize(width: 20, height: 20))
            let angle = (CGFloat(i) / CGFloat(droneCount)) * 2 * .pi
            let radius: CGFloat = 100

            drone.position = CGPoint(
                x: goblin.sprite.position.x + cos(angle) * radius,
                y: goblin.sprite.position.y + sin(angle) * radius + 200 // Start above
            )

            scene.addChild(drone)
            drones.append(drone)

            // Targeting laser
            let laser = SKShapeNode()
            laser.strokeColor = .red
            laser.alpha = 0.5
            scene.addChild(laser)

            // Drone behavior
            let updateLaser = SKAction.customAction(withDuration: spell.duration) { node, time in
                let path = CGMutablePath()
                path.move(to: drone.position)
                path.addLine(to: goblin.sprite.position)
                laser.path = path
            }

            laser.run(SKAction.sequence([
                updateLaser,
                SKAction.removeFromParent()
            ]))
        }

        // Drone strike sequence
        let strikeDelay = spell.duration / TimeInterval(droneCount)

        for (index, drone) in drones.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + strikeDelay * Double(index)) {
                // Strike animation
                drone.run(SKAction.sequence([
                    SKAction.move(to: goblin.sprite.position, duration: 0.2),
                    SKAction.run {
                        // Explosion effect
                        let explosion = SKShapeNode(circleOfRadius: spell.aoeRadius)
                        explosion.fillColor = .orange
                        explosion.strokeColor = .red
                        explosion.position = goblin.sprite.position
                        explosion.alpha = 0.7
                        scene.addChild(explosion)

                        // Area damage
                        for target in scene.goblinManager.goblinContainers {
                            if target.sprite.position.distance(to: explosion.position) < spell.aoeRadius {
                                target.applyDamage(spell.damage)
                            }
                        }

                        explosion.run(SKAction.sequence([
                            SKAction.fadeOut(withDuration: 0.3),
                            SKAction.removeFromParent()
                        ]))
                    },
                    SKAction.removeFromParent()
                ]))
            }
        }
    }
}

class CrucifixionEffect: SpellEffect {
    func apply(spell: Spell, on goblin: Goblin.GoblinContainer) {
        guard let scene = goblin.sprite.scene as? GameScene else { return }

        // Store original position and state
        let originalPosition = goblin.sprite.position
        let originalZRotation = goblin.sprite.zRotation
        
        // Create cross
        let cross = SKSpriteNode(color: .brown, size: CGSize(width: 20, height: 100))
        cross.position = originalPosition
        scene.addChild(cross)

        // Horizontal beam
        let beam = SKSpriteNode(color: .brown, size: CGSize(width: 60, height: 20))
        beam.position = CGPoint(x: cross.position.x, y: cross.position.y + 20)
        scene.addChild(beam)

        // Bind target to cross
        goblin.sprite.position = CGPoint(x: cross.position.x, y: cross.position.y + 20)
        goblin.sprite.zRotation = 0
        
        // Disable movement
        let originalPhysicsBody = goblin.sprite.physicsBody
        goblin.sprite.physicsBody = nil
        goblin.pauseAttacks()

        // Create binding chains/nails effect
        let chainPoints = [
            CGPoint(x: -20, y: 0),  // Left hand
            CGPoint(x: 20, y: 0),   // Right hand
            CGPoint(x: 0, y: -30)   // Feet
        ]

        for point in chainPoints {
            let nail = SKShapeNode(circleOfRadius: 3)
            nail.fillColor = .gray
            nail.position = CGPoint(
                x: goblin.sprite.position.x + point.x,
                y: goblin.sprite.position.y + point.y
            )
            scene.addChild(nail)

            // Blood drip effect
            let drip = BloodDripEmitter(at: nail.position)
            scene.addChild(drip)

            // Cleanup
            DispatchQueue.main.asyncAfter(deadline: .now() + spell.duration) {
                nail.removeFromParent()
                drip.removeFromParent()
            }
        }

        // Damage over time
        let damageTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            goblin.applyDamage(spell.damage / 8)

            // Affect nearby enemies with fear (slow + damage reduction)
            for target in scene.goblinManager.goblinContainers {
                if target !== goblin && target.sprite.position.distance(to: cross.position) < spell.aoeRadius {
                    target.sprite.speed *= 0.9
                }
            }
        }

        // Cleanup
        DispatchQueue.main.asyncAfter(deadline: .now() + spell.duration) {
            damageTimer.invalidate()
            cross.removeFromParent()
            beam.removeFromParent()
            
            // Restore original state
            goblin.sprite.position = originalPosition
            goblin.sprite.zRotation = originalZRotation
            goblin.sprite.physicsBody = originalPhysicsBody
            goblin.resumeAttacks()

            // Reset affected enemies
            for target in scene.goblinManager.goblinContainers {
                target.sprite.speed = 1.0
            }
        }
    }
}

// class MindControlEffect: SpellEffect {
//     func apply(spell: Spell, on goblin: Goblin.GoblinContainer) {
//         guard let scene = goblin.sprite.scene as? GameScene else { return }

//         // Visual indicator
//         let controlRing = SKShapeNode(circleOfRadius: 25)
//         controlRing.strokeColor = .magenta
//         controlRing.lineWidth = 3
//         controlRing.position = goblin.sprite.position
//         scene.addChild(controlRing)

//         // Store original properties
//         let originalColor = goblin.sprite.color
//         let originalBlend = goblin.sprite.colorBlendFactor

//         // Mark as controlled
//         goblin.sprite.color = .magenta
//         goblin.sprite.colorBlendFactor = 0.5

//         // Override goblin's behavior
//         let originalUpdate = goblin.update // Store original update if it exists
//         goblin.update = { [weak goblin, weak scene] deltaTime in
//             guard let goblin = goblin, let scene = scene else { return }

//             // Find nearest other goblin
//             if let nearestGoblin = scene.goblinManager.goblinContainers
//                 .filter({ $0 !== goblin })
//                 .min(by: { $0.sprite.position.distance(to: goblin.sprite.position) <
//                           $1.sprite.position.distance(to: goblin.sprite.position) }) {

//                 // Attack other goblins
//                 if goblin.sprite.position.distance(to: nearestGoblin.sprite.position) < 50 {
//                     nearestGoblin.applyDamage(goblin.damage * 2) // Double damage!
//                 } else {
//                     // Move towards target
//                     let direction = (nearestGoblin.sprite.position - goblin.sprite.position).normalized()
//                     goblin.sprite.position += direction * 200 * CGFloat(deltaTime)
//                 }
//             }
//         }

//         // Pulse animation
//         controlRing.run(SKAction.repeatForever(SKAction.sequence([
//             SKAction.scale(to: 1.2, duration: 0.5),
//             SKAction.scale(to: 1.0, duration: 0.5)
//         ])))

//         // Cleanup after duration
//         DispatchQueue.main.asyncAfter(deadline: .now() + spell.duration) {
//             goblin.update = originalUpdate
//             goblin.sprite.color = originalColor
//             goblin.sprite.colorBlendFactor = originalBlend
//             controlRing.removeFromParent()
//         }
//     }
// }

class RiftWalkerEffect: SpellEffect {
    func apply(spell: Spell, on goblin: Goblin.GoblinContainer) {
        guard let scene = goblin.sprite.scene as? GameScene else { return }

        // Create rifts
        let riftCount = 5
        var riftPositions: [CGPoint] = []
        let radius: CGFloat = 150

        // Create rift portals in a circle
        for i in 0..<riftCount {
            let angle = (CGFloat(i) / CGFloat(riftCount)) * 2 * .pi
            let position = CGPoint(
                x: goblin.sprite.position.x + cos(angle) * radius,
                y: goblin.sprite.position.y + sin(angle) * radius
            )
            riftPositions.append(position)

            let rift = SKShapeNode(circleOfRadius: 20)
            rift.fillColor = .black
            rift.strokeColor = .purple
            rift.glowWidth = 5
            rift.alpha = 0.8
            rift.position = position
            scene.addChild(rift)

            // Rift animation
            rift.run(SKAction.sequence([
                SKAction.scale(to: 1.2, duration: 0.2),
                SKAction.wait(forDuration: spell.duration),
                SKAction.group([
                    SKAction.fadeOut(withDuration: 0.3),
                    SKAction.scale(to: 0, duration: 0.3)
                ]),
                SKAction.removeFromParent()
            ]))
        }

        // Teleport between rifts and damage nearby enemies
        var currentRiftIndex = 0
        let teleportTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
            let nextIndex = (currentRiftIndex + 1) % riftPositions.count
            let nextPosition = riftPositions[nextIndex]

            // Teleport effect
            let flash = SKSpriteNode(color: .white, size: CGSize(width: 40, height: 40))
            flash.position = goblin.sprite.position
            scene.addChild(flash)
            flash.run(SKAction.sequence([
                SKAction.fadeOut(withDuration: 0.1),
                SKAction.removeFromParent()
            ]))

            // Damage enemies near both positions
            for target in scene.goblinManager.goblinContainers {
                if target.sprite.position.distance(to: goblin.sprite.position) < spell.aoeRadius ||
                   target.sprite.position.distance(to: nextPosition) < spell.aoeRadius {
                    target.applyDamage(spell.damage)

                    // Create lightning between rifts
                    let lightning = SKShapeNode()
                    let path = CGMutablePath()
                    path.move(to: goblin.sprite.position)
                    path.addLine(to: nextPosition)
                    lightning.path = path
                    lightning.strokeColor = .cyan
                    lightning.lineWidth = 2
                    scene.addChild(lightning)
                    lightning.run(SKAction.sequence([
                        SKAction.fadeOut(withDuration: 0.1),
                        SKAction.removeFromParent()
                    ]))
                }
            }

            goblin.sprite.position = nextPosition
            currentRiftIndex = nextIndex
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + spell.duration) {
            teleportTimer.invalidate()
        }
    }
}

class SwarmQueenEffect: SpellEffect {
    func apply(spell: Spell, on goblin: Goblin.GoblinContainer) {
        guard let scene = goblin.sprite.scene as? GameScene else { return }

        let swarmCount = 20
        var swarmEmitters: [SwarmQueenEmitter] = []

        // Create swarm emitters
        for _ in 0..<swarmCount {
            let emitter = SwarmQueenEmitter(at: goblin.sprite.position)
            scene.addChild(emitter)
            swarmEmitters.append(emitter)
        }

        // Swarm behavior
        var time: CGFloat = 0
        let updateTimer = Timer.scheduledTimer(withTimeInterval: 1/60, repeats: true) { [weak scene] _ in
            guard let scene = scene else { return }
            time += 0.05

            for (index, emitter) in swarmEmitters.enumerated() {
                let angle = time + CGFloat(index) * (2 * .pi / CGFloat(swarmCount))
                let radius: CGFloat = 50 + sin(time * 2 + CGFloat(index)) * 20

                let targetPosition = CGPoint(
                    x: goblin.sprite.position.x + cos(angle) * radius,
                    y: goblin.sprite.position.y + sin(angle) * radius
                )

                // Smooth movement
                let direction = CGPoint(
                    x: targetPosition.x - emitter.position.x,
                    y: targetPosition.y - emitter.position.y
                ).normalized()
                emitter.position = CGPoint(
                    x: emitter.position.x + direction.x * 5,
                    y: emitter.position.y + direction.y * 5
                )

                // Damage nearby enemies
                for target in scene.goblinManager.goblinContainers {
                    if target.sprite.position.distance(to: emitter.position) < 20 {
                        target.applyDamage(spell.damage * 0.2)
                    }
                }
            }
        }

        // Cleanup
        DispatchQueue.main.asyncAfter(deadline: .now() + spell.duration) {
            updateTimer.invalidate()
            for emitter in swarmEmitters {
                emitter.run(SKAction.sequence([
                    SKAction.group([
                        SKAction.fadeOut(withDuration: 0.3),
                        SKAction.scale(to: 0, duration: 0.3)
                    ]),
                    SKAction.removeFromParent()
                ]))
            }
        }
    }
}

class NanoSwarmEffect: SpellEffect {
    func apply(spell: Spell, on goblin: Goblin.GoblinContainer) {
        guard let scene = goblin.sprite.scene as? GameScene else { return }

        // Create main nanite cloud
        let swarm = NanoSwarmEmitter(at: goblin.sprite.position)
        scene.addChild(swarm)

        var infectedTargets: Set<Goblin.GoblinContainer> = []
        var miniClouds: [(cloud: NanoSwarmMiniEmitter, target: Goblin.GoblinContainer)] = []

        // Nanite behavior
        let updateTimer = Timer.scheduledTimer(withTimeInterval: 1/30, repeats: true) { [weak scene] _ in
            guard let scene = scene else { return }
            
            // Update mini cloud positions
            for (cloud, target) in miniClouds {
                cloud.position = target.sprite.position
            }
            
            // Find new targets to infect
            for target in scene.goblinManager.goblinContainers {
                if !infectedTargets.contains(target) &&
                   target.sprite.position.distance(to: swarm.position) < spell.aoeRadius {
                    infectedTargets.insert(target)
                    
                    // Visual corruption
                    target.sprite.run(SKAction.repeatForever(SKAction.sequence([
                        SKAction.colorize(with: .cyan, colorBlendFactor: 0.5, duration: 0.1),
                        SKAction.wait(forDuration: 0.1),
                        SKAction.colorize(with: .magenta, colorBlendFactor: 0.5, duration: 0.1)
                    ])))
                    
                    // Create mini cloud
                    let miniCloud = NanoSwarmMiniEmitter(at: target.sprite.position)
                    scene.addChild(miniCloud)
                    miniClouds.append((miniCloud, target))
                }
            }

            // Apply effects to infected targets
            for target in infectedTargets {
                target.applyDamage(spell.damage / 30)
                target.sprite.speed *= 0.995

                // Infection spread logic
                if Double.random(in: 0...1) < 0.1 {
                    let nearbyTargets = scene.goblinManager.goblinContainers.filter {
                        !infectedTargets.contains($0) &&
                        $0.sprite.position.distance(to: target.sprite.position) < 50
                    }
                    if let newTarget = nearbyTargets.randomElement() {
                        infectedTargets.insert(newTarget)
                    }
                }
            }
        }

        // Cleanup
        DispatchQueue.main.asyncAfter(deadline: .now() + spell.duration) {
            updateTimer.invalidate()
            swarm.run(SKAction.sequence([
                SKAction.fadeOut(withDuration: 0.5),
                SKAction.removeFromParent()
            ]))
            
            for (cloud, _) in miniClouds {
                cloud.run(SKAction.sequence([
                    SKAction.fadeOut(withDuration: 0.3),
                    SKAction.removeFromParent()
                ]))
            }

            for target in infectedTargets {
                target.sprite.removeAllActions()
                target.sprite.colorBlendFactor = 0
                target.sprite.speed = 1.0
            }
        }
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

class SystemOverrideEffect: SpellEffect {
    func apply(spell: Spell, on goblin: Goblin.GoblinContainer) {
        guard let scene = goblin.sprite.scene as? GameScene else { return }

        // Create effects
        let codeRain = CodeRainEmitter(at: CGPoint(x: scene.frame.midX, y: scene.frame.maxY))
        scene.addChild(codeRain)

        // Original overlay effects
        let glitchOverlay = SKSpriteNode(color: .black, size: scene.frame.size)
        glitchOverlay.position = CGPoint(x: scene.frame.midX, y: scene.frame.midY)
        glitchOverlay.alpha = 0.3
        glitchOverlay.zPosition = 100
        scene.addChild(glitchOverlay)

        let scanLine = SKSpriteNode(color: .cyan, size: CGSize(width: scene.frame.width, height: 2))
        scanLine.position = CGPoint(x: scene.frame.midX, y: scene.frame.minY)
        scanLine.zPosition = 101
        scene.addChild(scanLine)

        scanLine.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.moveTo(y: scene.frame.maxY, duration: 1.0),
            SKAction.moveTo(y: scene.frame.minY, duration: 0)
        ])))

        var affectedTargets: Set<Goblin.GoblinContainer> = []

        // System override behavior
        let overrideTimer = Timer.scheduledTimer(withTimeInterval: 1/30, repeats: true) { [weak scene] _ in
            guard let scene = scene else { return }
            
            for target in scene.goblinManager.goblinContainers {
                if target.sprite.position.distance(to: goblin.sprite.position) < spell.aoeRadius {
                    if !affectedTargets.contains(target) {
                        affectedTargets.insert(target)
                        
                        // Glitch movement effect
                        let glitchSequence = SKAction.repeatForever(SKAction.sequence([
                            SKAction.moveBy(x: CGFloat.random(in: -10...10),
                                         y: CGFloat.random(in: -10...10),
                                         duration: 0.05),
                            SKAction.moveBy(x: CGFloat.random(in: -10...10),
                                         y: CGFloat.random(in: -10...10),
                                         duration: 0.05)
                        ]))
                        target.sprite.run(glitchSequence)

                        // Behavior modification
                        if Double.random(in: 0...1) < 0.3 {
                            target.damage *= -0.5
                        } else {
                            target.sprite.speed *= -1
                        }
                    }
                    
                    target.applyDamage(spell.damage / 30)
                }
            }
        }

        // Cleanup
        DispatchQueue.main.asyncAfter(deadline: .now() + spell.duration) {
            overrideTimer.invalidate()
            codeRain.run(SKAction.sequence([
                SKAction.fadeOut(withDuration: 0.5),
                SKAction.removeFromParent()
            ]))
            glitchOverlay.removeFromParent()
            scanLine.removeFromParent()

            for target in affectedTargets {
                target.sprite.removeAllActions()
                target.sprite.speed = abs(target.sprite.speed)
                target.damage = abs(target.damage)
            }
        }
    }
}

class IronMaidenEffect: SpellEffect {
    func apply(spell: Spell, on goblin: Goblin.GoblinContainer) {
        guard let scene = goblin.sprite.scene as? GameScene else { return }

        // Pause the goblin and remove from parent
        goblin.pauseAttacks()
        goblin.sprite.removeAllActions()
        goblin.sprite.removeFromParent()

        // Create Iron Maiden around the goblin
        let ironMaiden = IronMaidenEmitter(goblin: goblin)
        ironMaiden.position = goblin.sprite.position
        scene.addChild(ironMaiden)

        // Damage over time
        let damagePerTick = spell.damage / CGFloat(spell.duration)
        let tickDuration: TimeInterval = 0.5
        let numberOfTicks = Int(spell.duration / tickDuration)

        let damageAction = SKAction.repeat(SKAction.sequence([
            SKAction.run {
                goblin.applyDamage(damagePerTick)
            },
            SKAction.wait(forDuration: tickDuration)
        ]), count: numberOfTicks)

        ironMaiden.run(damageAction)

        // Release goblin after duration
        DispatchQueue.main.asyncAfter(deadline: .now() + spell.duration) {
            goblin.sprite.position = ironMaiden.position
            scene.addChild(goblin.sprite)
            ironMaiden.removeFromParent()
            goblin.resumeAttacks()
        }
    }
}

class CyberneticOverloadEffect: SpellEffect {
    func apply(spell: Spell, on goblin: Goblin.GoblinContainer) {
        guard let scene = goblin.sprite.scene as? GameScene else { return }

        // Apply overload effect
        let overloadEffect = CyberneticOverloadEmitter(at: goblin.sprite.position)
        scene.addChild(overloadEffect)

        // Damage over time
        let damagePerTick = spell.damage / CGFloat(spell.duration)
        let tickDuration: TimeInterval = 0.5
        let numberOfTicks = Int(spell.duration / tickDuration)

        let damageAction = SKAction.repeat(SKAction.sequence([
            SKAction.run {
                goblin.applyDamage(damagePerTick)
            },
            SKAction.wait(forDuration: tickDuration)
        ]), count: numberOfTicks)

        goblin.sprite.run(damageAction)

        // Chain lightning to nearby goblins
        let chainAction = SKAction.sequence([
            SKAction.wait(forDuration: 0.5),
            SKAction.run { [weak self] in
                self?.chainLightning(from: goblin, spell: spell)
            }
        ])
        scene.run(SKAction.repeat(chainAction, count: numberOfTicks))

        // Cleanup
        DispatchQueue.main.asyncAfter(deadline: .now() + spell.duration) {
            overloadEffect.removeFromParent()
        }
    }

    private func chainLightning(from goblin: Goblin.GoblinContainer, spell: Spell) {
        guard let scene = goblin.sprite.scene as? GameScene else { return }
        let nearbyGoblins = scene.goblinManager.goblinContainers.filter { target in
            target !== goblin && target.sprite.position.distance(to: goblin.sprite.position) < spell.aoeRadius
        }
        for targetGoblin in nearbyGoblins {
            // Apply damage
            targetGoblin.applyDamage(spell.damage * 0.5)

            // Create lightning bolt
            let lightning = SKShapeNode()
            let path = CGMutablePath()
            path.move(to: goblin.sprite.position)
            path.addLine(to: targetGoblin.sprite.position)
            lightning.path = path
            lightning.strokeColor = .cyan
            lightning.lineWidth = 2
            scene.addChild(lightning)

            lightning.run(SKAction.sequence([
                SKAction.fadeOut(withDuration: 0.2),
                SKAction.removeFromParent()
            ]))
        }
    }
}

class SteampunkTimeBombEffect: SpellEffect {
    func apply(spell: Spell, on goblin: Goblin.GoblinContainer) {
        guard let scene = goblin.sprite.scene as? GameScene else { return }

        // Attach time bomb to goblin
        let timeBomb = TimeBombEmitter()
        timeBomb.position = CGPoint(x: 0, y: goblin.sprite.size.height / 2)
        goblin.sprite.addChild(timeBomb)

        // Ticking animation
        let tickAction = SKAction.sequence([
            SKAction.wait(forDuration: 0.5),
            SKAction.run {
                // Ticking effect (could add sound here)
            }
        ])
        timeBomb.run(SKAction.repeat(tickAction, count: Int(spell.duration / 0.5)))

        // Explosion after duration
        DispatchQueue.main.asyncAfter(deadline: .now() + spell.duration) {
            // Explosion effect
            let explosion = SKShapeNode(circleOfRadius: spell.aoeRadius)
            explosion.fillColor = .orange
            explosion.position = goblin.sprite.position
            scene.addChild(explosion)

            // Remove time bomb
            timeBomb.removeFromParent()

            // Apply area damage
            for target in scene.goblinManager.goblinContainers {
                let distance = target.sprite.position.distance(to: explosion.position)
                if distance <= spell.aoeRadius {
                    let falloff = 1 - (distance / spell.aoeRadius)
                    target.applyDamage(spell.damage * CGFloat(falloff))
                }
            }

            // Explosion animation
            explosion.run(SKAction.sequence([
                SKAction.fadeOut(withDuration: 0.5),
                SKAction.removeFromParent()
            ]))
        }
    }
}



class ShadowPuppetEffect: SpellEffect {
    func apply(spell: Spell, on goblin: Goblin.GoblinContainer) {
        guard let scene = goblin.sprite.scene as? GameScene else { return }

        // Create shadow puppet at goblin's position
        let shadowSprite = goblin.sprite.copy() as! SKSpriteNode
        shadowSprite.color = .black
        shadowSprite.colorBlendFactor = 1.0
        shadowSprite.alpha = 0.7
        shadowSprite.position = goblin.sprite.position
        shadowSprite.zPosition = goblin.sprite.zPosition

        // Create a dummy GoblinContainer for the shadow puppet
        let shadowGoblin = Goblin.GoblinContainer(
            type: goblin.type,
            sprite: shadowSprite,
            healthBar: SKShapeNode(),
            healthFill: SKShapeNode(),
            health: goblin.health,
            damage: goblin.damage * 1.2,
            maxHealth: goblin.maxHealth,
            goldValue: 0
        )

        // Add to the scene and goblin manager
        scene.addChild(shadowSprite)
        scene.goblinManager.addShadowGoblin(shadowGoblin)

        // Shadow attacks other goblins
        shadowGoblin.startAttackingGoblins(in: scene)

        // Remove shadow puppet after duration
        DispatchQueue.main.asyncAfter(deadline: .now() + spell.duration) {
            shadowSprite.removeFromParent()
            scene.goblinManager.removeShadowGoblin(shadowGoblin)
        }

        // Visual effect
        let shadowEffect = ShadowPuppetEmitter(at: goblin.sprite.position)
        scene.addChild(shadowEffect)
        shadowEffect.run(SKAction.sequence([
            SKAction.wait(forDuration: spell.duration),
            SKAction.removeFromParent()
        ]))
    }
}

class TemporalDistortionEffect: SpellEffect {
    func apply(spell: Spell, on goblin: Goblin.GoblinContainer) {
        // Slow down goblin
        goblin.sprite.speed = 0.3

        // Visual effect
        let distortion = TemporalDistortionEmitter()
        distortion.position = CGPoint.zero
        goblin.sprite.addChild(distortion)

        // Restore speed after duration
        DispatchQueue.main.asyncAfter(deadline: .now() + spell.duration) {
            goblin.sprite.speed = 1.0
            distortion.removeFromParent()
        }
    }
}

class QuantumCollapseEffect: SpellEffect {
    func apply(spell: Spell, on goblin: Goblin.GoblinContainer) {
        guard let scene = goblin.sprite.scene else { return }

        // Apply fluctuating damage
        let minDamage = spell.damage * 0.5
        let maxDamage = spell.damage * 1.5
        let randomDamage = CGFloat.random(in: minDamage...maxDamage)
        goblin.applyDamage(randomDamage)

        // Visual effect
        let quantumEffect = QuantumCollapseEmitter()
        quantumEffect.position = goblin.sprite.position
        scene.addChild(quantumEffect)
        quantumEffect.run(SKAction.sequence([
            SKAction.wait(forDuration: spell.duration),
            SKAction.removeFromParent()
        ]))
    }
}



class BloodMoonEffect: SpellEffect {
    func apply(spell: Spell, on goblin: Goblin.GoblinContainer) {
        guard let scene = goblin.sprite.scene as? GameScene else { return }

        // Add visual effect
        let bloodMoon = BloodMoonEmitter(at: goblin.sprite.position)
        scene.addChild(bloodMoon)

        // Damage and healing over time
        let totalTicks = Int(spell.duration)
        let damagePerTick = spell.damage / CGFloat(totalTicks)
        let healPerTick = damagePerTick * 0.5

        let action = SKAction.repeat(SKAction.sequence([
            SKAction.run {
                goblin.applyDamage(damagePerTick)
                scene.playerState.health = min(scene.playerState.maxHealth, scene.playerState.health + healPerTick)
            },
            SKAction.wait(forDuration: 1.0)
        ]), count: totalTicks)

        scene.run(action)

        // Cleanup
        bloodMoon.run(SKAction.sequence([
            SKAction.wait(forDuration: spell.duration),
            SKAction.removeFromParent()
        ]))
    }
}

class EarthShatterEffect: SpellEffect {
    func apply(spell: Spell, on goblin: Goblin.GoblinContainer) {
        guard let scene = goblin.sprite.scene as? GameScene else { return }

        // Add visual effect
        let earthShatter = EarthShatterEmitter(at: goblin.sprite.position)
        scene.addChild(earthShatter)

        // Damage nearby goblins
        let nearbyGoblins = scene.goblinManager.goblinContainers.filter {
            $0.sprite.position.distance(to: goblin.sprite.position) <= spell.aoeRadius
        }
        for target in nearbyGoblins {
            target.applyDamage(spell.damage)
        }

        // Cleanup
        earthShatter.run(SKAction.sequence([
            SKAction.wait(forDuration: 1.0),
            SKAction.removeFromParent()
        ]))
    }
}

class MysticBarrierEffect: SpellEffect {
    func apply(spell: Spell, on goblin: Goblin.GoblinContainer) {
        guard let scene = goblin.sprite.scene else { return }

        // Create barrier around player
        let barrier = MysticBarrierEmitter(at: scene.playerPosition, radius: spell.aoeRadius)
        scene.addChild(barrier)

        // Damage goblins who touch the barrier
        let damageAction = SKAction.run {
            let goblins = scene.goblinManager.goblinContainers
            for target in goblins {
                if target.sprite.position.distance(to: scene.playerPosition) <= spell.aoeRadius {
                    target.applyDamage(spell.damage)
                }
            }
        }
        barrier.run(SKAction.repeat(SKAction.sequence([
            damageAction,
            SKAction.wait(forDuration: 0.5)
        ]), count: Int(spell.duration / 0.5)))

        // Cleanup
        barrier.run(SKAction.sequence([
            SKAction.wait(forDuration: spell.duration),
            SKAction.removeFromParent()
        ]))
    }
}
