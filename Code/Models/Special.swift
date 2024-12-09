import Foundation
import SpriteKit

enum TargetingMode {
    case global     // Affects all goblins
    case maxHealth  // Targets single goblin with largest health
    case random     // Targets a random goblin
}

class Special {
    let name: String
    var aoeRadius: CGFloat
    var aoeColor: SKColor
    var duration: TimeInterval
    var damage: CGFloat
    let effect: SpecialEffect?
    let cooldown: TimeInterval
    let targetingMode: TargetingMode
    let rarity: ItemRarity
    var lastUsedTime: Date?
    private var totalPausedTime: TimeInterval = 0
    private var pauseStartTime: Date?

    init(name: String, aoeRadius: CGFloat, aoeColor: SKColor, duration: TimeInterval, damage: CGFloat, effect: SpecialEffect?, cooldown: TimeInterval, targetingMode: TargetingMode, rarity: ItemRarity = .common) {
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
        
        // Calculate effective time passed, subtracting any paused time
        let effectiveTimePassed = Date().timeIntervalSince(lastUsed) - totalPausedTime
        return effectiveTimePassed >= cooldown
    }

    func pauseCooldown() {
        guard pauseStartTime == nil else { return } // Already paused
        pauseStartTime = Date()
    }
    
    func resumeCooldown() {
        guard let pauseStart = pauseStartTime else { return } // Not paused
        totalPausedTime += Date().timeIntervalSince(pauseStart)
        pauseStartTime = nil
    }

    func use(from casterPosition: CGPoint, to targetPosition: CGPoint, by playerState: PlayerState, in scene: SKScene) -> Bool {
        if !canUse() {
            return false
        }

        lastUsedTime = Date()
        totalPausedTime = 0 // Reset paused time when used
        pauseStartTime = nil
        
        guard let gameScene = scene as? GameScene else { return false }
        
        // Handle different targeting modes
        switch targetingMode {
        case .global:
            return useGlobalTargeting(from: casterPosition, by: playerState, in: gameScene)
            
        case .maxHealth:
            return useMaxHealthTargeting(from: casterPosition, by: playerState, in: gameScene)
            
        case .random:
            return useRandomTargeting(from: casterPosition, by: playerState, in: gameScene)
        }
    }
    
    private func useGlobalTargeting(from casterPosition: CGPoint, by playerState: PlayerState, in scene: GameScene) -> Bool {
        // Create full screen flash effect
        let flash = SKSpriteNode(color: aoeColor, size: scene.size)
        flash.position = CGPoint(x: scene.size.width/2, y: scene.size.height/2)
        flash.alpha = 0.0
        flash.zPosition = 100
        scene.addChild(flash)
        
        // Flash animation
        let fadeIn = SKAction.fadeAlpha(to: 0.3, duration: 0.2)
        let fadeOut = SKAction.fadeAlpha(to: 0.0, duration: 0.2)
        let remove = SKAction.removeFromParent()
        
        // Apply damage after the animation completes
        let applyDamage = SKAction.run { [weak self] in
            guard let self = self else { return }
            // Apply effect to all goblins with modified damage
            let modifiedDamage = self.damage * playerState.spellPowerMultiplier
            let allGoblins = scene.goblinManager.getGoblins()
            for goblin in allGoblins {
                goblin.applyDamage(modifiedDamage)
                if let effect = self.effect {
                    effect.apply(spell: self, on: goblin)
                }
            }
        }
        
        // Sequence the animations and damage application
        flash.run(SKAction.sequence([fadeIn, fadeOut, remove, applyDamage]))
        
        return !scene.goblinManager.getGoblins().isEmpty
    }
    
    private func useMaxHealthTargeting(from casterPosition: CGPoint, by playerState: PlayerState, in scene: GameScene) -> Bool {
        let allGoblins = scene.goblinManager.getGoblins()
        guard !allGoblins.isEmpty else { return false }
        
        // Find goblin(s) with maximum health
        let maxHealth = allGoblins.map { $0.health }.max() ?? 0
        let maxHealthGoblins = allGoblins.filter { $0.health == maxHealth }
        
        // If multiple goblins have max health, find the closest one
        let targetGoblin = maxHealthGoblins.min { goblin1, goblin2 in
            casterPosition.distance(to: goblin1.sprite.position) < casterPosition.distance(to: goblin2.sprite.position)
        }
        
        guard let target = targetGoblin else { return false }
        
        // Create visual effect at target with modified AOE size
        let modifiedRadius = 30 * playerState.spellAOEMultiplier
        let targetEffect = SKShapeNode(circleOfRadius: modifiedRadius)
        targetEffect.strokeColor = aoeColor
        targetEffect.fillColor = aoeColor.withAlphaComponent(0.3)
        targetEffect.position = target.sprite.position
        targetEffect.zPosition = 90
        scene.addChild(targetEffect)
        
        // Animate the effect
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)
        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        let remove = SKAction.removeFromParent()
        
