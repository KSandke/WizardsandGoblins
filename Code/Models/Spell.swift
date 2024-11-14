import Foundation
import SpriteKit

class Spell {
    let name: String
    let manaCost: CGFloat
    let aoeRadius: CGFloat
    let duration: TimeInterval
    let damage: CGFloat
    let specialEffect: ((Spell, Goblin.GoblinContainer) -> Void)?
    
    init(name: String, manaCost: CGFloat, aoeRadius: CGFloat, duration: TimeInterval, damage: CGFloat, specialEffect: ((Spell, Goblin.GoblinContainer) -> Void)?) {
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
        
        // Set up physics body
        let physicsBody = SKPhysicsBody(circleOfRadius: spellNode.size.width / 2)
        physicsBody.isDynamic = true
        physicsBody.affectedByGravity = false
        physicsBody.categoryBitMask = PhysicsCategory.spell
        physicsBody.contactTestBitMask = PhysicsCategory.goblin
        physicsBody.collisionBitMask = PhysicsCategory.none
        spellNode.physicsBody = physicsBody
        
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
        aoeCircle.fillColor = .orange
        aoeCircle.strokeColor = .clear
        aoeCircle.alpha = 0.5
        aoeCircle.position = position
        aoeCircle.zPosition = 1
        scene.addChild(aoeCircle)
        
        // Apply effects to goblins using Goblin class
        if let gameScene = scene as? GameScene {
            // Apply damage with spell power multiplier
            let modifiedSpell = Spell(
                name: self.name,
                manaCost: self.manaCost,
                aoeRadius: self.aoeRadius,
                duration: self.duration,
                damage: self.damage * gameScene.playerState.spellPowerMultiplier,
                specialEffect: self.specialEffect
            )
            gameScene.applySpell(modifiedSpell, at: position)
        }
        
        // Create fade out and remove sequence
        let fadeOut = SKAction.fadeOut(withDuration: duration)
        let remove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([fadeOut, remove])
        
        aoeCircle.run(sequence)
    }
} 
