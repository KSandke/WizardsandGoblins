import Foundation
import CoreGraphics
import SpriteKit

// First, create a FrostEffect class
class FrostEffect: SpellEffect {
    func apply(spell: Spell, on goblin: Goblin.GoblinContainer) {
        goblin.applyDamage(spell.damage)
        // Apply slowing effect
        goblin.sprite.speed = 0.5
        let wait = SKAction.wait(forDuration: 5.0)
        let resetSpeed = SKAction.run {
            goblin.sprite.speed = 1.0
        }
        goblin.sprite.run(SKAction.sequence([wait, resetSpeed]))
    }
}

protocol SpellCaster {
    var currentSpell: Spell { get set }
    var spellCharges: Int { get set }
    var maxSpellCharges: Int { get set }
    var spellPowerMultiplier: CGFloat { get set }
    var spellAOEMultiplier: CGFloat { get set }
    var spellSpeedMultiplier: CGFloat { get set }
    func cycleSpell()
    func cycleSpellBackwards()
}

class PlayerState: SpellCaster {
    // Castle state
    var castleHealth: CGFloat = GameConfig.defaultCastleHealth {
        didSet {
            onCastleHealthChanged?(castleHealth)
        }
    }
    let maxCastleHealth: CGFloat = GameConfig.defaultCastleHealth
    
    // Wizard state
    var spellCharges: Int = GameConfig.defaultSpellCharges {
        didSet {
            onPlayerChargesChanged?(spellCharges)
        }
    }
    var maxSpellCharges: Int = GameConfig.defaultMaxSpellCharges {
        didSet {
            onMaxSpellChargesChanged?(maxSpellCharges)
        }
    }
    
    var currentSpell: Spell {
        didSet {
            onSpellChanged?(currentSpell)
        }
    }
    
    var maxHealth: CGFloat = GameConfig.defaultCastleHealth {
        didSet {
            let healthPercentage = castleHealth / oldValue
            castleHealth = maxHealth * healthPercentage
        }
    }
    
    var spellPowerMultiplier: CGFloat = GameConfig.defaultSpellPowerMultiplier
    var spellAOEMultiplier: CGFloat = GameConfig.defaultSpellAOEMultiplier
    var spellSpeedMultiplier: CGFloat = GameConfig.defaultSpellSpeedMultiplier
    var manaRegenRate: CGFloat = GameConfig.defaultManaRegenRate
    
    // New properties for upgrades
    private var availableSpells: [Spell] = []
    
    // Add playerPosition property
    var playerPosition: CGPoint = .zero
    
    var consumableSpells: [String: Int] = [:] // Tracks spell name and quantity
    
    // Add after the existing properties
    // Add new properties for combo tracking
    var currentCombo: Int = 0 {
        didSet {
            // Update highest combo if current exceeds it
            if currentCombo > highestCombo {
                highestCombo = currentCombo
            }
            onComboChanged?(currentCombo)
        }
    }
    var highestCombo: Int = 0
    var comboTimer: Timer?
    let comboTimeout: TimeInterval = GameConfig.comboTimeoutDuration
    
    // Add callback for UI updates
    var onComboChanged: ((Int) -> Void)?
    
    // Constructor
    init(initialPosition: CGPoint = .zero) {
        self.playerPosition = initialPosition
        
        // Initialize with fireball as the default spell
        currentSpell = FireballSpell()
        
        // Initialize maxHealth to match castleHealth
        maxHealth = maxCastleHealth
        
        // Initialize with only Fireball and Ice spells
        availableSpells = [
            FireballSpell(),
            IceSpell(),
        ]
    }
    
    // Callbacks for binding
    var onCastleHealthChanged: ((CGFloat) -> Void)?
    var onPlayerChargesChanged: ((Int) -> Void)?
    var onScoreChanged: ((Int) -> Void)?
    var onCoinsChanged: ((Int) -> Void)?
    var onMaxSpellChargesChanged: ((Int) -> Void)?
    var onSpellChanged: ((Spell) -> Void)?
    
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
        spellCharges = min(maxSpellCharges, spellCharges + 1)
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
        spellPowerMultiplier = GameConfig.defaultSpellPowerMultiplier  // Reset spell power
        spellCharges = maxSpellCharges
        currentCombo = 0
        highestCombo = 0
        comboTimer?.invalidate()
        comboTimer = nil
    }
    
    // Simplify spell usage to single wizard
    func useSpell(cost: Int, spellName: String? = nil) -> Bool {
        if let name = spellName {
            if let spell = availableSpells.first(where: { $0.name == name }), spell.isOneTimeUse {
                if let quantity = consumableSpells[name], quantity > 0 {
                    consumableSpells[name] = quantity - 1
                    return true
                }
                return false
            }
        }
        
        if spellCharges >= cost {
            spellCharges -= cost
            return true
        }
        return false
    }
    
    // Simplify to get current spell
    func getCurrentSpell() -> Spell {
        return currentSpell
    }
    
    // Add function to swap spells
    func cycleSpell() {
        let availableSpells = getAvailableSpells()
        guard availableSpells.count > 1,
              let currentIndex = availableSpells.firstIndex(where: { $0.name == currentSpell.name }) else { return }
        
        let nextIndex = (currentIndex + 1) % availableSpells.count
        currentSpell = availableSpells[nextIndex]
    }
    
    // Update setSpell function for shop purchases
    func setSpell(spell: Spell) {
        currentSpell = spell
    }
    
    func getCurrentSpellName() -> String {
        return currentSpell.name
    }
    
    // Add this new method
    func addSpell(_ spell: Spell) {
        // Check if we already have this type of spell
        if !availableSpells.contains(where: { $0.name == spell.name }) {
            availableSpells.append(spell)
        }
    }
    
    func getAvailableSpells() -> [Spell] {
        return availableSpells
    }
    
    func updatePlayerPosition(_ newPosition: CGPoint) {
        playerPosition = newPosition
    }
    
    func addConsumableSpell(_ spellName: String, quantity: Int = 1) {
        consumableSpells[spellName] = (consumableSpells[spellName] ?? 0) + quantity
    }
    
    func hasConsumableSpell(_ spellName: String) -> Bool {
        return (consumableSpells[spellName] ?? 0) > 0
    }
    
    func getConsumableSpellCount(_ spellName: String) -> Int {
        return consumableSpells[spellName] ?? 0
    }
    
    // Add new method for combo handling
    func incrementCombo() {
        // Reset existing timer if it exists
        comboTimer?.invalidate()
        
        // Increment combo
        currentCombo += 1
        
        // Start new timer
        comboTimer = Timer.scheduledTimer(withTimeInterval: comboTimeout, repeats: false) { [weak self] _ in
            self?.resetCombo()
        }
    }
    
    private func resetCombo() {
        currentCombo = 0
        comboTimer?.invalidate()
        comboTimer = nil
    }
    
    func cycleSpellBackwards() {
        let availableSpells = getAvailableSpells()
        guard availableSpells.count > 1,
              let currentIndex = availableSpells.firstIndex(where: { $0.name == currentSpell.name }) else { return }
        
        let nextIndex = (currentIndex - 1 + availableSpells.count) % availableSpells.count
        currentSpell = availableSpells[nextIndex]
    }
    
    func getInactiveSpell() -> Spell {
        let availableSpells = getAvailableSpells()
        guard availableSpells.count > 1,
              let currentIndex = availableSpells.firstIndex(where: { $0.name == currentSpell.name }) else {
            return currentSpell // Fallback to current spell if no alternatives
        }
        
        let nextIndex = (currentIndex + 1) % availableSpells.count
        return availableSpells[nextIndex]
    }
}
