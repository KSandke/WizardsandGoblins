import SpriteKit
import Foundation


struct ShopItem {
    let name: String
    let description: String
    var basePrice: Int
    let icon: String  // Name of image asset
    let effect: (PlayerState, @escaping (String) -> Void) -> Void
    let rarity: ItemRarity?  // Add optional rarity property
    
    // Add current price tracking
    private static var purchaseCounts: [String: Int] = [:]
    
    var currentPrice: Int {
        let purchases = ShopItem.purchaseCounts[name] ?? 0
        return basePrice + (purchases * basePrice)
    }
    
    var level: Int {
        return (ShopItem.purchaseCounts[name] ?? 0) + 1
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
            }
        ),
        ShopItem(
            name: "Spell AOE +10%",
            description: "Increase spell area",
            basePrice: 8,
            icon: "aoe_upgrade",
            effect: { state, showMessage in
                state.spellAOEMultiplier *= 1.1
            }
        ),
        ShopItem(
            name: "Spell Speed +15%",
            description: "Cast spells faster",
            basePrice: 12,
            icon: "speed_upgrade",
            effect: { state, showMessage in
                state.spellSpeedMultiplier *= 1.15
            }
        ),
        ShopItem(
            name: "Mana Regen +20%",
            description: "Regenerate mana faster",
            basePrice: 15,
            icon: "regen_upgrade",
            effect: { state, showMessage in
                state.manaRegenRate *= 1.2
            }
        ),
        ShopItem(
            name: "Spell Power +10%",
            description: "Increase spell damage",
            basePrice: 10,
            icon: "power_upgrade",
            effect: { state, showMessage in
                state.spellPowerMultiplier *= 1.1
            }
        )
    ]
    
    static func recordPurchase(of itemName: String) {
        purchaseCounts[itemName] = (purchaseCounts[itemName] ?? 0) + 1
    }
    
    // Update initializer to include rarity
    init(name: String, description: String, basePrice: Int, icon: String, effect: @escaping (PlayerState, @escaping (String) -> Void) -> Void, rarity: ItemRarity? = nil) {
        self.name = name
        self.description = description
        self.basePrice = basePrice
        self.icon = icon
        self.effect = effect
        self.rarity = rarity
    }
}

class ShopView: SKNode {
    private let playerState: PlayerState
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
    
    init(size: CGSize, playerState: PlayerState, config: WaveConfig, currentWave: Int, onClose: @escaping () -> Void) {
        // Initialize all properties before super.init()
        self.playerState = playerState
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
        
        // Calculate total width needed for both permanent upgrade buttons
        let totalWidth = (buttonWidth * 2) + padding
        let startX = (size.width - totalWidth) / 2 + buttonWidth / 2
        
        // Position buttons between coin display and close button
        let upperButtonY = size.height * 0.55  // Upper row for permanent upgrades
        let lowerButtonY = size.height * 0.35  // Lower row for special
        
        // First, position the permanent upgrades
        let permanentUpgrades = availableUpgrades.filter { $0.rarity == nil }
        for (index, item) in permanentUpgrades.enumerated() {
            let x = startX + CGFloat(index) * (buttonWidth + padding)
            let button = createItemButton(item: item, size: CGSize(width: buttonWidth, height: buttonHeight))
            button.position = CGPoint(x: x, y: upperButtonY)
            addChild(button)
            itemButtons.append(button)
        }
        
        // Then, position the special upgrade if available
        if let specialUpgrade = availableUpgrades.first(where: { $0.rarity != nil }) {
            let button = createItemButton(item: specialUpgrade, size: CGSize(width: buttonWidth, height: buttonHeight))
            button.position = CGPoint(x: size.width/2, y: lowerButtonY)
            addChild(button)
            itemButtons.append(button)
        }
        
        // Position close button at the bottom
        closeButton.position = CGPoint(x: size.width/2, y: lowerButtonY - buttonHeight - 40)
        addChild(closeButton)
    }
    
