//
//  WaveConfig.swift
//  WizardsandGoblins
//
//  Created by Kevin Sandke on 11/25/24.
//

import Foundation

// Spawn pattern types
public enum SpawnPattern {
    case single
    case line(count: Int)
    case surrounded(centerCount: Int, surroundCount: Int)
    case stream(count: Int, interval: TimeInterval)
    case vFormation(count: Int)
    case circle(count: Int, radius: CGFloat)
    case crossFormation(count: Int)
    case spiral(count: Int, radius: CGFloat)
    case random(count: Int, spread: CGFloat)
    
    public var goblinCount: Int {
        switch self {
        case .single:
            return 1
        case .line(let count):
            return count
        case .surrounded(let centerCount, let surroundCount):
            return centerCount + surroundCount
        case .stream(let count, _):
            return count
        case .vFormation(let count):
            return count
        case .circle(let count, _):
            return count
        case .crossFormation(let count):
            return count * 4 + 1  // 4 arms plus center
        case .spiral(let count, _):
            return count
        case .random(let count, _):
            return count
        }
    }
}

// Configuration for spawn patterns
public struct SpawnPatternConfig {
    public let pattern: SpawnPattern
    public let probability: Double
    
    public init(pattern: SpawnPattern, probability: Double) {
        self.pattern = pattern
        self.probability = probability
    }
}

// Main wave configuration
public struct WaveConfig {
    public var goblinTypeProbabilities: [Goblin.GoblinType: Double]
    public var maxGoblins: Int
    public var baseSpawnInterval: TimeInterval
    public var spawnPatterns: [SpawnPatternConfig]
    
    public init(goblinTypeProbabilities: [Goblin.GoblinType: Double], maxGoblins: Int, baseSpawnInterval: TimeInterval, spawnPatterns: [SpawnPatternConfig]) {
        self.goblinTypeProbabilities = goblinTypeProbabilities
        self.maxGoblins = maxGoblins
        self.baseSpawnInterval = baseSpawnInterval
        self.spawnPatterns = spawnPatterns
    }
    
