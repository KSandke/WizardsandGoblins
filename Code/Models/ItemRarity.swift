import Foundation
import UIKit

enum ItemRarity: Int, CaseIterable {
    case common = 0
    case uncommon = 1
    case rare = 2
    case epic = 3
    case legendary = 4
    
    var color: UIColor {
        switch self {
        case .common:
            return .white
        case .uncommon:
            return UIColor(red: 0.2, green: 0.8, blue: 0.2, alpha: 1.0)  // Green
        case .rare:
            return UIColor(red: 0.0, green: 0.4, blue: 1.0, alpha: 1.0)  // Blue
        case .epic:
            return UIColor(red: 0.6, green: 0.2, blue: 0.8, alpha: 1.0)  // Purple
        case .legendary:
            return UIColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 1.0)  // Orange
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
