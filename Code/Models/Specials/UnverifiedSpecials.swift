import Foundation
import SpriteKit


// Predefined Spell Classes

class TacticalNukeSpell: Spell {
    init() {
        super.init(
            name: "TacticalNuke",
            aoeRadius: 200,
            duration: 3.0,
            damage: 100,
            effect: TacticalNukeEffect(),
            isOneTimeUse: true
        )
    }
}

class CrowSwarmSpell: Spell {
    init() {
        super.init(
            name: "CrowSwarm",
            aoeRadius: 150,
            duration: 5.0,
            damage: 20,
            effect: DroneSwarmEffect(),
            isOneTimeUse: true
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
            effect: NanoSwarmEffect(),
            isOneTimeUse: true
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
            effect: SystemOverrideEffect(),
            isOneTimeUse: true
        )
    }
}

class CyberneticOverloadSpell: Spell {
    init() {
        super.init(
            name: "Cybernetic Overload",
            aoeRadius: 100,
            duration: 5.0,
            damage: 30,
            effect: CyberneticOverloadEffect(),
            isOneTimeUse: true
        )
    }
}

class SteampunkTimeBombSpell: Spell {
    init() {
        super.init(
            name: "Steampunk Time Bomb",
            aoeRadius: 150,
            duration: 3.0,
            damage: 50,
            effect: SteampunkTimeBombEffect(),
            isOneTimeUse: true
        )
    }
}


class ShadowPuppetSpell: Spell {
    init() {
        super.init(
            name: "Shadow Puppet",
            aoeRadius: 5,
            duration: 10.0,
            damage: 0,
            effect: ShadowPuppetEffect(),
            isOneTimeUse: true
        )
    }
}

class TemporalDistortionSpell: Spell {
    init() {
        super.init(
            name: "Temporal Distortion",
            aoeRadius: 120,
            duration: 5.0,
            damage: 0,
            effect: TemporalDistortionEffect(),
            isOneTimeUse: true
        )
    }
}

class QuantumCollapseSpell: Spell {
    init() {
        super.init(
            name: "Quantum Collapse",
            aoeRadius: 100,
            duration: 3.0,
            damage: 50,
            effect: QuantumCollapseEffect(),
            isOneTimeUse: true
        )
    }
}

class EarthShatterSpell: Spell {
    init() {
        super.init(
            name: "Earth Shatter",
            aoeRadius: 100,
            duration: 1.0,
            damage: 40,
            effect: EarthShatterEffect(),
            isOneTimeUse: false
        )
    }
}

class MysticBarrierSpell: Spell {
    init() {
        super.init(
            name: "Mystic Barrier",
            aoeRadius: 80,
            duration: 8.0,
            damage: 20,
            effect: MysticBarrierEffect(),
            isOneTimeUse: true
        )
    }
}

class DivineWrathSpell: Spell {
    init() {
        super.init(
            name: "Divine Wrath",
            aoeRadius: 5,
            duration: 2.0,
            damage: 50,
            effect: DivineWrathEffect(),
            isOneTimeUse: true
        )
    }
}

