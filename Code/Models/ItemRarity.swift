import Foundation

enum ItemRarity: Int, CaseIterable {
    case common = 0
    case uncommon = 1
    case rare = 2
    case epic = 3
    case legendary = 4
    
    var color: SKColor {
        switch self {
        case .common:
            return .white
        case .uncommon:
            return .green
        case .rare:
            return .blue
        case .epic:
            return .purple
        case .legendary:
            return .orange
        }
    }
    
    var dropChance: Double {
        switch self {
        case .common:
            return 0.60      // 60%
        case .uncommon:
            return 0.25      // 25%
        case .rare:
            return 0.10      // 10%
        case .epic:
            return 0.04      // 4%
        case .legendary:
            return 0.01      // 1%
        }
    }
    
    var name: String {
        switch self {
        case .common:
            return "Common"
        case .uncommon:
            return "Uncommon"
        case .rare:
            return "Rare"
        case .epic:
            return "Epic"
        case .legendary:
            return "Legendary"
        }
    }
}