    // Add a static function to create default configurations
    public static func createWaveConfigs() -> [Int: WaveConfig] {
        return [
            -1: WaveConfig( // Default wave configuration
                goblinTypeProbabilities: [.normal: 60.0, .small: 20.0, .large: 20.0],
                maxGoblins: 7,
                baseSpawnInterval: 2.0,
                spawnPatterns: [
                    SpawnPatternConfig(pattern: .single, probability: 70.0),
                    SpawnPatternConfig(pattern: .line(count: 3), probability: 30.0)
                ]
            ),
            1: WaveConfig(
                goblinTypeProbabilities: [.normal: 100.0],
                maxGoblins: 3,
                baseSpawnInterval: 3.0,
                spawnPatterns: [
                    SpawnPatternConfig(pattern: .single, probability: 100.0)
                ]
            ),
            2: WaveConfig( //use this config for testing
                goblinTypeProbabilities: [.normal: 100.0],
                maxGoblins: 10,
                baseSpawnInterval: 2.0,
                spawnPatterns: [
                    SpawnPatternConfig(pattern: .single, probability: 70.0),
                    SpawnPatternConfig(pattern: .line(count: 3), probability: 30.0)
                ]
            ),
            3: WaveConfig(
                goblinTypeProbabilities: [.normal: 100.0],
                maxGoblins: 10,
                baseSpawnInterval: 2.0,
                spawnPatterns: [
                    SpawnPatternConfig(pattern: .single, probability: 70.0),
                    SpawnPatternConfig(pattern: .line(count: 3), probability: 30.0)
                ]
            ),
            4: WaveConfig(
                goblinTypeProbabilities: [.normal: 70.0, .small: 15.0, .large: 15.0],
                maxGoblins: 15,
                baseSpawnInterval: 1.8,
                spawnPatterns: [
                    SpawnPatternConfig(pattern: .single, probability: 50.0),
                    SpawnPatternConfig(pattern: .line(count: 3), probability: 30.0),
                    SpawnPatternConfig(pattern: .surrounded(centerCount: 1, surroundCount: 4), probability: 20.0)
                ]
            ),
            5: WaveConfig(
                goblinTypeProbabilities: [.normal: 40.0, .small: 40.0, .ranged: 20.0],
                maxGoblins: 25,
                baseSpawnInterval: 1.5,
                spawnPatterns: [
        SpawnPatternConfig(pattern: .vFormation(count: 3), probability: 60.0),
                    SpawnPatternConfig(pattern: .circle(count: 5, radius: 100), probability: 40.0)
                ]
            ),
6: WaveConfig(
    goblinTypeProbabilities: [.normal: 30.0, .small: 30.0, .large: 20.0, .ranged: 20.0],
    maxGoblins: 30,
    baseSpawnInterval: 1.4,
    spawnPatterns: [
        SpawnPatternConfig(pattern: .crossFormation(count: 2), probability: 40.0),
        SpawnPatternConfig(pattern: .spiral(count: 6, radius: 150), probability: 30.0),
        SpawnPatternConfig(pattern: .random(count: 4, spread: 120), probability: 30.0)
    ]
),
7: WaveConfig(
    goblinTypeProbabilities: [.normal: 20.0, .small: 30.0, .large: 30.0, .ranged: 20.0],
    maxGoblins: 35,
    baseSpawnInterval: 1.3,
    spawnPatterns: [
        SpawnPatternConfig(pattern: .circle(count: 8, radius: 150), probability: 35.0),
        SpawnPatternConfig(pattern: .vFormation(count: 5), probability: 35.0),
        SpawnPatternConfig(pattern: .crossFormation(count: 3), probability: 30.0)
    ]
),
8: WaveConfig(
    goblinTypeProbabilities: [.normal: 20.0, .small: 20.0, .large: 35.0, .ranged: 25.0],
    maxGoblins: 40,
    baseSpawnInterval: 1.2,
    spawnPatterns: [
        SpawnPatternConfig(pattern: .spiral(count: 8, radius: 200), probability: 40.0),
        SpawnPatternConfig(pattern: .random(count: 6, spread: 150), probability: 30.0),
        SpawnPatternConfig(pattern: .circle(count: 10, radius: 180), probability: 30.0)
    ]
),
9: WaveConfig(
    goblinTypeProbabilities: [.normal: 15.0, .small: 25.0, .large: 35.0, .ranged: 25.0],
    maxGoblins: 45,
    baseSpawnInterval: 1.1,
    spawnPatterns: [
        SpawnPatternConfig(pattern: .crossFormation(count: 4), probability: 35.0),
        SpawnPatternConfig(pattern: .vFormation(count: 6), probability: 35.0),
        SpawnPatternConfig(pattern: .spiral(count: 10, radius: 250), probability: 30.0)
    ]
),
10: WaveConfig(
    goblinTypeProbabilities: [.normal: 10.0, .small: 25.0, .large: 40.0, .ranged: 25.0],
    maxGoblins: 50,
    baseSpawnInterval: 1.0,
    spawnPatterns: [
        SpawnPatternConfig(pattern: .circle(count: 12, radius: 200), probability: 30.0),
        SpawnPatternConfig(pattern: .crossFormation(count: 5), probability: 35.0),
        SpawnPatternConfig(pattern: .random(count: 8, spread: 200), probability: 35.0)
    ]
),
11: WaveConfig(
    goblinTypeProbabilities: [.normal: 10.0, .small: 20.0, .large: 40.0, .ranged: 30.0],
    maxGoblins: 55,
    baseSpawnInterval: 0.9,
    spawnPatterns: [
        SpawnPatternConfig(pattern: .spiral(count: 12, radius: 250), probability: 40.0),
        SpawnPatternConfig(pattern: .vFormation(count: 7), probability: 30.0),
        SpawnPatternConfig(pattern: .circle(count: 14, radius: 220), probability: 30.0)
    ]
),
12: WaveConfig(
    goblinTypeProbabilities: [.small: 30.0, .large: 40.0, .ranged: 30.0],
    maxGoblins: 60,
    baseSpawnInterval: 0.9,
    spawnPatterns: [
        SpawnPatternConfig(pattern: .crossFormation(count: 6), probability: 35.0),
        SpawnPatternConfig(pattern: .random(count: 10, spread: 250), probability: 35.0),
        SpawnPatternConfig(pattern: .spiral(count: 14, radius: 300), probability: 30.0)
    ]
),
13: WaveConfig(
    goblinTypeProbabilities: [.small: 25.0, .large: 45.0, .ranged: 30.0],
    maxGoblins: 65,
    baseSpawnInterval: 0.8,
    spawnPatterns: [
        SpawnPatternConfig(pattern: .circle(count: 16, radius: 250), probability: 40.0),
        SpawnPatternConfig(pattern: .vFormation(count: 8), probability: 30.0),
        SpawnPatternConfig(pattern: .crossFormation(count: 7), probability: 30.0)
    ]
),
14: WaveConfig(
    goblinTypeProbabilities: [.small: 20.0, .large: 45.0, .ranged: 35.0],
    maxGoblins: 70,
    baseSpawnInterval: 0.8,
    spawnPatterns: [
        SpawnPatternConfig(pattern: .spiral(count: 16, radius: 300), probability: 35.0),
        SpawnPatternConfig(pattern: .random(count: 12, spread: 300), probability: 35.0),
        SpawnPatternConfig(pattern: .circle(count: 18, radius: 280), probability: 30.0)
    ]
),
15: WaveConfig(
    goblinTypeProbabilities: [.small: 15.0, .large: 50.0, .ranged: 35.0],
    maxGoblins: 75,
    baseSpawnInterval: 0.7,
    spawnPatterns: [
        SpawnPatternConfig(pattern: .crossFormation(count: 8), probability: 40.0),
        SpawnPatternConfig(pattern: .vFormation(count: 9), probability: 30.0),
        SpawnPatternConfig(pattern: .spiral(count: 18, radius: 350), probability: 30.0)
    ]
),
16: WaveConfig(
    goblinTypeProbabilities: [.small: 15.0, .large: 50.0, .ranged: 35.0],
    maxGoblins: 80,
    baseSpawnInterval: 0.7,
    spawnPatterns: [
        SpawnPatternConfig(pattern: .circle(count: 20, radius: 300), probability: 35.0),
        SpawnPatternConfig(pattern: .random(count: 14, spread: 350), probability: 35.0),
        SpawnPatternConfig(pattern: .crossFormation(count: 9), probability: 30.0)
    ]
),
17: WaveConfig(
    goblinTypeProbabilities: [.small: 10.0, .large: 55.0, .ranged: 35.0],
    maxGoblins: 85,
    baseSpawnInterval: 0.6,
    spawnPatterns: [
        SpawnPatternConfig(pattern: .spiral(count: 20, radius: 400), probability: 40.0),
        SpawnPatternConfig(pattern: .vFormation(count: 10), probability: 30.0),
        SpawnPatternConfig(pattern: .circle(count: 22, radius: 320), probability: 30.0)
    ]
),
18: WaveConfig(
    goblinTypeProbabilities: [.small: 10.0, .large: 55.0, .ranged: 35.0],
    maxGoblins: 90,
    baseSpawnInterval: 0.6,
    spawnPatterns: [
        SpawnPatternConfig(pattern: .crossFormation(count: 10), probability: 35.0),
        SpawnPatternConfig(pattern: .random(count: 16, spread: 400), probability: 35.0),
        SpawnPatternConfig(pattern: .spiral(count: 22, radius: 450), probability: 30.0)
    ]
),
19: WaveConfig(
    goblinTypeProbabilities: [.small: 5.0, .large: 60.0, .ranged: 35.0],
    maxGoblins: 95,
    baseSpawnInterval: 0.5,
    spawnPatterns: [
        SpawnPatternConfig(pattern: .circle(count: 24, radius: 350), probability: 35.0),
        SpawnPatternConfig(pattern: .vFormation(count: 12), probability: 35.0),
        SpawnPatternConfig(pattern: .crossFormation(count: 11), probability: 30.0)
    ]
),
20: WaveConfig(
    goblinTypeProbabilities: [.small: 5.0, .large: 60.0, .ranged: 35.0],
    maxGoblins: 100,
    baseSpawnInterval: 0.5,
    spawnPatterns: [
        SpawnPatternConfig(pattern: .spiral(count: 24, radius: 500), probability: 40.0),
        SpawnPatternConfig(pattern: .random(count: 18, spread: 450), probability: 30.0),
        SpawnPatternConfig(pattern: .circle(count: 26, radius: 400), probability: 30.0)
    ]
)
        ]
    }
    
    // Add a function to create a default config for higher waves
    public static func createDefaultConfig(forWave wave: Int) -> WaveConfig {
        var config = WaveConfig(
            goblinTypeProbabilities: [.normal: 100.0],
            maxGoblins: 10,
            baseSpawnInterval: 2.0,
            spawnPatterns: [
                SpawnPatternConfig(pattern: .single, probability: 100.0)
            ]
        )
        
        // Modify based on wave number
        config.maxGoblins = (wave - 1) * 5
        config.baseSpawnInterval = max(2.0 - 0.1 * Double(wave - 1), 0.5)
        
        return config
    }
}

