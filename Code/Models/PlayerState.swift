import Foundation
import CoreGraphics
import SpriteKit

class PlayerState {
    // Castle state
    var castleHealth: CGFloat = 100 {
        didSet {
            onCastleHealthChanged?(castleHealth)
        }
    }
    let maxCastleHealth: CGFloat = 100
    
    // Wizard state
    var playerOneSpellCharges: Int = 5 {
        didSet {
            onPlayerOneChargesChanged?(playerOneSpellCharges)
        }
    }
    var playerTwoSpellCharges: Int = 5 {
        didSet {
            onPlayerTwoChargesChanged?(playerTwoSpellCharges)
        }
    }
    var maxSpellCharges: Int = 5 {
        didSet {
            onMaxSpellChargesChanged?(maxSpellCharges)
        }
    }
    
    // Spell slots
    var playerOneSpell: Spell
    var playerTwoSpell: Spell
    
    // New properties for upgrades
    var maxHealth: CGFloat = 100 {
        didSet {
            // When maxHealth increases, increase current health proportionally
            let healthPercentage = castleHealth / oldValue
            castleHealth = maxHealth * healthPercentage
        }
    }
    
    var spellPowerMultiplier: CGFloat = 1.0
    
    // Constructor
    init() {
        // Initialize default spells
        playerOneSpell = Spell(
            name: "spell1",
            aoeRadius: 50,
            duration: 1.0,
            damage: 25,
            specialEffect: nil
        )

        playerTwoSpell = Spell(
            name: "IceSpell",
            aoeRadius: 50,
            duration: 1.0,
            damage: 20,
            specialEffect: { spell, container in
                // Apply slowing effect
                container.sprite.speed = 0.5 // Reduce speed
                let wait = SKAction.wait(forDuration: 5.0) // Slow duration
                let resetSpeed = SKAction.run {
                    container.sprite.speed = 1.0
                }
                container.sprite.run(SKAction.sequence([wait, resetSpeed]))
            }
        )
        
        // Initialize maxHealth to match castleHealth
        maxHealth = maxCastleHealth
    }
    
    // Callbacks for binding
    var onCastleHealthChanged: ((CGFloat) -> Void)?
    var onPlayerOneChargesChanged: ((Int) -> Void)?
    var onPlayerTwoChargesChanged: ((Int) -> Void)?
    var onScoreChanged: ((Int) -> Void)?
    var onCoinsChanged: ((Int) -> Void)?
    var onMaxSpellChargesChanged: ((Int) -> Void)?
    
    // Score state
    var score: Int = 0 {
        didSet {
            onScoreChanged?(score)
        }
    }
    
    // Coins state
    var coins: Int = 0 {
        didSet {
            onCoinsChanged?(coins)
        }
    }
    
    
    func addScore(points: Int) {
        score += points
    }
    
    func addCoins(_ amount: Int) {
        coins += amount
    }
    
    // Update regenerateMana function
    func regenerateSpellCharges() {
        playerOneSpellCharges = min(maxSpellCharges, playerOneSpellCharges + 1)
        playerTwoSpellCharges = min(maxSpellCharges, playerTwoSpellCharges + 1)
    }
    
    func takeDamage(_ damage: CGFloat) -> Bool {
        castleHealth = max(0, castleHealth - damage)
        return castleHealth <= 0
    }
    
    // Update reset function
    func reset() {
        maxHealth = maxCastleHealth  // Reset max health
        castleHealth = maxHealth
        score = 0
        coins = 0
        spellPowerMultiplier = 1.0  // Reset spell power
        playerOneSpellCharges = maxSpellCharges
        playerTwoSpellCharges = maxSpellCharges
    }
    
    // Update useSpell function
    func useSpell(isPlayerOne: Bool, cost: CGFloat) -> Bool {
        let currentCharges = isPlayerOne ? playerOneSpellCharges : playerTwoSpellCharges
        
        if currentCharges < 1 {
            return false
        }
        
        if isPlayerOne {
            playerOneSpellCharges -= 1
        } else {
            playerTwoSpellCharges -= 1
        }
        
        return true
    }

    func getSpell(isPlayerOne: Bool) -> Spell {
        return isPlayerOne ? playerOneSpell : playerTwoSpell
    }
    
    func setSpell(forPlayerOne: Bool, spell: Spell) {
        if forPlayerOne {
            playerOneSpell = spell
        } else {
            playerTwoSpell = spell
        }
    }
} 
