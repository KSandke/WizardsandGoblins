import Foundation
import SpriteKit

enum TargetingMode {
    case direct      // Point and click targeting
    case area       // Area of effect targeting
    case automatic  // Auto-targeting nearest enemy
    case global     // Affects entire battlefield
    case maxHealth  // Affects all goblins with max health
}

class Special {
    let name: String
    var aoeRadius: CGFloat
    var aoeColor: SKColor
    var duration: TimeInterval
    var damage: CGFloat
    let effect: SpellEffect?
    let cooldown: TimeInterval
    let targetingMode: TargetingMode
    let rarity: ItemRarity
    private var lastUsedTime: Date?

    init(name: String, aoeRadius: CGFloat, aoeColor: SKColor, duration: TimeInterval, damage: CGFloat, effect: SpellEffect?, cooldown: TimeInterval, targetingMode: TargetingMode, rarity: ItemRarity = .common) {
        self.name = name
        self.aoeRadius = aoeRadius
        self.aoeColor = aoeColor
        self.duration = duration
        self.damage = damage
        self.effect = effect
        self.cooldown = cooldown
        self.targetingMode = targetingMode
        self.rarity = rarity
    }

    func canUse() -> Bool {
        guard let lastUsed = lastUsedTime else { return true }
        return Date().timeIntervalSince(lastUsed) >= cooldown
    }

    func use(from casterPosition: CGPoint, to targetPosition: CGPoint, by playerState: PlayerState, in scene: SKScene) -> Bool {
        if !canUse() {
            return false
        }

        lastUsedTime = Date()
        
        let specialNode = SKSpriteNode(imageNamed: name)
        specialNode.size = CGSize(width: 50, height: 50)
        specialNode.position = casterPosition
        scene.addChild(specialNode)

        let dx = targetPosition.x - casterPosition.x
        let dy = targetPosition.y - casterPosition.y
        let angle = atan2(dy, dx)
        specialNode.zRotation = angle + .pi / 2 + .pi

        let distance = casterPosition.distance(to: targetPosition)
        let adjustedSpeed = GameConfig.defaultSpellSpeed * playerState.spellSpeedMultiplier
        let travelDuration = TimeInterval(distance / adjustedSpeed)

        let moveAction = SKAction.move(to: targetPosition, duration: travelDuration)
        let applyEffect = SKAction.run { [weak self, weak scene] in
            guard let self = self, let scene = scene else { return }
            self.applyEffect(at: targetPosition, in: scene)
        }
        let removeSpecial = SKAction.removeFromParent()

        let sequence = SKAction.sequence([moveAction, applyEffect, removeSpecial])
        specialNode.run(sequence)

        return true
    }

    func applyEffect(at position: CGPoint, in scene: SKScene) {
        guard let gameScene = scene as? GameScene else { return }
        
        let modifiedSpecial = Special(
            name: self.name,
            aoeRadius: self.aoeRadius,
            aoeColor: self.aoeColor,
            duration: self.duration,
            damage: self.damage * gameScene.playerState.spellPowerMultiplier,
            effect: self.effect,
            cooldown: self.cooldown,
            targetingMode: self.targetingMode,
            rarity: self.rarity
        )
        gameScene.applySpecial(modifiedSpecial, at: position)
    }
}