class ArcaneStormSpell: Spell {
    init() {
        super.init(
            name: "Arcane Storm",
            aoeRadius: 150,
            duration: 4.0,
            damage: 40,
            effect: ArcaneStormEffect(),
            isOneTimeUse: true
        )
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

        // Create shadow puppet sprite
        let shadowSprite = SKSpriteNode(texture: goblin.sprite.texture)
        shadowSprite.size = goblin.sprite.size
        shadowSprite.position = goblin.sprite.position
        shadowSprite.color = .black
        shadowSprite.colorBlendFactor = 1.0
        shadowSprite.alpha = 0.7
        shadowSprite.zPosition = goblin.sprite.zPosition

        // Add shadow effect
        let shadowEffect = ShadowPuppetEmitter(at: .zero)
        shadowSprite.addChild(shadowEffect)

        // Create shadow goblin container
        let shadowGoblin = Goblin.GoblinContainer(
            type: goblin.type,
            sprite: shadowSprite,
            healthBar: SKShapeNode(), // Empty health bar
            healthFill: SKShapeNode(),
            health: goblin.health,
            damage: goblin.damage * 1.5, // 50% more damage
            maxHealth: goblin.maxHealth,
            goldValue: 0
        )

        // Add to scene and start behavior
        scene.addChild(shadowSprite)
        scene.goblinManager.addShadowGoblin(shadowGoblin)

        // Start attacking behavior
        let updateAction = SKAction.customAction(withDuration: spell.duration) { _, _ in
            // Find nearest non-shadow goblin
            if let nearestGoblin = scene.goblinManager.goblinContainers
                .filter({ $0 !== goblin })
                .min(by: { $0.sprite.position.distance(to: shadowSprite.position) <
                          $1.sprite.position.distance(to: shadowSprite.position) }) {

                let attackRange: CGFloat = 50
                let distance = shadowSprite.position.distance(to: nearestGoblin.sprite.position)
                
                if distance <= attackRange {
                    // Attack
                    nearestGoblin.applyDamage(shadowGoblin.damage)
                    
                    // Attack visual
                    let slash = ShadowPuppetEmitter(at: nearestGoblin.sprite.position)
                    scene.addChild(slash)
                    slash.run(SKAction.sequence([
                        SKAction.wait(forDuration: 0.2),
                        SKAction.removeFromParent()
                    ]))
                } else {
                    // Move towards target
                    let direction = (nearestGoblin.sprite.position - shadowSprite.position).normalized()
                    let speed: CGFloat = 150
                    shadowSprite.position = CGPoint(
                        x: shadowSprite.position.x + direction.x * speed * 1/60,
                        y: shadowSprite.position.y + direction.y * speed * 1/60
                    )
                    
                    // Update facing direction
                    shadowSprite.xScale = direction.x < 0 ? -abs(shadowSprite.xScale) : abs(shadowSprite.xScale)
                }
            }
        }

        // Run the update action
        shadowSprite.run(SKAction.sequence([
            updateAction,
            SKAction.run { [weak scene] in
                scene?.goblinManager.removeShadowGoblin(shadowGoblin)
            }
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
        guard let scene = goblin.sprite.scene as? GameScene else { return }

        // Create barrier at the goblin's position (spell landing point) instead of player position
        let barrier = MysticBarrierEmitter(at: goblin.sprite.position, radius: spell.aoeRadius)
        scene.addChild(barrier)

        // Damage goblins who touch the barrier
        let damageAction = SKAction.run {
            let goblins = scene.goblinManager.goblinContainers
            for target in goblins {
                // Check distance from barrier center (goblin position) instead of player position
                if target.sprite.position.distance(to: goblin.sprite.position) <= spell.aoeRadius {
                    target.applyDamage(spell.damage)
                }
            }
        }
        barrier.run(SKAction.sequence([
            SKAction.repeat(SKAction.sequence([
                damageAction,
                SKAction.wait(forDuration: 0.5)
            ]), count: Int(spell.duration / 0.5)),
            SKAction.removeFromParent()
        ]))
    }
}



class DivineWrathEffect: SpellEffect {
    func apply(spell: Spell, on goblin: Goblin.GoblinContainer) {
        guard let scene = goblin.sprite.scene else { return }

        // Create lightning strike effect
        let lightning = DivineWrathEmitter(position: goblin.sprite.position)
        scene.addChild(lightning)

        // Damage the goblin
        goblin.applyDamage(spell.damage)

        // Remove effect after a short duration
        lightning.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.5),
            SKAction.removeFromParent()
        ]))
    }
}

class ArcaneStormEffect: SpellEffect {
    func apply(spell: Spell, on goblin: Goblin.GoblinContainer) {
        guard let scene = goblin.sprite.scene as? GameScene else { return }

        // Create storm effect at the goblin's position
        let storm = ArcaneStormEmitter(position: goblin.sprite.position, radius: spell.aoeRadius)
        scene.addChild(storm)

        // Damage all goblins within the area over time
        let damagePerTick = spell.damage / CGFloat(spell.duration)
        let tickAction = SKAction.repeat(SKAction.sequence([
            SKAction.run {
                for target in scene.goblinManager.goblinContainers {
                    let distance = target.sprite.position.distance(to: goblin.sprite.position)
                    if distance <= spell.aoeRadius {
                        target.applyDamage(damagePerTick)
                    }
                }
            },
            SKAction.wait(forDuration: 1.0)
        ]), count: Int(spell.duration))

        scene.run(tickAction)

        // Remove storm after duration
        storm.run(SKAction.sequence([
            SKAction.wait(forDuration: spell.duration),
            SKAction.removeFromParent()
        ]))
    }
}