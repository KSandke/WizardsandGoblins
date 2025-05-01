# Wizards and Goblins

A tower defense-style game where you play as a wizard defending your castle against waves of goblins using spells and special abilities.

## Game Features

### Wave System
- Progressive difficulty through 20 unique waves
- Each wave introduces new goblin types and patterns
- Wave configurations include:
  - Normal goblins (Waves 1-3)
  - Large goblins (Waves 4-5)
  - Ranged goblins (Waves 6-8)
  - Small goblins (Wave 9+)
  - Mixed goblin types (Waves 11-20)

### Combat System
- Multiple spell types
- Combo system for skilled play
- Special abilities with cooldowns
- Mana management system
- Health and mana potions

### Goblin Types
- Normal: Basic goblin units
- Large: Tougher, more health
- Small: Fast, less health
- Ranged: Attacks from distance

### Spawn Patterns
Various tactical formations including:
- Single spawns
- Line formations
- V-formations
- Cross formations
- Circle formations
- Spiral patterns
- Random clusters

### Player Features
- Spell charge system
- Mana regeneration
- Score tracking
- Perfect wave bonuses
- Shop system between waves

### Technical Features
- Built with SpriteKit
- Physics-based interactions
- Sound effects and music
- Haptic feedback
- Tutorial system for new players
- Dynamic difficulty scaling

## Game Flow
1. Tutorial for new players
2. Wave-based combat
3. Score screen after each wave
4. Shop interface between waves
5. Progressive difficulty increase

## Wave Management
The game includes a sophisticated wave management system that:
- Tracks goblin spawns and deaths
- Manages wave completion
- Handles timeout scenarios
- Controls spawn patterns and intervals

Reference code for wave configuration:

