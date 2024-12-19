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

    // Physics categories
    static let potionCategory: UInt32 = 0x1 << 5
    static let spellCategory: UInt32 = 0x1 << 2

    // Potion configurations
    static let potionSpawnInterval: TimeInterval = 15.0 // Potion appears every 15 seconds
    static let manaPotionDuration: TimeInterval = 5.0   // Infinite mana lasts for 5 seconds
    static let smallHealthPotionAmount: CGFloat = 20.0
    static let largeHealthPotionAmount: CGFloat = 50.0

    // Path Configuration
    static let goblinPathPoints: [CGPoint] = [
        CGPoint(x: 0.8, y: 1.2),    // Start (relative to screen width/height)
        CGPoint(x: 0.8, y: 0.6),
        CGPoint(x: 0.6, y: 0.6),
        CGPoint(x: 0.6, y: 0.9),
        CGPoint(x: 0.1, y: 0.9),
        CGPoint(x: 0.1, y: 0.8),
        CGPoint(x: 0.5, y: 0.8),
        CGPoint(x: 0.5, y: 0.7),
        CGPoint(x: 0.1, y: 0.7),
        CGPoint(x: 0.1, y: 0.5),
        CGPoint(x: 0.9, y: 0.5),
        CGPoint(x: 0.9, y: 0.4),
        CGPoint(x: 0.7, y: 0.4),
        CGPoint(x: 0.1, y: 0.4),
        CGPoint(x: 0.1, y: 0.2),
        CGPoint(x: 0.3, y: 0.2),
        CGPoint(x: 0.3, y: 0.3),
        CGPoint(x: 0.5, y: 0.3),
        CGPoint(x: 0.5, y: 0.2)
    ]
}
