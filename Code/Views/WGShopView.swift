import SpriteKit
import Foundation


struct ShopItem {
    let name: String
    let description: String
    var basePrice: Int
    let icon: String  // Name of image asset
    let effect: (PlayerState, @escaping (String) -> Void) -> Void
    let rarity: ItemRarity?  // Add optional rarity property
    let maxLevel: Int  // Add maximum level property
    
    // Add current price tracking
    private static var purchaseCounts: [String: Int] = [:]
    
    var currentPrice: Int {
        let purchases = ShopItem.purchaseCounts[name] ?? 0
        return basePrice + (purchases * basePrice)
    }
    
    var level: Int {
        return (ShopItem.purchaseCounts[name] ?? 0) + 1
    }
    
    var isMaxLevel: Bool {  // Add helper property
        return level > maxLevel
    }
    
    // Predefined shop items
    static let permanentUpgrades: [ShopItem] = [
        ShopItem(
            name: "Max Spell Charges +1",
            description: "Increase spell charges",
            basePrice: 10,
            icon: "SpellCharges",
            effect: { state, showMessage in
                state.maxSpellCharges += 1
                state.spellCharges += 1
            },
            maxLevel: 3  // Cap at 3 additional charges
        ),
        ShopItem(
            name: "Spell AOE +10%",
            description: "Increase spell area",
            basePrice: 8,
            icon: "aoe_upgrade",
            effect: { state, showMessage in
                state.spellAOEMultiplier *= 1.1
            },
            maxLevel: 5  // Cap at 50% total increase
        ),
        ShopItem(
            name: "Spell Speed +15%",
            description: "Cast spells faster",
            basePrice: 12,
            icon: "speed_upgrade",
            effect: { state, showMessage in
                state.spellSpeedMultiplier *= 1.15
            },
            maxLevel: 5  // Cap at 75% total increase
        ),
        ShopItem(
            name: "Mana Regen +20%",
            description: "Regenerate mana faster",
            basePrice: 15,
            icon: "regen_upgrade",
            effect: { state, showMessage in
                state.manaRegenRate *= 1.2
            },
            maxLevel: 5  // Cap at 100% total increase
        ),
        ShopItem(
            name: "Spell Power +10%",
            description: "Increase spell damage",
            basePrice: 10,
            icon: "power_upgrade",
            effect: { state, showMessage in
                state.spellPowerMultiplier *= 1.1
            },
            maxLevel: 10  // Cap at 100% total increase
        )
    ]
    
    static func recordPurchase(of itemName: String) {
        purchaseCounts[itemName] = (purchaseCounts[itemName] ?? 0) + 1
    }
    
    // Update initializer to include rarity
    init(name: String, description: String, basePrice: Int, icon: String, effect: @escaping (PlayerState, @escaping (String) -> Void) -> Void, rarity: ItemRarity? = nil, maxLevel: Int = 1) {
        self.name = name
        self.description = description
        self.basePrice = basePrice
        self.icon = icon
        self.effect = effect
        self.rarity = rarity
        self.maxLevel = maxLevel
    }
}

class ShopView: SKNode {
    private let playerState: PlayerState
    private let playerView: PlayerView
    private var onClose: () -> Void
    
    // UI Elements
    private let background: SKSpriteNode
    private let statsLabel: SKLabelNode
    private var itemButtons: [SKNode] = []
    private let closeButton: SKLabelNode
    
    // Add new properties
    private let waveInfoLabel: SKLabelNode
    private let goblinTypeLabels: [SKLabelNode]
    
    // Add new property to track current available upgrades
    private var availableUpgrades: [ShopItem] = []
    
    // Add property to track when special was last refreshed
    private static var lastSpecialRefreshWave = 0
    private static var currentSpecialOffer: Special?
    
    // Add property to track the special slot selector
    private var slotSelector: SKNode?
    
    // Add this property to store all available specials
    private let allSpecials: [Special] = [
//        Special(name: "FireStorm", aoeRadius: 100, aoeColor: .red, duration: 0.5, damage: 20, effect: nil, cooldown: 10, targetingMode: .global, rarity: .common),
//        Special(name: "IceBlast", aoeRadius: 80, aoeColor: .cyan, duration: 0.5, damage: 30, effect: nil, cooldown: 8, targetingMode: .random, rarity: .uncommon),
        Special(name: "LightningStrike", aoeRadius: 60, aoeColor: .yellow, duration: 0.5, damage: 45, effect: nil, cooldown: 6, targetingMode: .maxHealth, rarity: .rare),
        Special(name: "VoidBlast", aoeRadius: 120, aoeColor: .purple, duration: 0.5, damage: 60, effect: nil, cooldown: 5, targetingMode: .global, rarity: .epic),
        Special(name: "DragonBreath", aoeRadius: 150, aoeColor: .orange, duration: 0.5, damage: 100, effect: nil, cooldown: 4, targetingMode: .global, rarity: .legendary),
        BlizzardSpecial(),
        //HologramTrapSpecial(),
        InfernoSpecial(),
        MeteorShowerSpecial(),
        DivineHealingSpecial()
    ]
    
