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
        
        guard let gameScene = scene as? GameScene else { return false }
        
        // Handle different targeting modes
        switch targetingMode {
        case .direct:
            return useDirectTargeting(from: casterPosition, to: targetPosition, by: playerState, in: gameScene)
            
        case .area:
            return useAreaTargeting(from: casterPosition, to: targetPosition, by: playerState, in: gameScene)
            
        case .automatic:
            if let nearestGoblin = findNearestGoblin(from: casterPosition, in: gameScene) {
                return useDirectTargeting(from: casterPosition, to: nearestGoblin.position, by: playerState, in: gameScene)
            }
            return false
            
        case .global:
            return useGlobalTargeting(from: casterPosition, by: playerState, in: gameScene)
            
        case .maxHealth:
            return useMaxHealthTargeting(from: casterPosition, by: playerState, in: gameScene)
        }
    }
    
    private func useDirectTargeting(from casterPosition: CGPoint, to targetPosition: CGPoint, by playerState: PlayerState, in scene: GameScene) -> Bool {
        let specialNode = createSpecialNode(at: casterPosition)
        scene.addChild(specialNode)
        
        let angle = calculateAngle(from: casterPosition, to: targetPosition)
        specialNode.zRotation = angle + .pi / 2 + .pi
        
        let travelDuration = calculateTravelDuration(from: casterPosition, to: targetPosition, with: playerState)
        
        let moveAction = SKAction.move(to: targetPosition, duration: travelDuration)
        let applyEffect = SKAction.run { [weak self] in
            self?.applyEffect(at: targetPosition, in: scene)
        }
        let removeSpecial = SKAction.removeFromParent()
        
        specialNode.run(SKAction.sequence([moveAction, applyEffect, removeSpecial]))
        return true
    }
    
    private func useAreaTargeting(from casterPosition: CGPoint, to targetPosition: CGPoint, by playerState: PlayerState, in scene: GameScene) -> Bool {
        // Create targeting indicator
        let aoeIndicator = SKShapeNode(circleOfRadius: aoeRadius)
        aoeIndicator.strokeColor = aoeColor.withAlphaComponent(0.5)
        aoeIndicator.fillColor = aoeColor.withAlphaComponent(0.2)
        aoeIndicator.position = targetPosition
        scene.addChild(aoeIndicator)
        
        // Fade in and out animation
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.2)
        let wait = SKAction.wait(forDuration: 0.1)
        let fadeOut = SKAction.fadeAlpha(to: 0.0, duration: 0.2)
        let remove = SKAction.removeFromParent()
        
        aoeIndicator.run(SKAction.sequence([fadeIn, wait, fadeOut, remove]))
        
        // Apply effect to all goblins in the area
        let goblinsInRange = scene.goblinManager.getGoblins().filter { goblin in
            let distance = targetPosition.distance(to: goblin.sprite.position)
            return distance <= aoeRadius
        }
        
        for goblin in goblinsInRange {
            applyEffect(at: goblin.sprite.position, in: scene)
        }
        
        return true
    }
    
    private func useGlobalTargeting(from casterPosition: CGPoint, by playerState: PlayerState, in scene: GameScene) -> Bool {
        // Create full screen flash effect
        let flash = SKSpriteNode(color: aoeColor, size: scene.size)
        flash.position = CGPoint(x: scene.size.width/2, y: scene.size.height/2)
        flash.alpha = 0.0
        scene.addChild(flash)
        
        let fadeIn = SKAction.fadeAlpha(to: 0.3, duration: 0.2)
        let wait = SKAction.wait(forDuration: 0.1)
        let fadeOut = SKAction.fadeAlpha(to: 0.0, duration: 0.2)
        let remove = SKAction.removeFromParent()
        
        flash.run(SKAction.sequence([fadeIn, wait, fadeOut, remove]))
        
        // Apply effect to all goblins
        for goblin in scene.goblinManager.getGoblins() {
            applyEffect(at: goblin.sprite.position, in: scene)
        }
        
        return true
    }
    
    private func useMaxHealthTargeting(from casterPosition: CGPoint, by playerState: PlayerState, in scene: GameScene) -> Bool {
        let maxHealthGoblins = scene.goblinManager.getGoblins().filter { goblin in
            goblin.health >= goblin.maxHealth
        }
        
        for goblin in maxHealthGoblins {
            applyEffect(at: goblin.sprite.position, in: scene)
        }
        
        return !maxHealthGoblins.isEmpty
    }
    
    private func findNearestGoblin(from position: CGPoint, in scene: GameScene) -> Goblin.GoblinContainer? {
        return scene.goblinManager.getGoblins().min { goblin1, goblin2 in
            position.distance(to: goblin1.sprite.position) < position.distance(to: goblin2.sprite.position)
        }
    }
    
    private func createSpecialNode(at position: CGPoint) -> SKSpriteNode {
        let specialNode = SKSpriteNode(imageNamed: name)
        specialNode.size = CGSize(width: 50, height: 50)
        specialNode.position = position
        return specialNode
    }
    
    private func calculateAngle(from start: CGPoint, to end: CGPoint) -> CGFloat {
        let dx = end.x - start.x
        let dy = end.y - start.y
        return atan2(dy, dx)
    }
    
    private func calculateTravelDuration(from start: CGPoint, to end: CGPoint, with playerState: PlayerState) -> TimeInterval {
        let distance = start.distance(to: end)
        let adjustedSpeed = GameConfig.defaultSpellSpeed * playerState.spellSpeedMultiplier
        return TimeInterval(distance / adjustedSpeed)
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
