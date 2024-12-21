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
            return count + 1  // 4 arms plus center
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

