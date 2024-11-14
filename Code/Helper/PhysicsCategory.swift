import SpriteKit
struct PhysicsCategory {
    static let none: UInt32 = 0
    static let goblin: UInt32 = 0b1        // 1
    static let goblinProjectile: UInt32 = 0b10       // 2
    static let castle: UInt32 = 0b100      // 4
    static let spell: UInt32 = 0b1000      // 8
    // Add more categories as needed
}