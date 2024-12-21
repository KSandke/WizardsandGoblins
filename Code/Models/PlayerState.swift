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
    
    // New properties for specials
    private var specialSlots: [Special?] = [nil, nil, nil, nil]
    private var selectedSpecialIndex: Int = 0
    var currentSpecial: Special? {
        get { specialSlots[selectedSpecialIndex] }
        set {
            specialSlots[selectedSpecialIndex] = newValue
            onSpecialChanged?(newValue, selectedSpecialIndex)
        }
    }
    
    // Add callback for special changes
    var onSpecialChanged: ((Special?, Int) -> Void)?
    
    // Add this property
    var currentSpecialIndex: Int {
        return selectedSpecialIndex
    }
    
    // Add the new callback
    var onSpecialSlotsChanged: ((Int) -> Void)?
    
    // Infinite mana properties
    private var infiniteManaActive = false
    private var infiniteManaTimer: Timer?

    // Callbacks
    var onInfiniteManaStatusChanged: ((Bool) -> Void)?
    var onHealthRestored: ((CGFloat) -> Void)?
    
    // Constructor
    init(initialPosition: CGPoint = .zero) {
        self.playerPosition = initialPosition
        
        // Initialize with Lightning as the default spell
        currentSpell = FireballSpell()
        
        // Initialize maxHealth to match castleHealth
        maxHealth = maxCastleHealth
        
        // Initialize with Lightning and Ice spells
        availableSpells = [
            FireballSpell(),

        ]
        
        specialSlots = [nil, nil, nil, nil]
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
        
        // Reset infinite mana
        deactivateInfiniteMana()
        
        // Additional resets if needed
    }
    
    // Simplify spell usage to single wizard
    func useSpell(cost: Int) -> Bool {
        if infiniteManaActive {
            // Spell cost is waived during infinite mana
            return true
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
            // Only add if we haven't hit the limit
            if availableSpells.count < GameConfig.maxSpellSlots {
                availableSpells.append(spell)
                // Trigger update of spell icons by notifying of current spell
                onSpellChanged?(currentSpell)
            }
        }
    }
    
    func getAvailableSpells() -> [Spell] {
        return availableSpells
    }
    
    func updatePlayerPosition(_ newPosition: CGPoint) {
        playerPosition = newPosition
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
    
    // Special management functions
    func getCurrentSpecial() -> Special? {
        return specialSlots[selectedSpecialIndex]
    }
    
    func cycleSpecialSlot() {
        selectedSpecialIndex = (selectedSpecialIndex + 1) % specialSlots.count
        onSpecialChanged?(currentSpecial, selectedSpecialIndex)
    }
    
    func addSpecial(_ special: Special) {
        if let emptyIndex = specialSlots.firstIndex(where: { $0 == nil }) {
            // Found an empty slot, add the special there
            specialSlots[emptyIndex] = special
            onSpecialChanged?(special, emptyIndex)
            onSpecialSlotsChanged?(emptyIndex)
        } else {
            // replace this with the new special selection screen
            specialSlots[selectedSpecialIndex] = special
            onSpecialChanged?(special, selectedSpecialIndex)
            onSpecialSlotsChanged?(selectedSpecialIndex)
        }
    }
    
    func replaceSpecial(_ special: Special, at index: Int) {
        guard index >= 0 && index < specialSlots.count else { return }
        specialSlots[index] = special
        onSpecialChanged?(special, index)
        onSpecialSlotsChanged?(index)
    }
    
    func removeSpecial(at index: Int) {
        guard index >= 0 && index < specialSlots.count else { return }
        specialSlots[index] = nil
        onSpecialChanged?(nil, index)
        onSpecialSlotsChanged?(index)
    }
    
    func getSpecialSlots() -> [Special?] {
        return specialSlots
    }
    
    func selectSpecialSlot(_ index: Int) {
        guard index >= 0 && index < specialSlots.count else { return }
        selectedSpecialIndex = index
        onSpecialChanged?(currentSpecial, selectedSpecialIndex)
    }
    
    // Add new method to check if player owns a spell
    func hasSpell(named spellName: String) -> Bool {
        return availableSpells.contains { $0.name == spellName }
    }
    
    func replaceSpell(_ newSpell: Spell, at index: Int) {
        guard index >= 0 && index < availableSpells.count else { return }
        
        // If replacing current spell, update currentSpell
        if availableSpells[index].name == currentSpell.name {
            currentSpell = newSpell
        }
        
        // Replace the spell at the specified index
        availableSpells[index] = newSpell
        
        // Notify listeners if needed
        onSpellChanged?(currentSpell)
    }
    
    // Add these new functions
    func getNextSpell() -> Spell {
        let availableSpells = getAvailableSpells()
        guard availableSpells.count > 1,
              let currentIndex = availableSpells.firstIndex(where: { $0.name == currentSpell.name }) else {
            return currentSpell
        }
        
        let nextIndex = (currentIndex + 1) % availableSpells.count
        return availableSpells[nextIndex]
    }
    
    func getPreviousSpell() -> Spell {
        let availableSpells = getAvailableSpells()
        guard availableSpells.count > 1,
              let currentIndex = availableSpells.firstIndex(where: { $0.name == currentSpell.name }) else {
            return currentSpell
        }
        
        let previousIndex = (currentIndex - 1 + availableSpells.count) % availableSpells.count
        return availableSpells[previousIndex]
    }

    // Add methods to activate and deactivate infinite mana
    func activateInfiniteMana(duration: TimeInterval) {
        // Play infinite mana activation sound
        SoundManager.shared.playSound("infinite_mana_effect")
        infiniteManaActive = true
        onInfiniteManaStatusChanged?(true)
        infiniteManaTimer?.invalidate()
        infiniteManaTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
            self?.deactivateInfiniteMana()
        }
    }

    private func deactivateInfiniteMana() {
        infiniteManaActive = false
        onInfiniteManaStatusChanged?(false)
        infiniteManaTimer?.invalidate()
        infiniteManaTimer = nil
    }

    func isInfiniteManaActive() -> Bool {
        return infiniteManaActive
    }
    
    func restoreHealth(amount: CGFloat) {
        castleHealth = min(maxCastleHealth, castleHealth + amount)
    }
}