    // Add new properties
    private static var lastSpellRefreshWave = 0
    private static var currentSpellOffer: Spell?
    private var spellSelector: SKNode?
    
    // Add all available spells
    private let allSpells: [Spell] = [
        FireballSpell(),
        IceSpell(),
        LightningSpell(),
        BleedDartSpell(),
        PoisonCloudSpell()
    ]
    
    // Add new property for reset label
    private let resetTimerLabel: SKLabelNode
    
    init(size: CGSize, playerState: PlayerState, playerView: PlayerView, config: WaveConfig, currentWave: Int, onClose: @escaping () -> Void) {
        // Initialize the reset timer label
        self.resetTimerLabel = SKLabelNode(fontNamed: "HelveticaNeue")
        
        // Initialize all properties before super.init()
        self.playerState = playerState
        self.playerView = playerView
        self.onClose = onClose
        self.background = SKSpriteNode(color: .black.withAlphaComponent(0.8), size: size)
        self.statsLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        self.closeButton = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        self.waveInfoLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        self.goblinTypeLabels = []
        
        // Call super.init()
        super.init()
        
        // Select random upgrades BEFORE setting up UI
        selectRandomUpgrades(currentWave)  // Pass currentWave to the method
        
        // Setup UI after initialization
        setupUI(size: size)
        setupWaveInfo(config, size: size)
        updateStats()
        
        // Configure close button
        closeButton.text = "Close Shop"
        closeButton.name = "closeShopButton"
        closeButton.fontSize = 24
        closeButton.fontColor = .white
        
        // Add reset timer label after other UI setup
        setupResetTimerLabel(currentWave: currentWave)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(size: CGSize) {
        // Add background
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(background)
        
        // Constants for vertical spacing
        let topPadding: CGFloat = 90
        
        // Create coin display at the top
        statsLabel.fontSize = 32
        statsLabel.fontColor = .yellow
        statsLabel.position = CGPoint(x: size.width/2 + 25, y: size.height - topPadding)
        addChild(statsLabel)
        
        // Add coin icon
        let coinIcon = SKSpriteNode(imageNamed: "coin")
        coinIcon.size = CGSize(width: 40, height: 40)
        coinIcon.position = CGPoint(x: statsLabel.position.x - 100, y: statsLabel.position.y)
        addChild(coinIcon)
        
        // Create shop items section
        let buttonWidth: CGFloat = min(180, size.width / 2.5)
        let buttonHeight: CGFloat = 120
        let padding: CGFloat = 20
        
        // Calculate grid layout
        let gridWidth = buttonWidth * 2 + padding
        let startX = (size.width - gridWidth) / 2 + buttonWidth / 2
        let startY = size.height * 0.5  // Adjust this value to position the grid vertically
        
        // Create array of all available items
        var allItems: [ShopItem] = []
        
        // Add permanent upgrades (first two slots)
        let permanentUpgrades = availableUpgrades.filter { $0.rarity == nil }
        allItems.append(contentsOf: permanentUpgrades.prefix(2))
        
        // Add special upgrade if available (third slot)
        if let specialUpgrade = availableUpgrades.first(where: { $0.rarity != nil }) {
            allItems.append(specialUpgrade)
        }
        
        // Add spell upgrade if available (fourth slot)
        if let spellItem = createSpellShopItem() {
            allItems.append(spellItem)
        }
        
        // Create 2x2 grid
        for (index, item) in allItems.enumerated() {
            let row = index / 2
            let col = index % 2
            
            let x = startX + CGFloat(col) * (buttonWidth + padding)
            let y = startY - CGFloat(row) * (buttonHeight + padding)
            
            let button = createItemButton(item: item, size: CGSize(width: buttonWidth, height: buttonHeight))
            button.position = CGPoint(x: x, y: y)
            addChild(button)
            itemButtons.append(button)
        }
        
        // Update close button position - move it further down
        closeButton.position = CGPoint(x: size.width/2, y: startY - (buttonHeight * 2.0) - padding * 2.0 - 10)
        addChild(closeButton)
    }
    
    private func createItemButton(item: ShopItem, size: CGSize) -> SKNode {
        let container = SKNode()
        container.name = "itemButton_\(item.name)"
        
        let background = SKShapeNode(rectOf: size, cornerRadius: 10)
        
        // Check if item is already purchased (for specials/spells)
        let isAlreadyPurchased = isItemPurchased(item)
        
        // For permanent upgrades, check max level. For others, check if already purchased
        if (item.rarity == nil && item.isMaxLevel) {
            background.fillColor = .gray.withAlphaComponent(0.1)
            background.strokeColor = .gray
        } else if isAlreadyPurchased {
            background.fillColor = .gray.withAlphaComponent(0.1)
            background.strokeColor = .gray
        } else if let rarity = item.rarity {
            background.fillColor = rarity.color.withAlphaComponent(0.3)
            background.strokeColor = rarity.color
        } else {
            background.fillColor = .gray.withAlphaComponent(0.3)
            background.strokeColor = .white
        }
        container.addChild(background)
        
        let padding: CGFloat = 10  // Padding from button edges
        let maxWidth = size.width - (padding * 2)  // Maximum width for text
        
        // Item name - potentially wrap text if too long
        let nameLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        nameLabel.text = item.name
        nameLabel.fontSize = 14  // Reduced font size
        nameLabel.position = CGPoint(x: 0, y: 30)
        nameLabel.horizontalAlignmentMode = .center
        nameLabel.verticalAlignmentMode = .center
        // Adjust text if too wide
        while nameLabel.frame.width > maxWidth && nameLabel.fontSize > 10 {
            nameLabel.fontSize -= 1
        }
        container.addChild(nameLabel)
        
        // Level display
        let levelLabel = SKLabelNode(fontNamed: "HelveticaNeue")
        levelLabel.text = "Level \(item.level)"
        levelLabel.fontSize = 12
        levelLabel.fontColor = .green
        levelLabel.position = CGPoint(x: 0, y: 10)
        levelLabel.horizontalAlignmentMode = .center
        levelLabel.verticalAlignmentMode = .center
        container.addChild(levelLabel)
        
        // Description - wrap text if needed
        let descLabel = SKLabelNode(fontNamed: "HelveticaNeue")
        descLabel.text = item.description
        descLabel.fontSize = 11  // Smaller font for description
        descLabel.position = CGPoint(x: 0, y: -10)
        descLabel.horizontalAlignmentMode = .center
        descLabel.verticalAlignmentMode = .center
        // Adjust text if too wide
        while descLabel.frame.width > maxWidth && descLabel.fontSize > 8 {
            descLabel.fontSize -= 1
        }
        container.addChild(descLabel)
        
        // Price label logic
        let priceLabel = SKLabelNode(fontNamed: "HelveticaNeue")
        if item.rarity == nil && item.isMaxLevel {
            priceLabel.text = "Max Level"
            priceLabel.fontColor = .gray
        } else if isAlreadyPurchased {
            priceLabel.text = "Already Purchased"
            priceLabel.fontColor = .gray
        } else {
            priceLabel.text = "\(item.currentPrice) coins"
            priceLabel.fontColor = .yellow
        }
        priceLabel.fontSize = 12
        priceLabel.position = CGPoint(x: 0, y: -30)
        priceLabel.horizontalAlignmentMode = .center
        priceLabel.verticalAlignmentMode = .center
        container.addChild(priceLabel)
        
        // Add rarity label if applicable
        if let rarity = item.rarity {
            let rarityLabel = SKLabelNode(fontNamed: "HelveticaNeue")
            rarityLabel.text = rarity.name
            rarityLabel.fontSize = 10
            rarityLabel.fontColor = rarity.color
            rarityLabel.position = CGPoint(x: 0, y: -45)
            rarityLabel.horizontalAlignmentMode = .center
            rarityLabel.verticalAlignmentMode = .center
            container.addChild(rarityLabel)
        }
        
        return container
    }
    
    private func isItemPurchased(_ item: ShopItem) -> Bool {
        // For specials, check if it's in the player's special slots
        if let special = ShopView.currentSpecialOffer, special.name == item.name {
            let currentSpecials = playerState.getSpecialSlots()
            return currentSpecials.contains { $0?.name == special.name }
        }
        
        // For spells, check if it's in the player's spell inventory
        if let spell = ShopView.currentSpellOffer,
           item.name == spell.name {
            return playerState.hasSpell(named: spell.name)
        }
        
        return false
    }
    
    private func updateStats() {
        // Updated to only show coins prominently
        statsLabel.text = "\(playerState.coins) Coins"
        
        // Add score in smaller text below if desired
        let scoreLabel = SKLabelNode(fontNamed: "HelveticaNeue")
        scoreLabel.text = "Score: \(playerState.score)"
        scoreLabel.fontSize = 20
        scoreLabel.position = CGPoint(x: statsLabel.position.x, y: statsLabel.position.y - 30)
        scoreLabel.fontColor = .white
        addChild(scoreLabel)
    }
    
    func handleTap(at point: CGPoint) {
        let nodes = self.nodes(at: point)
        
        // Handle special selector taps if it's showing
        if slotSelector != nil {
            for node in nodes {
                if node.name == "specialSelectorCancel" {
                    slotSelector?.removeFromParent()
                    slotSelector = nil
                    return
                }
                
                if let buttonName = node.name,
                   buttonName.starts(with: "specialSlotButton_"),
                   let index = Int(buttonName.dropFirst("specialSlotButton_".count)),
                   let item = availableUpgrades.first(where: { $0.rarity != nil }) {
                    completePurchase(item, replacingSlot: index)
                    slotSelector?.removeFromParent()
                    slotSelector = nil
                    return
                }
            }
            return  // Early return if selector is open
        }
        
        // Handle spell selector taps if it's showing
        if spellSelector != nil {
            for node in nodes {
                if node.name == "spellSelectorCancel" {
                    spellSelector?.removeFromParent()
                    spellSelector = nil
                    return
                }
                
                if let buttonName = node.name,
                   buttonName.starts(with: "spellSlotButton_"),
                   let index = Int(buttonName.dropFirst("spellSlotButton_".count)),
                   let newSpell = ShopView.currentSpellOffer {
                    let currentSpells = playerState.getAvailableSpells()
                    if index < currentSpells.count {
                        playerState.replaceSpell(newSpell, at: index)
                        spellSelector?.removeFromParent()
                        spellSelector = nil
                        refreshItemButtons()
                    }
                    return
                }
            }
            return  // Early return if selector is open
        }
        
        // Only handle shop buttons if no selector is open
        for node in nodes {
            if node.name == "closeShopButton" {
                onClose()
                return
            }
            
            if let buttonName = node.name,
               buttonName.starts(with: "itemButton_"),
               let item = availableUpgrades.first(where: { "itemButton_\($0.name)" == buttonName }) {
                purchaseItem(item)
                return
            }
        }
    }
    
    private func purchaseItem(_ item: ShopItem) {
        // For permanent upgrades, check max level
        if item.rarity == nil && item.isMaxLevel {
            showMessage("Maximum level reached!")
            return
        }
        
        // For specials/spells, check if already purchased
        if isItemPurchased(item) {
            showMessage("Already purchased!")
            return
        }
        
        // Rest of the existing purchase logic
        guard playerState.coins >= item.currentPrice else {
            showMessage("Not enough coins!")
            return
        }
        
        // If this is a special and all slots are filled, show slot selector
        if item.rarity != nil {
            let specialSlots = playerState.getSpecialSlots()
            if !specialSlots.contains(where: { $0 == nil }) {
                if let special = allSpecials.first(where: { $0.name == item.name }) {
                    showSpecialSlotSelector(for: special)
                    return
                }
            }
        }
        
        // If this is a spell and all slots are filled, show spell selector
        if let spell = ShopView.currentSpellOffer,
           item.name == spell.name {
            if playerState.getAvailableSpells().count >= GameConfig.maxSpellSlots {
                showSpellSlotSelector(for: spell)
                return
            }
        }
        
        // Normal purchase flow for non-specials or when empty slots are available
        completePurchase(item)
    }
    
    private func completePurchase(_ item: ShopItem, replacingSlot: Int? = nil) {
        playerState.coins -= item.currentPrice
        
        // If this is a special and we have a slot to replace
        if let special = ShopView.currentSpecialOffer,
           item.name == special.name,
           let slotIndex = replacingSlot {
            // Replace the special in the specific slot
            playerState.replaceSpecial(special, at: slotIndex)
            playerView.updateSpecialButton(at: slotIndex)
        } 
        // If this is a spell
        else if let spell = ShopView.currentSpellOffer,
                  item.name == spell.name {
            if let slotIndex = replacingSlot {
                // Replace existing spell
                playerState.replaceSpell(spell, at: slotIndex)
            } else {
                // Add new spell
                playerState.addSpell(spell)
            }
        }
        // Normal purchase flow for other items
        else {
            item.effect(playerState) { [weak self] message in
                self?.showMessage(message)
            }
        }
        
        ShopItem.recordPurchase(of: item.name)
        showMessage("\(item.name) acquired!")
        refreshItemButtons()
        updateStats()
    }
    
    private func refreshItemButtons() {
        itemButtons.forEach { $0.removeFromParent() }
        itemButtons.removeAll()
        
        let buttonWidth: CGFloat = min(180, background.frame.width / 2.5)
        let buttonHeight: CGFloat = 120
        let padding: CGFloat = 20
        
        // Calculate grid layout
        let gridWidth = buttonWidth * 2 + padding
        let startX = (background.frame.width - gridWidth) / 2 + buttonWidth / 2
        let startY = background.frame.height * 0.5
        
        // Create array of all available items
        var allItems: [ShopItem] = []
        
        // Add permanent upgrades (first two slots)
        let permanentUpgrades = availableUpgrades.filter { $0.rarity == nil }
        allItems.append(contentsOf: permanentUpgrades.prefix(2))
        
        // Add special upgrade if available (third slot)
        if let specialUpgrade = availableUpgrades.first(where: { $0.rarity != nil }) {
            allItems.append(specialUpgrade)
        }
        
        // Add spell upgrade if available (fourth slot)
        if let spellItem = createSpellShopItem() {
            allItems.append(spellItem)
        }
        
        // Create 2x2 grid
        for (index, item) in allItems.enumerated() {
            let row = index / 2
            let col = index % 2
            
            let x = startX + CGFloat(col) * (buttonWidth + padding)
            let y = startY - CGFloat(row) * (buttonHeight + padding)
            
            let button = createItemButton(item: item, size: CGSize(width: buttonWidth, height: buttonHeight))
            button.position = CGPoint(x: x, y: y)
            addChild(button)
            itemButtons.append(button)
        }
    }
    
    private func showMessage(_ text: String) {
        // Remove any existing messages first
        self.enumerateChildNodes(withName: "messageLabel") { node, _ in
            node.removeFromParent()
        }
        
        let message = SKLabelNode(fontNamed: "HelveticaNeue")
        message.name = "messageLabel"  // Add name for removal
        message.text = text
        message.fontSize = 20
        message.fontColor = .white
        message.alpha = 0
        
        // Position below coins but above shop items
        // Assuming statsLabel is your coins display
        message.position = CGPoint(
            x: background.frame.width/2,
            y: statsLabel.position.y - 60
              // Adjust this value as needed
        )
        addChild(message)
        
        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
        let wait = SKAction.wait(forDuration: 1.5)
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let remove = SKAction.removeFromParent()
        
        message.run(SKAction.sequence([fadeIn, wait, fadeOut, remove]))
    }
    
    private func setupWaveInfo(_ config: WaveConfig, size: CGSize) {
        // Position wave info between coins and shop items
        let waveInfoY = size.height * 0.82  // Position in upper third of screen
        
        waveInfoLabel.text = "Next Wave Composition:"
        waveInfoLabel.fontSize = 24
        waveInfoLabel.fontColor = .white
        waveInfoLabel.position = CGPoint(x: size.width/2, y: waveInfoY)
        addChild(waveInfoLabel)
        
        // Calculate total goblins
        let totalGoblins = config.maxGoblins
        
        // Create labels for each goblin type
        var yOffset: CGFloat = waveInfoY - 30
        let minY = size.height * 0.6  // Stop before reaching shop items
        
        for (type, probability) in config.goblinTypeProbabilities {
            if yOffset < minY { break }
            
            let count = Int(round(Double(totalGoblins) * probability / 100.0))
            let typeLabel = SKLabelNode(fontNamed: "HelveticaNeue")
            typeLabel.fontSize = 18
            typeLabel.fontColor = .white
            typeLabel.text = "\(goblinTypeName(type)): \(count)"
            typeLabel.position = CGPoint(x: size.width/2, y: yOffset)
            addChild(typeLabel)
            yOffset -= 25
        }
        
        // Add total count if there's room
        if yOffset >= minY {
            let totalLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
            totalLabel.fontSize = 20
            totalLabel.fontColor = .yellow
            totalLabel.text = "Total Goblins: \(totalGoblins)"
            totalLabel.position = CGPoint(x: size.width/2, y: yOffset - 10)
            addChild(totalLabel)
        }
    }
    
    private func goblinTypeName(_ type: Goblin.GoblinType) -> String {
        switch type {
        case .normal:
            return "Normal Goblins"
        case .large:
            return "Large Goblins"
        case .small:
            return "Small Goblins"
        case .ranged:
            return "Ranged Goblins"
        }
    }
    
    private func selectRandomUpgrades(_ currentWave: Int) {
        // Check if we need to refresh the special (every 2 waves)
        if currentWave % 2 == 1 || ShopView.currentSpecialOffer == nil {
            let special = generateRandomSpecial()
            // Only offer the special if the player doesn't already have it
            let currentSpecials = playerState.getSpecialSlots()
            let currentSpecialNames = Set(currentSpecials.compactMap { $0?.name })
            
            if !currentSpecialNames.contains(special.name) {
                ShopView.currentSpecialOffer = special
            } else {
                ShopView.currentSpecialOffer = nil
            }
            ShopView.lastSpecialRefreshWave = currentWave
        }
        
        // Check if we need to refresh the spell (every 2 waves)
        if currentWave % 2 == 1 || ShopView.currentSpellOffer == nil {
            let spell = generateRandomSpell()
            ShopView.currentSpellOffer = spell
            ShopView.lastSpellRefreshWave = currentWave
        }
        
        // Create array of all available items
        var upgrades = [ShopItem]()
        
        // Add permanent upgrades (first two slots)
        let regularUpgrades = Array(ShopItem.permanentUpgrades.shuffled().prefix(2))
        upgrades.append(contentsOf: regularUpgrades)
        
        // Add special upgrade if available (third slot)
        if let special = ShopView.currentSpecialOffer {
            upgrades.append(ShopItem(
                name: special.name,
                description: "Special Attack",
                basePrice: calculateSpecialPrice(special),
                icon: special.name,
                effect: { state, showMessage in
                    state.addSpecial(special)
                    showMessage("Special ability acquired!")
                },
                rarity: special.rarity
            ))
        }
        
        // Add spell upgrade if available (fourth slot)
        if let spell = ShopView.currentSpellOffer {
            upgrades.append(ShopItem(
                name: spell.name,
                description: "New Spell",
                basePrice: calculateSpellPrice(spell),
                icon: spell.name,
                effect: { [weak self] state, showMessage in
                    if state.getAvailableSpells().count >= GameConfig.maxSpellSlots {
                        self?.showSpellSlotSelector(for: spell)
                    } else {
                        state.addSpell(spell)
                        showMessage("New spell acquired!")
                    }
                },
                rarity: spell.rarity
            ))
        }
        
        availableUpgrades = upgrades
    }
    
    private func calculateSpecialPrice(_ special: Special) -> Int {
        // Debug: All specials cost 0
        return 0
        
        // Original code commented out for reference
        /*
        let basePrice = 15
        let rarityMultiplier: Int
        
        switch special.rarity {
        case .common: rarityMultiplier = 1
        case .uncommon: rarityMultiplier = 2
        case .rare: rarityMultiplier = 4
        case .epic: rarityMultiplier = 8
        case .legendary: rarityMultiplier = 15
        }
        
        return basePrice * rarityMultiplier
        */
    }
    
    private func generateRandomSpecial() -> Special {
        // Get current specials from player state
        let currentSpecials = playerState.getSpecialSlots()
        let currentSpecialNames = Set(currentSpecials.compactMap { $0?.name })
        
        // Roll for rarity
        let roll = Double.random(in: 0...1)
        var selectedRarity: ItemRarity = .common
        
        var cumulativeChance = 0.0
        for rarity in ItemRarity.allCases {
            cumulativeChance += rarity.dropChance
            if roll <= cumulativeChance {
                selectedRarity = rarity
                break
            }
        }
        
        // Filter out specials the player already has and match the selected rarity
        let availableSpecials = allSpecials.filter { special in
            !currentSpecialNames.contains(special.name) && special.rarity == selectedRarity
        }
        
        // If no specials available for selected rarity, try other rarities
        if availableSpecials.isEmpty {
            let anyAvailableSpecials = allSpecials.filter { special in
                !currentSpecialNames.contains(special.name)
            }
            
            // If no specials available at all, return nil and handle in selectRandomUpgrades
            if anyAvailableSpecials.isEmpty {
                return allSpecials[0] // Fallback to first special if somehow nothing is available
            }
            
            return anyAvailableSpecials.randomElement() ?? allSpecials[0]
        }
        
        return availableSpecials.randomElement() ?? allSpecials[0]
    }
    
    private func generateRandomSpell() -> Spell? {
        let availableSpells = allSpells.filter { spell in
            !playerState.hasSpell(named: spell.name)
        }
        
        return availableSpells.randomElement()
    }
    
    private func createSpellShopItem() -> ShopItem? {
        guard let spell = ShopView.currentSpellOffer else {
            return nil
        }

        return ShopItem(
            name: spell.name,
            description: "New Spell",
            basePrice: calculateSpellPrice(spell),
            icon: spell.name,
            effect: { [weak self] state, showMessage in
                if state.getAvailableSpells().count >= GameConfig.maxSpellSlots {
                    self?.showSpellSlotSelector(for: spell)
                } else {
                    state.addSpell(spell)
                    showMessage("New spell acquired!")
                }
            },
            rarity: spell.rarity
        )
    }
    
    private func calculateSpellPrice(_ spell: Spell) -> Int {
        // Debug: All spells cost 0
        return 0
        
        // Uncomment for real pricing
        /*
        let basePrice = 20
        let rarityMultiplier: Int
        
        switch spell.rarity {
        case .common: rarityMultiplier = 1
        case .uncommon: rarityMultiplier = 2
        case .rare: rarityMultiplier = 4
        case .epic: rarityMultiplier = 8
        case .legendary: rarityMultiplier = 15
        }
        
        return basePrice * rarityMultiplier
        */
    }
    
    private func showSpecialSlotSelector(for special: Special) {
        // Remove any existing selector first
        slotSelector?.removeFromParent()
        
        // Calculate container size to fit the entire screen
        let containerWidth = background.frame.width
        let containerHeight = background.frame.height
        
        // Create selector node
        let selector = SKNode()
        selector.zPosition = 2000
        
        // Add semi-transparent background
        let background = SKShapeNode(rectOf: CGSize(width: containerWidth, height: containerHeight))
        background.fillColor = .black
        background.alpha = 0.7
        background.strokeColor = .clear
        selector.addChild(background)
        
        // Add title
        let titleLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        titleLabel.text = "Select slot to replace"
        titleLabel.fontSize = 32
        titleLabel.position = CGPoint(x: 0, y: containerHeight/4)
        selector.addChild(titleLabel)
        
        // Setup slot buttons in a 2x2 grid
        let buttonWidth: CGFloat = min(180, containerWidth / 2.5)
        let buttonHeight: CGFloat = 120
        let padding: CGFloat = 20
        
        // Calculate grid layout
        let gridWidth = buttonWidth * 2 + padding
        let startX = -gridWidth/2 + buttonWidth/2
        let startY = buttonHeight/2 + padding/2  // Adjust this to position the grid vertically
        
        let slots = playerState.getSpecialSlots()
        for i in 0..<slots.count {
            let row = i / 2
            let col = i % 2
            
            let x = startX + CGFloat(col) * (buttonWidth + padding)
            let y = startY - CGFloat(row) * (buttonHeight + padding)
            
            let button = createSpecialSlotButton(
                slots[i],
                at: i,
                size: CGSize(width: buttonWidth, height: buttonHeight)
            )
            button.position = CGPoint(x: x, y: y)
            button.name = "specialSlotButton_\(i)"
            selector.addChild(button)
        }
        
        // Add cancel button
        let cancelButton = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        cancelButton.text = "Cancel"
        cancelButton.fontSize = 24
        cancelButton.fontColor = .red
        cancelButton.position = CGPoint(x: 0, y: -containerHeight/4)
        cancelButton.name = "specialSelectorCancel"
        selector.addChild(cancelButton)
        
        // Position the entire selector node in the center of the screen
        selector.position = CGPoint(x: background.frame.width/2, y: background.frame.height/2)
        
        addChild(selector)
        slotSelector = selector
    }
    
    private func createSpecialSlotButton(_ currentSpecial: Special?, at index: Int, size: CGSize) -> SKNode {
        let container = SKNode()
        container.name = "specialSlotButton_\(index)"
        
        let background = SKShapeNode(rectOf: size, cornerRadius: 10)
        if let special = currentSpecial {
            background.fillColor = special.rarity.color.withAlphaComponent(0.3)
            background.strokeColor = special.rarity.color
        } else {
            background.fillColor = .gray.withAlphaComponent(0.3)
            background.strokeColor = .white
        }
        container.addChild(background)
        
        let icon = SKSpriteNode(imageNamed: currentSpecial?.name ?? "EmptySpecial")
        icon.size = CGSize(width: size.width * 0.6, height: size.height * 0.6)
        container.addChild(icon)
        
        if let special = currentSpecial {
            let nameLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
            nameLabel.text = special.name
            nameLabel.fontSize = 12
            nameLabel.position = CGPoint(x: 0, y: -size.height/2 - 10)
            container.addChild(nameLabel)
            
            let rarityLabel = SKLabelNode(fontNamed: "HelveticaNeue")
            rarityLabel.text = special.rarity.name
            rarityLabel.fontSize = 10
            rarityLabel.fontColor = special.rarity.color
            rarityLabel.position = CGPoint(x: 0, y: -size.height/2 - 25)
            container.addChild(rarityLabel)
        }
        
        return container
    }
    
    private func showSpellSlotSelector(for newSpell: Spell) {
        // Remove any existing selector
        spellSelector?.removeFromParent()
        
        // Calculate container size to fit the entire screen
        let containerWidth = background.frame.width
        let containerHeight = background.frame.height
        
        // Create selector node
        let selector = SKNode()
        selector.zPosition = 2000
        
        // Add semi-transparent background
        let background = SKShapeNode(rectOf: CGSize(width: containerWidth, height: containerHeight))
        background.fillColor = .black
        background.alpha = 0.7
        background.strokeColor = .clear
        selector.addChild(background)
        
        // Add title
        let titleLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        titleLabel.text = "Select spell to replace"
        titleLabel.fontSize = 32
        titleLabel.position = CGPoint(x: 0, y: containerHeight/4)
        selector.addChild(titleLabel)
        
        // Setup spell buttons
        let buttonWidth: CGFloat = min(100, containerWidth / 4)
        let buttonHeight: CGFloat = min(100, containerHeight / 3)
        let padding: CGFloat = 15
        
        let currentSpells = playerState.getAvailableSpells()
        let totalWidth = CGFloat(currentSpells.count) * (buttonWidth + padding) - padding
        let startX = -totalWidth/2 + buttonWidth/2
        let buttonY: CGFloat = 0  // Center Y
        
        for (i, spell) in currentSpells.enumerated() {
            let button = createSpellButton(spell, at: i, size: CGSize(width: buttonWidth, height: buttonHeight))
            button.position = CGPoint(x: startX + CGFloat(i) * (buttonWidth + padding), y: buttonY)
            button.name = "spellSlotButton_\(i)"
            selector.addChild(button)
        }
        
        // Add cancel button
        let cancelButton = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        cancelButton.text = "Cancel"
        cancelButton.fontSize = 24
        cancelButton.fontColor = .red
        cancelButton.position = CGPoint(x: 0, y: -containerHeight/4)
        cancelButton.name = "spellSelectorCancel"
        selector.addChild(cancelButton)
        
        // Position the entire selector node in the center of the screen
        selector.position = CGPoint(x: background.frame.width/2, y: background.frame.height/2)
        
        addChild(selector)
        spellSelector = selector
    }
    
    private func createSpellButton(_ spell: Spell, at index: Int, size: CGSize) -> SKNode {
        let container = SKNode()
        
        let background = SKShapeNode(rectOf: size, cornerRadius: 10)
        background.fillColor = spell.rarity.color.withAlphaComponent(0.3)
        background.strokeColor = spell.rarity.color
        container.addChild(background)
        
        // Add spell icon if available
        let icon = SKSpriteNode(imageNamed: spell.name)
        icon.size = CGSize(width: size.width * 0.6, height: size.height * 0.6)
        container.addChild(icon)
        
        // Add spell name
        let nameLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        nameLabel.text = spell.name
        nameLabel.fontSize = 12
        nameLabel.position = CGPoint(x: 0, y: -size.height/2 - 10)
        container.addChild(nameLabel)
        
        // Add rarity label
        let rarityLabel = SKLabelNode(fontNamed: "HelveticaNeue")
        rarityLabel.text = spell.rarity.name
        rarityLabel.fontSize = 10
        rarityLabel.fontColor = spell.rarity.color
        rarityLabel.position = CGPoint(x: 0, y: -size.height/2 - 25)
        container.addChild(rarityLabel)
        
        return container
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        handleTouch(at: location)
    }
    
    private func handleTouch(at location: CGPoint) {
        let nodes = self.nodes(at: location)
        for node in nodes {
            if let name = node.name {
                if name.hasPrefix("specialSlotButton_") {
                    if let index = Int(name.dropFirst("specialSlotButton_".count)),
                       let special = ShopView.currentSpecialOffer,
                       let item = availableUpgrades.first(where: { $0.name == special.name }) {
                        // Complete the purchase with the specific slot index
                        completePurchase(item, replacingSlot: index)
                        slotSelector?.removeFromParent()
                        slotSelector = nil
                    }
                } else if name == "specialSelectorCancel" {
                    slotSelector?.removeFromParent()
                } else if name.hasPrefix("spellSlotButton_") {
                    if let index = Int(name.dropFirst("spellSlotButton_".count)),
                       let newSpell = ShopView.currentSpellOffer {
                        let currentSpells = playerState.getAvailableSpells()
                        if index < currentSpells.count {
                            playerState.replaceSpell(newSpell, at: index)
                            spellSelector?.removeFromParent()
                            refreshItemButtons() // Refresh buttons to show updated state
                        }
                    }
                } else if name == "spellSelectorCancel" {
                    spellSelector?.removeFromParent()
                }
            }
        }
    }
    
    private func setupResetTimerLabel(currentWave: Int) {
        resetTimerLabel.fontSize = 20
        resetTimerLabel.fontColor = .white
        resetTimerLabel.horizontalAlignmentMode = .center

        // Calculate waves until reset
        let wavesUntilReset = if currentWave % 2 == 0 {
            1  // Just reset, show 2 waves until next reset
        } else {
            2  // One wave has passed, show 1 wave until next reset
        }
        
        // Create reset message
        let resetText = "Shop resets in:\n\(wavesUntilReset) wave\(wavesUntilReset != 1 ? "s" : "")"
        
        resetTimerLabel.text = resetText
        resetTimerLabel.numberOfLines = 0  // Allow multiple lines
        resetTimerLabel.horizontalAlignmentMode = .center
        
        // Position it below the close button
        resetTimerLabel.position = CGPoint(
            x: closeButton.position.x,
            y: closeButton.position.y + 35  // Increase this value to move it lower
        )
        
        addChild(resetTimerLabel)
        updateResetTimer(currentWave: currentWave)
    }
    
    private func updateResetTimer(currentWave: Int) {
        // Calculate waves until reset
        let wavesUntilReset = if currentWave % 2 == 0 {
            1  // Just reset, show 2 waves until next reset
        } else {
            2  // One wave has passed, show 1 wave until next reset
        }
        
        // Update reset message
        let resetText = "Shop resets in:\n\(wavesUntilReset) wave\(wavesUntilReset != 1 ? "s" : "")"
        resetTimerLabel.text = resetText
    }
} 
