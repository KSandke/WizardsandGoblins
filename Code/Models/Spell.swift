import Foundation
import SpriteKit

class Spell {
    let name: String
    let aoeRadius: CGFloat
    let duration: TimeInterval
    let damage: CGFloat
    let specialEffect: ((Spell, Goblin.GoblinContainer) -> Void)?
    
    init(name: String, aoeRadius: CGFloat, duration: TimeInterval, damage: CGFloat, specialEffect: ((Spell, Goblin.GoblinContainer) -> Void)?) {
        self.name = name
        self.aoeRadius = aoeRadius
        self.duration = duration
        self.damage = damage
        self.specialEffect = specialEffect
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
                specialEffect: self.specialEffect
            )
            gameScene.applySpell(modifiedSpell, at: position)
        }
        
        let fadeOut = SKAction.fadeOut(withDuration: duration)
        let remove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([fadeOut, remove])
        
        aoeCircle.run(sequence)
    }
} 
