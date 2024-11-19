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
    var maxCastleHealth: CGFloat = 100
    
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
    
    // Spells
    var unlockedSpells: [Spell] = []
    var equippedSpells: [Spell?] = [nil, nil]
    private var isUsingPrimarySpell: Bool = true
    
    // New properties for upgrades
    var maxHealth: CGFloat = 100 {
        didSet {
            let healthPercentage = castleHealth / oldValue
            castleHealth = maxHealth * healthPercentage
        }
    }
    
    var spellPowerMultiplier: CGFloat = 1.0
    
    // Powerups
    var powerups: [PowerUp] = []
    
    // Constructor
    init() {
        // Initialize spells
        let fireball = FireballSpell()
        let iceSpell = IceSpell()
        let lightningSpell = LightningSpell()
        unlockedSpells = [fireball, lightningSpell]
        equippedSpells = [lightningSpell, iceSpell]
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
    
    func regenerateSpellCharges() {
        playerOneSpellCharges = min(maxSpellCharges, playerOneSpellCharges + 1)
        playerTwoSpellCharges = min(maxSpellCharges, playerTwoSpellCharges + 1)
    }
    
    func takeDamage(_ damage: CGFloat) -> Bool {
        castleHealth = max(0, castleHealth - damage)
        return castleHealth <= 0
    }
    
    func reset() {
        maxHealth = maxCastleHealth
        castleHealth = maxHealth
        score = 0
        coins = 0
        spellPowerMultiplier = 1.0
        playerOneSpellCharges = maxSpellCharges
        playerTwoSpellCharges = maxSpellCharges
        powerups = []
    }
    
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
    
    func getSpell(isPlayerOne: Bool) -> Spell? {
        let spellIndex = isPlayerOne ? 0 : 1
        return equippedSpells[spellIndex]
    }
    
    func getSpellName(forSlot slot: Int) -> String {
        return equippedSpells[slot]?.name ?? "DefaultSpell"
    }
}

class PowerUp {
    let name: String
    let icon: String
    let effect: (PlayerState) -> Void
    
    init(name: String, icon: String, effect: @escaping (PlayerState) -> Void) {
        self.name = name
        self.icon = icon
        self.effect = effect
    }
} 
