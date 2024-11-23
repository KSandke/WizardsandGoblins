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
    
    // Replace individual spell properties with primary/secondary spells
    var primarySpell: Spell {
        didSet {
            // You might want to add notification handling here
        }
    }
    var secondarySpell: Spell {
        didSet {
            // You might want to add notification handling here
        }
    }
    private var isUsingPrimarySpell: Bool = true
    
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
    
    // Constructor
    init(initialPosition: CGPoint = .zero) {
        self.playerPosition = initialPosition
        
        // Initialize primary spell (previously spell1)
        primarySpell = Spell(
            name: "spell1",
            aoeRadius: 50,
            duration: 1.0,
            damage: 25,
            effect: DefaultEffect()  // Use DefaultEffect here
        )

        // Initialize secondary spell (previously IceSpell)
        secondarySpell = Spell(
            name: "IceSpell",
            aoeRadius: 50,
            duration: 1.0,
            damage: 20,
            effect: FrostEffect()  // Use FrostEffect here instead of closure
        )
        
        // Initialize maxHealth to match castleHealth
        maxHealth = maxCastleHealth
        
        // Add initial spells to available spells
        availableSpells = [primarySpell, secondarySpell, LightningSpell(), PoisonCloudSpell(), AC130Spell(), PredatorMissileSpell(), DriveBySpell(), DroneSwarmSpell(), SwarmQueenSpell(), HologramTrapSpell(), ShadowPuppetSpell(), TacticalNukeSpell(), CrucifixionSpell(), RiftWalkerSpell(), NanoSwarmSpell(), IronMaidenSpell(), CyberneticOverloadSpell(), SteampunkTimeBombSpell(), TemporalDistortionSpell(), QuantumCollapseSpell(), EarthShatterSpell(), MysticBarrierSpell(), DivineWrathSpell(), NecromancersGripSpell(), ArcaneStormSpell(), MeteorShowerSpell(), BlizzardSpell(), InfernoSpell()]
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

    // Replace getSpell function
    func getSpell(isPlayerOne: Bool) -> Spell {
        return isUsingPrimarySpell ? primarySpell : secondarySpell
    }
    
    // Add function to swap spells
    func swapSpells(isPlayerOne: Bool) {
        isUsingPrimarySpell.toggle()
    }
    
    // Update setSpell function for shop purchases
    func setSpell(isPrimary: Bool, spell: Spell) {
        if isPrimary {
            primarySpell = spell
        } else {
            secondarySpell = spell
        }
    }
    
    // Add this new method to PlayerState
    func getCurrentSpellName() -> String {
        return isUsingPrimarySpell ? primarySpell.name : secondarySpell.name
    }
    
    // Add this new method
    func addSpell(_ spell: Spell) {
        // Check if we already have this type of spell
        if !availableSpells.contains(where: { $0.name == spell.name }) {
            availableSpells.append(spell)
            // If this is our first or second spell, set it as primary/secondary
            if availableSpells.count == 1 {
                primarySpell = spell
            } else if availableSpells.count == 2 {
                secondarySpell = spell
            }
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
} 
