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

class PlayerState {
    // Castle state
    var castleHealth: CGFloat = 100 {
        didSet {
            onCastleHealthChanged?(castleHealth)
        }
    }
    let maxCastleHealth: CGFloat = 100
    
    // Wizard state
    var spellCharges: Int = 5 {
        didSet {
            onPlayerChargesChanged?(spellCharges)
        }
    }
    var maxSpellCharges: Int = 5 {
        didSet {
            onMaxSpellChargesChanged?(maxSpellCharges)
        }
    }
    
    // Single spell property instead of primary/secondary
    var currentSpell: Spell {
        didSet {
            onSpellChanged?(currentSpell)
        }
    }
    
    // New properties for upgrades
    var maxHealth: CGFloat = 100 {
        didSet {
            // When maxHealth increases, increase current health proportionally
            let healthPercentage = castleHealth / oldValue
            castleHealth = maxHealth * healthPercentage
        }
    }
    
    var spellPowerMultiplier: CGFloat = 1.0
    
    // Add this property to track available spells
    private var availableSpells: [Spell] = []
    
    // Add playerPosition property
    var playerPosition: CGPoint = .zero
    
    var consumableSpells: [String: Int] = [:] // Tracks spell name and quantity
    
    // Add after the existing properties
    var spellAOEMultiplier: CGFloat = 1.0
    var spellSpeedMultiplier: CGFloat = 1.0
    var manaRegenRate: CGFloat = 1.0
    
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
    let comboTimeout: TimeInterval = 3.0 // Adjust this value to control combo duration
    
    // Add callback for UI updates
    var onComboChanged: ((Int) -> Void)?
    
    // Add property to track selected inventory spell
    var selectedInventorySpell: String?
    
    // Add after selectedInventorySpell property
    var temporarySpell: Spell?
    
    // Add this with other callbacks
    var onTemporarySpellChanged: ((Spell?) -> Void)?
    
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
        spellPowerMultiplier = 1.0  // Reset spell power
        spellCharges = maxSpellCharges
        currentCombo = 0
        highestCombo = 0
        comboTimer?.invalidate()
        comboTimer = nil
    }
    
    // Simplify spell usage to handle both cooldowns and mana
    func useSpell(cost: Int, spellName: String? = nil) -> Bool {
        if temporarySpell != nil {
            // If we have a temporary spell, always allow casting
            return true
        }
        
        if let name = spellName {
            // Handle one-time use spells
            if let quantity = consumableSpells[name], quantity > 0 {
                consumableSpells[name] = quantity - 1
                return true
            }
            return false
        }
        
        // Handle regular spells with mana cost
        if spellCharges >= cost {
            spellCharges -= cost
            return true
        }
        return false
    }
    
    // Update getCurrentSpell to NOT consume temporarySpell
    func getCurrentSpell() -> Spell {
        return currentSpell
    }
    
    // Add new method to get spell for casting (consumes temporarySpell)
    func getSpellForCasting() -> Spell {
        if let temp = temporarySpell {
            print("Using temporary spell: \(temp.name)")  // Debug log
            // Clear the temporary spell after getting it
            temporarySpell = nil
            // Notify UI that temporary spell is consumed
            onTemporarySpellChanged?(nil)
            return temp
        }
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
    
    // Add this new method to PlayerState
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
    
    // Add this method to get available spells
    func getAvailableSpells() -> [Spell] {
        return availableSpells
    }
    
    // Add method to update player position
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
    
    // Modify useInventorySpell to handle creation and UI update safely
    func useInventorySpell(_ spellName: String) -> Bool {
        if let count = consumableSpells[spellName], count > 0 {
            guard let spell = createSpellByName(spellName) else {
                print("Failed to create spell with name: \(spellName)")
                return false
            }
            temporarySpell = spell
            // Reduce count
            consumableSpells[spellName] = count - 1

            // Remove if depleted
            if count - 1 <= 0 {
                consumableSpells.removeValue(forKey: spellName)
            }

            // Notify UI that a temporary spell is set
            onTemporarySpellChanged?(spell)

            return true
        }
        return false
    }
    
    // Add this method to add spells to the inventory
    func addSpellToInventory(_ spell: Spell) {
        print("Adding spell to inventory: \(spell.name)")  // Debug log
        consumableSpells[spell.name] = (consumableSpells[spell.name] ?? 0) + 1
        print("New inventory count for \(spell.name): \(consumableSpells[spell.name] ?? 0)")  // Debug log
    }
    
    // Add this method to check if there's a temporary spell
    func hasTemporarySpell() -> Bool {
        return temporarySpell != nil
    }
    
    func createSpellByName(_ spellName: String) -> Spell? {
        switch spellName {
        case AC130Spell().name:
            return AC130Spell()
        case TacticalNukeSpell().name:
            return TacticalNukeSpell()
        case DivineWrathSpell().name:
            return DivineWrathSpell()
        case ArcaneStormSpell().name:
            return ArcaneStormSpell()
        case MeteorShowerSpell().name:
            return MeteorShowerSpell()
        case PredatorMissileSpell().name:
            return PredatorMissileSpell()
        case CrowSwarmSpell().name:
            return CrowSwarmSpell()
        case SwarmQueenSpell().name:
            return SwarmQueenSpell()
        case NanoSwarmSpell().name:
            return NanoSwarmSpell()
        case SteampunkTimeBombSpell().name:
            return SteampunkTimeBombSpell()
        case ShadowPuppetSpell().name:
            return ShadowPuppetSpell()
        case TemporalDistortionSpell().name:
            return TemporalDistortionSpell()
        case MysticBarrierSpell().name:
            return MysticBarrierSpell()
        case BlizzardSpell().name:
            return BlizzardSpell()
        case InfernoSpell().name:
            return InfernoSpell()
        case FireballSpell().name:
            return FireballSpell()
        case IceSpell().name:
            return IceSpell()
        case LightningSpell().name:
            return LightningSpell()
        // Add any additional spells here
        default:
            print("Unknown spell name: \(spellName)")
            return nil
        }
    }
} 
