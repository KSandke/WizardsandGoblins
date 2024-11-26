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
                goblinTypeProbabilities: [.ranged: 100.0],
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
                goblinTypeProbabilities: [.small: 100.0],
                maxGoblins: 20,
                baseSpawnInterval: 1.5,
                spawnPatterns: [
                    SpawnPatternConfig(pattern: .single, probability: 70.0),
                    SpawnPatternConfig(pattern: .line(count: 3), probability: 30.0)
                ]
            ),
            6: WaveConfig(
                goblinTypeProbabilities: [.normal: 40.0, .small: 25.0, .large: 25.0, .ranged: 10.0],
                maxGoblins: 25,
                baseSpawnInterval: 1.5,
                spawnPatterns: [
                    SpawnPatternConfig(pattern: .single, probability: 60.0),
                    SpawnPatternConfig(pattern: .line(count: 3), probability: 30.0),
                    SpawnPatternConfig(pattern: .surrounded(centerCount: 1, surroundCount: 4), probability: 10.0)
                ]
            ),
            7: WaveConfig(
                goblinTypeProbabilities: [.small: 40.0, .large: 60.0],
                maxGoblins: 30,
                baseSpawnInterval: 1.2,
                spawnPatterns: [
                    SpawnPatternConfig(pattern: .single, probability: 80.0),
                    SpawnPatternConfig(pattern: .line(count: 3), probability: 20.0)
                ]
            ),
            8: WaveConfig(
                goblinTypeProbabilities: [.ranged: 100.0],
                maxGoblins: 30,
                baseSpawnInterval: 1.2,
                spawnPatterns: [
                    SpawnPatternConfig(pattern: .single, probability: 100.0)
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

