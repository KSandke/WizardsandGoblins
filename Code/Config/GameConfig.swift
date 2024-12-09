import Foundation
import CoreGraphics

struct GameConfig {
    // Game Balance
    static let defaultCastleHealth: CGFloat = 100
    static let defaultSpellCharges: Int = 5
    static let defaultMaxSpellCharges: Int = 5
    static let defaultSpellPowerMultiplier: CGFloat = 1.0
    static let defaultSpellAOEMultiplier: CGFloat = 1.0
    static let defaultSpellSpeedMultiplier: CGFloat = 1.0
    static let defaultManaRegenRate: CGFloat = 1.0
    
    // Combat
    static let comboTimeoutDuration: TimeInterval = 3.0
    static let manaPotionDropChance: Double = 0.1
    static let spellChargeRestoreAmount: Int = 2
    
    // Input
    static let swipeThreshold: CGFloat = 50.0
    static let swipeTimeThreshold: TimeInterval = 0.3
    
    // Wave Management
    static let defaultGoblinSpawnInterval: TimeInterval = 2.0
    static let defaultMaxGoblinsPerWave: Int = 10
    
    // Castle
    static let defaultCastlePosition: CGPoint = CGPoint(x: 0, y: 100) // x will be adjusted by screen width

    // Spell
    static let defaultSpellSpeed: CGFloat = 400
    static let maxSpellSlots: Int = 3
}