    private func createItemButton(item: ShopItem, size: CGSize) -> SKNode {
        let container = SKNode()
        container.name = "itemButton_\(item.name)"
        
        // Create background with rarity color if applicable
        let background = SKShapeNode(rectOf: size, cornerRadius: 10)
        if let rarity = item.rarity {
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
        
        // Price
        let priceLabel = SKLabelNode(fontNamed: "HelveticaNeue")
        priceLabel.text = "\(item.currentPrice) coins"
        priceLabel.fontSize = 12
        priceLabel.fontColor = .yellow
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
        guard playerState.coins >= item.currentPrice else {
            showMessage("Not enough coins!")
            return
        }
        
        playerState.coins -= item.currentPrice
        
        // Debug prints for special purchases
        if item.rarity != nil {
            print("🎯 Purchasing special: \(item.name) (Rarity: \(item.rarity?.name ?? "Unknown"))")
            
            // Print special slots before purchase
            print("📋 Special slots BEFORE purchase:")
            let beforeSlots = playerState.getSpecialSlots()
            for (index, special) in beforeSlots.enumerated() {
                print("  Slot \(index): \(special?.name ?? "Empty")")
            }
        }
        
        item.effect(playerState, showMessage)
        ShopItem.recordPurchase(of: item.name)
        
        // Print special slots after purchase if it was a special
        if item.rarity != nil {
            print("📋 Special slots AFTER purchase:")
            let afterSlots = playerState.getSpecialSlots()
            for (index, special) in afterSlots.enumerated() {
                print("  Slot \(index): \(special?.name ?? "Empty")")
            }
            print("-------------------")
        }
        
        // Show level up message
        showMessage("\(item.name) upgraded to Level \(item.level)!")
        
        refreshItemButtons()
        updateStats()
    }
    
    // Update refreshItemButtons to match the new layout
    private func refreshItemButtons() {
        itemButtons.forEach { $0.removeFromParent() }
        itemButtons.removeAll()
        
        let buttonWidth: CGFloat = min(180, background.frame.width / 2.5)
        let buttonHeight: CGFloat = 120
        let padding: CGFloat = 20
        
        // Calculate total width needed for both permanent upgrade buttons
        let totalWidth = (buttonWidth * 2) + padding
        let startX = (background.frame.width - totalWidth) / 2 + buttonWidth / 2
        
        // Position buttons with same layout as setupUI
        let upperButtonY = background.frame.height * 0.55  // Upper row for permanent upgrades
        let lowerButtonY = background.frame.height * 0.35  // Lower row for special
        
        // First, position the permanent upgrades
        let permanentUpgrades = availableUpgrades.filter { $0.rarity == nil }
        for (index, item) in permanentUpgrades.enumerated() {
            let x = startX + CGFloat(index) * (buttonWidth + padding)
            let button = createItemButton(item: item, size: CGSize(width: buttonWidth, height: buttonHeight))
            button.position = CGPoint(x: x, y: upperButtonY)
            addChild(button)
            itemButtons.append(button)
        }
        
        // Then, position the special upgrade if available
        if let specialUpgrade = availableUpgrades.first(where: { $0.rarity != nil }) {
            let button = createItemButton(item: specialUpgrade, size: CGSize(width: buttonWidth, height: buttonHeight))
            button.position = CGPoint(x: background.frame.width/2, y: lowerButtonY)
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
        
        // Create special shop item if available
        var upgrades = [ShopItem]()
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
        
        // Add regular upgrades
        let regularUpgrades = Array(ShopItem.permanentUpgrades.shuffled().prefix(2))
        upgrades.append(contentsOf: regularUpgrades)
        
        availableUpgrades = upgrades
    }
    
    private func calculateSpecialPrice(_ special: Special) -> Int {
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
        
        // Define all possible specials
        let allSpecials: [Special] = [
            Special(name: "FireStorm", aoeRadius: 100, aoeColor: .red, duration: 0.5, damage: 20, effect: nil, cooldown: 10, targetingMode: .global, rarity: .common),
            Special(name: "IceBlast", aoeRadius: 80, aoeColor: .cyan, duration: 0.5, damage: 30, effect: nil, cooldown: 8, targetingMode: .random, rarity: .uncommon),
            Special(name: "LightningStrike", aoeRadius: 60, aoeColor: .yellow, duration: 0.5, damage: 45, effect: nil, cooldown: 6, targetingMode: .maxHealth, rarity: .rare),
            Special(name: "VoidBlast", aoeRadius: 120, aoeColor: .purple, duration: 0.5, damage: 60, effect: nil, cooldown: 5, targetingMode: .global, rarity: .epic),
            Special(name: "DragonBreath", aoeRadius: 150, aoeColor: .orange, duration: 0.5, damage: 100, effect: nil, cooldown: 4, targetingMode: .global, rarity: .legendary)
        ]
        
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
} 