        // Apply damage after animation completes
        let applyDamage = SKAction.run { [weak self] in
            guard let self = self else { return }
            // Apply modified damage and effect
            let modifiedDamage = self.damage * playerState.spellPowerMultiplier
            target.applyDamage(modifiedDamage)
            if let effect = self.effect {
                effect.apply(spell: self, on: target)
            }
        }
        
        // Run the complete sequence
        targetEffect.run(SKAction.sequence([scaleUp, fadeOut, remove, applyDamage]))
        
        return true
    }
    
    private func useRandomTargeting(from casterPosition: CGPoint, by playerState: PlayerState, in scene: GameScene) -> Bool {
        let allGoblins = scene.goblinManager.getGoblins()
        guard !allGoblins.isEmpty else { return false }
        
        // Select a random goblin
        let targetGoblin = allGoblins.randomElement()
        guard let target = targetGoblin else { return false }
        
        // Create the special projectile
        let specialNode = SKSpriteNode(imageNamed: name)
        specialNode.size = CGSize(width: 50 * playerState.spellAOEMultiplier, height: 50 * playerState.spellAOEMultiplier)
        specialNode.position = casterPosition
        specialNode.zPosition = 95
        scene.addChild(specialNode)
        
        // Calculate angle for rotation
        let dx = target.sprite.position.x - casterPosition.x
        let dy = target.sprite.position.y - casterPosition.y
        let angle = atan2(dy, dx)
        specialNode.zRotation = angle + .pi / 2
        
        // Calculate travel duration based on distance and spell speed
        let distance = casterPosition.distance(to: target.sprite.position)
        let baseSpeed: CGFloat = 500 // pixels per second
        let modifiedSpeed = baseSpeed * playerState.spellSpeedMultiplier
        let travelDuration = TimeInterval(distance / modifiedSpeed)
        
        // Create the movement animation
        let moveAction = SKAction.move(to: target.sprite.position, duration: travelDuration)
        let rotateAction = SKAction.rotate(byAngle: .pi * 2, duration: travelDuration)
        
        // Create impact effect and apply damage
        let createImpactAndDamage = SKAction.run { [weak self] in
            guard let self = self else { return }
            
            // Create visual effect at target with modified AOE size
            let modifiedRadius = 30 * playerState.spellAOEMultiplier
            let targetEffect = SKShapeNode(circleOfRadius: modifiedRadius)
            targetEffect.strokeColor = self.aoeColor
            targetEffect.fillColor = self.aoeColor.withAlphaComponent(0.3)
            targetEffect.position = target.sprite.position
            targetEffect.zPosition = 90
            scene.addChild(targetEffect)
            
            // Animate the impact
            let impactScaleUp = SKAction.scale(to: 1.5, duration: 0.2)
            let impactFadeOut = SKAction.fadeOut(withDuration: 0.2)
            let impactRemove = SKAction.removeFromParent()
            targetEffect.run(SKAction.sequence([impactScaleUp, impactFadeOut, impactRemove]))
            
            // Apply modified damage and effect
            let modifiedDamage = self.damage * playerState.spellPowerMultiplier
            target.applyDamage(modifiedDamage)
            if let effect = self.effect {
                effect.apply(spell: self, on: target)
            }
        }
        
        let removeSpecial = SKAction.removeFromParent()
        
        // Run the complete sequence
        let sequence = SKAction.sequence([
            SKAction.group([moveAction, rotateAction]),
            createImpactAndDamage,
            removeSpecial
        ])
        
        specialNode.run(sequence)
        
        return true
    }
    
    func getEffectiveElapsedTime() -> TimeInterval {
        guard let lastUsed = lastUsedTime else { return cooldown }
        
        var effectiveElapsed = Date().timeIntervalSince(lastUsed)
        
        // Subtract the total paused time
        effectiveElapsed -= totalPausedTime
        
        // If currently paused, also subtract the current pause duration
        if let pauseStart = pauseStartTime {
            effectiveElapsed -= Date().timeIntervalSince(pauseStart)
        }
        
    //     let modifiedSpecial = Special(
    //         name: self.name,
    //         aoeRadius: self.aoeRadius,
    //         aoeColor: self.aoeColor,
    //         duration: self.duration,
    //         damage: self.damage * gameScene.playerState.spellPowerMultiplier,
    //         effect: self.effect,
    //         cooldown: self.cooldown,
    //         targetingMode: self.targetingMode,
    //         rarity: self.rarity
    //     )
    //     gameScene.applySpecial(modifiedSpecial, at: position)
    // }
        return effectiveElapsed
    }
}

protocol SpecialEffect {
    func apply(spell: Special, on goblin: Goblin.GoblinContainer)
}
