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
    var maxMana: CGFloat = 100 {
        didSet {
            // When maxMana increases, increase current mana proportionally
            let manaPercentageP1 = playerOneMana / oldValue
            let manaPercentageP2 = playerTwoMana / oldValue
            playerOneMana = maxMana * manaPercentageP1
            playerTwoMana = maxMana * manaPercentageP2
        }
    }
    private(set) var manaRegenRate: CGFloat = 7.5
    
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
            manaCost: 20,
            aoeRadius: 50,
            duration: 1.0,
            damage: 25,
            specialEffect: nil
        )

        playerTwoSpell = Spell(
            name: "IceSpell",
            manaCost: 20,
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
    var onPlayerOneManaChanged: ((CGFloat) -> Void)?
    var onPlayerTwoManaChanged: ((CGFloat) -> Void)?
    
    // Score state
    var score: Int = 0 {
        didSet {
            onScoreChanged?(score)
        }
    }
    var onScoreChanged: ((Int) -> Void)?
    
    // Coins state
    var coins: Int = 0 {
        didSet {
            onCoinsChanged?(coins)
        }
    }
    var onCoinsChanged: ((Int) -> Void)?
    
    func addScore(points: Int) {
        score += points
    }
    
    func addCoins(_ amount: Int) {
        coins += amount
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
        maxHealth = maxCastleHealth  // Reset max health
        castleHealth = maxHealth
        maxMana = 100  // Reset max mana to initial value
        playerOneMana = maxMana
        playerTwoMana = maxMana
        score = 0
        coins = 0
        spellPowerMultiplier = 1.0  // Reset spell power
        manaRegenRate = 7.5  // Reset mana regen
    }
    
    func useSpell(isPlayerOne: Bool, cost: CGFloat) -> Bool {
        let currentMana = isPlayerOne ? playerOneMana : playerTwoMana
        
        if currentMana < cost {
            return false
        }
        
        if isPlayerOne {
            playerOneMana -= cost
        } else {
            playerTwoMana -= cost
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
