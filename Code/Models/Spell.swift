import Foundation
import SpriteKit

class Spell {
    let name: String
    let manaCost: CGFloat
    let aoeRadius: CGFloat
    let duration: TimeInterval
    let damage: CGFloat
    let specialEffect: ((Spell, GameScene.GoblinContainer) -> Void)?
    
    init(name: String, manaCost: CGFloat, aoeRadius: CGFloat, duration: TimeInterval, damage: CGFloat, specialEffect: ((Spell, GameScene.GoblinContainer) -> Void)?) {
        self.name = name
        self.manaCost = manaCost
        self.aoeRadius = aoeRadius
        self.duration = duration
        self.damage = damage
        self.specialEffect = specialEffect
    }
    
    func cast(from casterPosition: CGPoint, to targetPosition: CGPoint, by playerState: PlayerState, isPlayerOne: Bool, in scene: SKScene) -> Bool {
        // Check mana
        if !playerState.useSpell(isPlayerOne: isPlayerOne, cost: manaCost) {
            return false
        }
        
        // Create spell sprite and animation
        let spellNode = SKSpriteNode(imageNamed: name) // Use the spell name as image name
        spellNode.size = CGSize(width: 50, height: 50)
        spellNode.position = casterPosition
        scene.addChild(spellNode)
        
        // Calculate direction and rotation
        let dx = targetPosition.x - casterPosition.x
        let dy = targetPosition.y - casterPosition.y
        let angle = atan2(dy, dx)
        spellNode.zRotation = angle + .pi / 2 + .pi
        
        // Calculate distance and duration
        let distance = casterPosition.distance(to: targetPosition)
        let baseSpeed: CGFloat = 400 // pixels per second
        let travelDuration = TimeInterval(distance / baseSpeed)
        
        // Create actions
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
        // Create the AOE circle
        let aoeCircle = SKShapeNode(circleOfRadius: aoeRadius)
        aoeCircle.fillColor = .orange // Customize color per spell
        aoeCircle.strokeColor = .clear
        aoeCircle.alpha = 0.5
        aoeCircle.position = position
        aoeCircle.zPosition = 1
        scene.addChild(aoeCircle)
        
        // Apply effects to goblins
        if let gameScene = scene as? GameScene {
            gameScene.applySpell(self, at: position)
        }
        
        // Create fade out and remove sequence
        let fadeOut = SKAction.fadeOut(withDuration: duration)
        let remove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([fadeOut, remove])
        
        aoeCircle.run(sequence)
    }
    
    func applyToGoblin(container: Goblin.GoblinContainer, in scene: SKScene) {
        // Apply damage or effects to the goblin
        let damageAmount: CGFloat = self.damage
        if let health = container.sprite.userData?["health"] as? CGFloat {
            var newHealth = health - damageAmount
            if newHealth < 0 { newHealth = 0 }
            container.sprite.userData?["health"] = newHealth
            
            // Update health bar
            let maxHealth = container.sprite.userData?["maxHealth"] as? CGFloat ?? 50.0
            let healthRatio = newHealth / maxHealth
            let healthBarWidth: CGFloat = 40
            let newWidth = healthBarWidth * healthRatio
            container.healthFill.xScale = healthRatio
            container.healthFill.position = CGPoint(x: container.healthBar.position.x - (healthBarWidth - newWidth) / 2, y: container.healthBar.position.y)
        }
    }
} 