```71:254:Code/Models/WaveConfig.swift
    // MARK: - Updated wave configs
    public static func createWaveConfigs() -> [Int: WaveConfig] {
        return [
            // Keep the default wave configuration at -1
            -1: WaveConfig( 
                goblinTypeProbabilities: [.normal: 60.0, .small: 20.0, .large: 20.0],
                maxGoblins: 7,
                baseSpawnInterval: 2.0,
                spawnPatterns: [
                    // This default remains in case it is still used somewhere
                    SpawnPatternConfig(pattern: .single, probability: 100.0)
                ]
            ),
            
            // 1–3: Only normal goblins
            1: WaveConfig(
                goblinTypeProbabilities: [.normal: 100.0],
                maxGoblins: 8,
                baseSpawnInterval: 1.0,
                spawnPatterns: [
                    SpawnPatternConfig(pattern: .single, probability: 100.0)
                ]
            ),
            2: WaveConfig(
                goblinTypeProbabilities: [.normal: 100.0],
                maxGoblins: 12,
                baseSpawnInterval: 1.1,
                spawnPatterns: [
                    SpawnPatternConfig(pattern: .single, probability: 100.0)
                ]
            ),
            3: WaveConfig(
                goblinTypeProbabilities: [.normal: 100.0],
                maxGoblins: 16,
                baseSpawnInterval: 1.2,
                spawnPatterns: [
                    SpawnPatternConfig(pattern: .single, probability: 100.0)
                ]
            ),
            
            // 4–5: Introduce large goblins
            4: WaveConfig(
                goblinTypeProbabilities: [.normal: 80.0, .large: 20.0],
                maxGoblins: 20,
                baseSpawnInterval: 1.3,
                spawnPatterns: [
                    SpawnPatternConfig(pattern: .single, probability: 100.0)
                ]
            ),
            5: WaveConfig(
                goblinTypeProbabilities: [.normal: 70.0, .large: 30.0],
                maxGoblins: 25,
                baseSpawnInterval: 1.4,
                spawnPatterns: [
                    SpawnPatternConfig(pattern: .single, probability: 100.0)
                ]
            ),

            // 6–8: Introduce ranged goblins into the mix
            6: WaveConfig(
                goblinTypeProbabilities: [.normal: 60.0, .large: 20.0, .ranged: 20.0],
                maxGoblins: 30,
                baseSpawnInterval: 1.5,
                spawnPatterns: [
                    SpawnPatternConfig(pattern: .single, probability: 100.0)
                ]
            ),
            7: WaveConfig(
                goblinTypeProbabilities: [.normal: 50.0, .large: 25.0, .ranged: 25.0],
                maxGoblins: 35,
                baseSpawnInterval: 1.6,
                spawnPatterns: [
                    SpawnPatternConfig(pattern: .single, probability: 100.0)
                ]
            ),
            8: WaveConfig(
                goblinTypeProbabilities: [.normal: 50.0, .large: 30.0, .ranged: 20.0],
                maxGoblins: 40,
                baseSpawnInterval: 1.7,
                spawnPatterns: [
                    SpawnPatternConfig(pattern: .single, probability: 100.0)
                ]
            ),

            // 9: Introduce small goblins as well
            9: WaveConfig(
                goblinTypeProbabilities: [.normal: 40.0, .large: 20.0, .ranged: 20.0, .small: 20.0],
                maxGoblins: 45,
                baseSpawnInterval: 1.8,
                spawnPatterns: [
                    SpawnPatternConfig(pattern: .single, probability: 100.0)
                ]
            ),
            10: WaveConfig(
                goblinTypeProbabilities: [.normal: 35.0, .large: 25.0, .ranged: 20.0, .small: 20.0],
                maxGoblins: 50,
                baseSpawnInterval: 1.9,
                spawnPatterns: [
                    SpawnPatternConfig(pattern: .single, probability: 100.0)
                ]
            ),

            // 11–20: Combine all types in varying amounts
            11: WaveConfig(
                goblinTypeProbabilities: [.normal: 30.0, .large: 30.0, .ranged: 20.0, .small: 20.0],
                maxGoblins: 55,
                baseSpawnInterval: 2.0,
                spawnPatterns: [
                    SpawnPatternConfig(pattern: .single, probability: 100.0)
                ]
            ),
            12: WaveConfig(
                goblinTypeProbabilities: [.normal: 28.0, .large: 32.0, .ranged: 20.0, .small: 20.0],
                maxGoblins: 60,
                baseSpawnInterval: 2.1,
                spawnPatterns: [
                    SpawnPatternConfig(pattern: .single, probability: 100.0)
                ]
            ),
            13: WaveConfig(
                goblinTypeProbabilities: [.normal: 25.0, .large: 35.0, .ranged: 20.0, .small: 20.0],
                maxGoblins: 65,
                baseSpawnInterval: 2.2,
                spawnPatterns: [
                    SpawnPatternConfig(pattern: .single, probability: 100.0)
                ]
            ),
            14: WaveConfig(
                goblinTypeProbabilities: [.normal: 25.0, .large: 30.0, .ranged: 25.0, .small: 20.0],
                maxGoblins: 70,
                baseSpawnInterval: 2.3,
                spawnPatterns: [
                    SpawnPatternConfig(pattern: .single, probability: 100.0)
                ]
            ),
            15: WaveConfig(
                goblinTypeProbabilities: [.normal: 20.0, .large: 30.0, .ranged: 25.0, .small: 25.0],
                maxGoblins: 75,
                baseSpawnInterval: 2.4,
                spawnPatterns: [
                    SpawnPatternConfig(pattern: .single, probability: 100.0)
                ]
            ),
            16: WaveConfig(
                goblinTypeProbabilities: [.normal: 15.0, .large: 35.0, .ranged: 25.0, .small: 25.0],
                maxGoblins: 80,
                baseSpawnInterval: 2.5,
                spawnPatterns: [
                    SpawnPatternConfig(pattern: .single, probability: 100.0)
                ]
            ),
            17: WaveConfig(
                goblinTypeProbabilities: [.normal: 15.0, .large: 35.0, .ranged: 30.0, .small: 20.0],
                maxGoblins: 85,
                baseSpawnInterval: 2.6,
                spawnPatterns: [
                    SpawnPatternConfig(pattern: .single, probability: 100.0)
                ]
            ),
            18: WaveConfig(
                goblinTypeProbabilities: [.normal: 10.0, .large: 40.0, .ranged: 30.0, .small: 20.0],
                maxGoblins: 90,
                baseSpawnInterval: 2.7,
                spawnPatterns: [
                    SpawnPatternConfig(pattern: .single, probability: 100.0)
                ]
            ),
            19: WaveConfig(
                goblinTypeProbabilities: [.normal: 5.0, .large: 40.0, .ranged: 35.0, .small: 20.0],
                maxGoblins: 95,
                baseSpawnInterval: 2.8,
                spawnPatterns: [
                    SpawnPatternConfig(pattern: .single, probability: 100.0)
                ]
            ),
            20: WaveConfig(
                goblinTypeProbabilities: [.normal: 5.0, .large: 45.0, .ranged: 30.0, .small: 20.0],
                maxGoblins: 100,
                baseSpawnInterval: 2.9,
                spawnPatterns: [
                    SpawnPatternConfig(pattern: .single, probability: 100.0)
                ]
            )
        ]
```


## Game Configuration
Core game settings and balance values are managed through GameConfig:

```4:74:Code/Config/GameConfig.swift
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
    static let defaultMaxGoblinsPerWave: Int = 50

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

    static let initialSpellCharges: Int = 5

    // Initial game state
    static let initialCoins: Int = 0
    static let initialScore: Int = 0
    static let initialWave: Int = 1
    static let maxSpecialSlots: Int = 4  // Maximum number of special ability slots
}
```



Built by Kevin Sandke and Anthony Mein for Hyel Inc
