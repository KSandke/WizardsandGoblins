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
    let manaRegenRate: CGFloat = 7.5
    
    // Spell slots
    var playerOneSpell: Spell
    var playerTwoSpell: Spell
    
    // Constructor
    init() {
        // Initialize default spells
        playerOneSpell = Spell(
            name: "Fireball",
            manaCost: 20,
            aoeRadius: 50,
            duration: 1.0,
            damage: 25,
            specialEffect: nil
        )

        playerTwoSpell = Spell(
            name: "IceSpell",
            manaCost: 30,
            aoeRadius: 50,
            duration: 1.0,
            damage: 15,
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
        castleHealth = maxCastleHealth
        playerOneMana = maxMana
        playerTwoMana = maxMana
        score = 0  // Reset score
        coins = 0  // Reset coins
        // Reset spells if needed
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