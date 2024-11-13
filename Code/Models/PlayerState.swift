import Foundation
import CoreGraphics

class PlayerState {
    // Castle state
    var castleHealth: CGFloat = 100 {
        didSet {
            onCastleHealthChanged?(castleHealth)
        }
    }
    let maxCastleHealth: CGFloat = 100
    
    // Wizard state
    var playerOneMana: CGFloat = 100 {
        didSet {
            onPlayerOneManaChanged?(playerOneMana)
        }
    }
    var playerTwoMana: CGFloat = 100 {
        didSet {
            onPlayerTwoManaChanged?(playerTwoMana)
        }
    }
    let maxMana: CGFloat = 100
    let spellCost: CGFloat = 20
    let manaRegenRate: CGFloat = 7.5
    
    // Callbacks for binding
    var onCastleHealthChanged: ((CGFloat) -> Void)?
    var onPlayerOneManaChanged: ((CGFloat) -> Void)?
    var onPlayerTwoManaChanged: ((CGFloat) -> Void)?
    
    // Score state
    var score: Int = 0 {
        didSet {
            onScoreChanged?(score)
        }
    }
    var onScoreChanged: ((Int) -> Void)?
    
    func addScore(points: Int) {
        score += points
    }
    
    func regenerateMana() {
        playerOneMana = min(maxMana, playerOneMana + manaRegenRate)
        playerTwoMana = min(maxMana, playerTwoMana + manaRegenRate)
    }
    
    func takeDamage(_ damage: CGFloat) -> Bool {
        castleHealth = max(0, castleHealth - damage)
        return castleHealth <= 0
    }
    
    func reset() {
        castleHealth = maxCastleHealth
        playerOneMana = maxMana
        playerTwoMana = maxMana
        score = 0  // Reset score
    }
    
    func useSpell(isPlayerOne: Bool) -> Bool {
        let currentMana = isPlayerOne ? playerOneMana : playerTwoMana
        
        if currentMana < spellCost {
            return false
        }
        
        if isPlayerOne {
            playerOneMana -= spellCost
        } else {
            playerTwoMana -= spellCost
        }
        
        return true
    }
} 