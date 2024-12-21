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
    
    // Override the main use method
    override func use(from casterPosition: CGPoint, to targetPosition: CGPoint, by playerState: PlayerState, in scene: SKScene) -> Bool {
        if !canUse() {
            return false
        }

        lastUsedTime = Date()
        
        guard let gameScene = scene as? GameScene else { return false }
        
        // Just trigger the meteor shower effect directly
        if let effect = self.effect {
            let randomGoblin = gameScene.goblinManager.goblinContainers.randomElement()
            if let target = randomGoblin {
                effect.apply(spell: self, on: target)
                return true
            }
        }
        return false
    }
}

class MeteorShowerEffect: SpecialEffect {
    func apply(spell: Special, on goblin: Goblin.GoblinContainer) {
        guard let scene = goblin.sprite.scene else { return }
        
        // Increase number of meteors and spread
        let numberOfMeteors = Int(spell.duration * 3) // Triple the number of meteors
        let timeBetweenMeteors = spell.duration / Double(numberOfMeteors)
        let damagePerMeteor = spell.damage / CGFloat(numberOfMeteors)
        
        // Calculate a wider area for meteor spawns
        let spreadRadius: CGFloat = 300 // Increased spread radius
        
        // Create a sequence for spawning each meteor
        let spawnSequence = SKAction.sequence([
            SKAction.run { [weak scene] in
                // Create multiple meteors per spawn
                for _ in 0...2 { // Spawn 3 meteors at once
                    // Randomize position in a wider area around the target
                    let angle = CGFloat.random(in: 0...(2 * .pi))
                    let distance = CGFloat.random(in: 0...spreadRadius)
                    let offset = CGPoint(
                        x: cos(angle) * distance,
                        y: sin(angle) * distance
                    )
                    let meteorPosition = goblin.sprite.position + offset
                    
                    // Create new meteor emitter
                    let meteor = MeteorShowerEmitter(at: meteorPosition)
                    scene?.addChild(meteor)
                    
                    // Apply damage when meteor lands
                    meteor.completionHandler = { [weak scene] in
                        guard let gameScene = scene as? GameScene else { return }
                        for target in gameScene.goblinManager.goblinContainers {
                            let distance = target.sprite.position.distance(to: meteorPosition)
                            if distance <= spell.aoeRadius {
                                target.applyDamage(damagePerMeteor)
                            }
                        }
                    }
                }
            },
            SKAction.wait(forDuration: timeBetweenMeteors)
        ])
        
        // Repeat the spawn sequence for each meteor group
        let meteorShowerAction = SKAction.repeat(spawnSequence, count: numberOfMeteors)
        scene.run(meteorShowerAction)
    }
}
