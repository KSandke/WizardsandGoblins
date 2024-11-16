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
