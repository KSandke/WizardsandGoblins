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
        
        // Calculate the time between meteor spawns
        let numberOfMeteors = Int(spell.duration)
        let timeBetweenMeteors = spell.duration / Double(numberOfMeteors)
        let damagePerMeteor = spell.damage / CGFloat(numberOfMeteors)
        
        // Create a sequence for spawning each meteor
        let spawnSequence = SKAction.sequence([
            SKAction.run { [weak scene] in
                // Randomize position slightly around the target
                let randomOffset = CGPoint(
                    x: CGFloat.random(in: -50...50),
                    y: CGFloat.random(in: -50...50)
                )
                let meteorPosition = goblin.sprite.position + randomOffset
                
                // Create new meteor emitter
                let meteor = MeteorShowerEmitter(at: meteorPosition)
                scene?.addChild(meteor)
                
                // Set completion handler for THIS specific meteor
                meteor.completionHandler = { [weak scene] in
                    guard let gameScene = scene as? GameScene else { return }
                    // Apply damage only when THIS meteor hits
                    for target in gameScene.goblinManager.goblinContainers {
                        let distance = target.sprite.position.distance(to: meteorPosition)
                        if distance <= spell.aoeRadius {
                            target.applyDamage(damagePerMeteor)
                        }
                    }
                }
            },
            SKAction.wait(forDuration: timeBetweenMeteors)
        ])
        
        // Repeat the spawn sequence for each meteor
        let meteorShowerAction = SKAction.repeat(spawnSequence, count: numberOfMeteors)
        scene.run(meteorShowerAction)
    }
}
