import Foundation
import SpriteKit

class Spell {
    let name: String
    var aoeRadius: CGFloat
    var aoeColor: SKColor
    var duration: TimeInterval
    var damage: CGFloat
    let effect: SpellEffect?
    let manaCost: Int
    let rarity: ItemRarity

    init(name: String, aoeRadius: CGFloat, aoeColor: SKColor, duration: TimeInterval, damage: CGFloat, effect: SpellEffect?, rarity: ItemRarity = .common) {
        self.name = name
        self.aoeRadius = aoeRadius
        self.aoeColor = aoeColor
        self.duration = duration
        self.damage = damage
        self.effect = effect
        self.manaCost = 1  // All spells cost 1 mana for now
        self.rarity = rarity
    }

    func cast(from casterPosition: CGPoint, to targetPosition: CGPoint, by playerState: PlayerState, in scene: SKScene) -> Bool {
        if !playerState.useSpell(cost: manaCost, spellName: nil) {
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
        let adjustedSpeed = GameConfig.defaultSpellSpeed * playerState.spellSpeedMultiplier
        let travelDuration = TimeInterval(distance / adjustedSpeed)

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
        let aoeCircle = SKShapeNode(circleOfRadius: aoeRadius * gameScene.playerState.spellAOEMultiplier)
        aoeCircle.fillColor = aoeColor
        aoeCircle.strokeColor = .clear
        aoeCircle.alpha = 0.5
        aoeCircle.position = position
        aoeCircle.zPosition = 1
        scene.addChild(aoeCircle)

        if let gameScene = scene as? GameScene {
            let modifiedSpell = Spell(
                name: self.name,
                aoeRadius: self.aoeRadius * gameScene.playerState.spellAOEMultiplier,
                duration: self.duration,
                damage: self.damage * gameScene.playerState.spellPowerMultiplier,
                effect: self.effect,
                rarity: self.rarity
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

class DefaultEffect: SpellEffect {
    func apply(spell: Spell, on goblin: Goblin.GoblinContainer) {
        goblin.applyDamage(spell.damage)
    }
}