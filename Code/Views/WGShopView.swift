import SpriteKit
import Foundation

struct ShopItem {
    let name: String
    let description: String
    var basePrice: Int
    let icon: String  // Name of image asset
    let effect: (PlayerState, @escaping (String) -> Void) -> Void
    let rarity: SpellRarity
    
    // Add current price tracking
    private static var purchaseCounts: [String: Int] = [:]
    
    var currentPrice: Int {
        let purchases = ShopItem.purchaseCounts[name] ?? 0
        return basePrice + (purchases * basePrice)
    }
    
    var level: Int {
        return (ShopItem.purchaseCounts[name] ?? 0) + 1
    }
    
    // Add spellShopItems array
    static let spellShopItems: [ShopItem] = [
        // Legendary Spells
        ShopItem(
            name: "AC130",
            description: "Rain death from above",
            basePrice: 45,
            icon: "AC130",
            effect: { state, showMessage in
                state.addSpellToInventory("AC130")
                showMessage("AC-130 added to inventory!")
            },
            rarity: .legendary
        ),
        ShopItem(
            name: "TacticalNuke",
            description: "Ultimate destruction",
            basePrice: 50,
            icon: "TacticalNuke",
            effect: { state, showMessage in
                state.addSpellToInventory("TacticalNuke")
                showMessage("Tactical Nuke added to inventory!")
            },
            rarity: .legendary
        ),
        ShopItem(
            name: "DivineWrath",
            description: "Call down divine punishment",
            basePrice: 45,
            icon: "DivineWrath",
            effect: { state, showMessage in
                state.addSpellToInventory("DivineWrath")
                showMessage("Divine Wrath added to inventory!")
            },
            rarity: .legendary
        ),
        ShopItem(
            name: "ArcaneStorm",
            description: "Unleash arcane devastation",
            basePrice: 50,
            icon: "ArcaneStorm",
            effect: { state, showMessage in
                state.addSpellToInventory("ArcaneStorm")
                showMessage("Arcane Storm added to inventory!")
            },
            rarity: .legendary
        ),
        ShopItem(
            name: "MeteorShower",
            description: "Rain meteors from the sky",
            basePrice: 40,
            icon: "MeteorShower",
            effect: { state, showMessage in
                state.addSpellToInventory("MeteorShower")
                showMessage("Meteor Shower added to inventory!")
            },
            rarity: .legendary
        ),
        
        // Rare Spells
        ShopItem(
            name: "PredatorMissile",
            description: "Call in a deadly missile strike",
            basePrice: 35,
            icon: "PredatorMissile",
            effect: { state, showMessage in
                state.addSpellToInventory("PredatorMissile")
                showMessage("Predator Missile added to inventory!")
            },
            rarity: .rare
        ),
        ShopItem(
            name: "CrowSwarm",
            description: "Summon a swarm of crows",
            basePrice: 30,
            icon: "CrowSwarm",
            effect: { state, showMessage in
                state.addSpellToInventory("CrowSwarm")
                showMessage("Crow Swarm added to inventory!")
            },
            rarity: .rare
        ),
        ShopItem(
            name: "SwarmQueen",
            description: "Command a swarm of minions",
            basePrice: 35,
            icon: "SwarmQueen",
            effect: { state, showMessage in
                state.addSpellToInventory("SwarmQueen")
                showMessage("Swarm Queen added to inventory!")
            },
            rarity: .rare
        ),
        ShopItem(
            name: "NanoSwarm",
            description: "Release destructive nanobots",
            basePrice: 35,
            icon: "NanoSwarm",
            effect: { state, showMessage in
                state.addSpellToInventory("NanoSwarm")
                showMessage("Nano Swarm added to inventory!")
            },
            rarity: .rare
        ),
        ShopItem(
            name: "SteampunkTimeBomb",
            description: "Deploy a time-warping explosive",
            basePrice: 35,
            icon: "SteampunkTimeBomb",
            effect: { state, showMessage in
                state.addSpellToInventory("SteampunkTimeBomb")
                showMessage("Steampunk Time Bomb added to inventory!")
            },
            rarity: .rare
        ),
        ShopItem(
            name: "ShadowPuppet",
            description: "Control enemies from the shadows",
            basePrice: 35,
            icon: "ShadowPuppet",
            effect: { state, showMessage in
                state.addSpellToInventory("ShadowPuppet")
                showMessage("Shadow Puppet added to inventory!")
            },
            rarity: .rare
        ),
        ShopItem(
            name: "TemporalDistortion",
            description: "Manipulate time itself",
            basePrice: 35,
            icon: "TemporalDistortion",
            effect: { state, showMessage in
                state.addSpellToInventory("TemporalDistortion")
                showMessage("Temporal Distortion added to inventory!")
            },
            rarity: .rare
        ),
        ShopItem(
            name: "MysticBarrier",
            description: "Create a damaging barrier",
            basePrice: 35,
            icon: "MysticBarrier",
            effect: { state, showMessage in
                state.addSpellToInventory("MysticBarrier")
                showMessage("Mystic Barrier added to inventory!")
            },
            rarity: .rare
        ),
        ShopItem(
            name: "Blizzard",
            description: "Freeze and damage enemies",
            basePrice: 35,
            icon: "Blizzard",
            effect: { state, showMessage in
                state.addSpellToInventory("Blizzard")
                showMessage("Blizzard added to inventory!")
            },
            rarity: .rare
        ),
        ShopItem(
            name: "Inferno",
            description: "Create a devastating inferno",
            basePrice: 35,
            icon: "Inferno",
            effect: { state, showMessage in
                state.addSpellToInventory("Inferno")
                showMessage("Inferno added to inventory!")
            },
            rarity: .rare
        ),
        
        // Uncommon Spells
        ShopItem(
            name: "HologramTrap",
            description: "Deploy a holographic trap",
            basePrice: 25,
            icon: "HologramTrap",
            effect: { state, showMessage in
                state.addSpellToInventory("HologramTrap")
                showMessage("Hologram Trap added to inventory!")
            },
            rarity: .uncommon
        ),
        ShopItem(
            name: "SystemOverride",
            description: "Override enemy systems",
            basePrice: 25,
            icon: "SystemOverride",
            effect: { state, showMessage in
                state.addSpellToInventory("SystemOverride")
                showMessage("System Override added to inventory!")
            },
            rarity: .uncommon
        ),
        ShopItem(
            name: "CyberneticOverload",
            description: "Overload cybernetic systems",
            basePrice: 25,
            icon: "CyberneticOverload",
            effect: { state, showMessage in
                state.addSpellToInventory("CyberneticOverload")
                showMessage("Cybernetic Overload added to inventory!")
            },
            rarity: .uncommon
        ),
        ShopItem(
            name: "EarthShatter",
            description: "Shatter the ground beneath",
            basePrice: 25,
            icon: "EarthShatter",
            effect: { state, showMessage in
                state.addSpellToInventory("EarthShatter")
                showMessage("Earth Shatter added to inventory!")
            },
            rarity: .uncommon
        )
    ]
    
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
            rarity: .basic
        ),
        ShopItem(
            name: "Spell AOE +10%",
            description: "Increase spell area",
            basePrice: 8,
            icon: "aoe_upgrade",
            effect: { state, showMessage in
                state.spellAOEMultiplier *= 1.1
            },
            rarity: .basic
        ),
        ShopItem(
            name: "Spell Speed +15%",
            description: "Cast spells faster",
            basePrice: 12,
            icon: "speed_upgrade",
            effect: { state, showMessage in
                state.spellSpeedMultiplier *= 1.15
            },
            rarity: .basic
        ),
        ShopItem(
            name: "Mana Regen +20%",
            description: "Regenerate mana faster",
            basePrice: 15,
            icon: "regen_upgrade",
            effect: { state, showMessage in
                state.manaRegenRate *= 1.2
            },
            rarity: .basic
        ),
        ShopItem(
            name: "Spell Power +10%",
            description: "Increase spell damage",
            basePrice: 10,
            icon: "power_upgrade",
            effect: { state, showMessage in
                state.spellPowerMultiplier *= 1.1
            },
            rarity: .basic
        )
    ]
    
    static func recordPurchase(of itemName: String) {
        purchaseCounts[itemName] = (purchaseCounts[itemName] ?? 0) + 1
    }
}

class ShopView: SKNode {
    private let playerState: PlayerState
    private var onClose: () -> Void
    private weak var playerView: PlayerView?
    
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
    
    init(size: CGSize, playerState: PlayerState, config: WaveConfig, currentWave: Int, playerView: PlayerView?, onClose: @escaping () -> Void) {
        self.playerState = playerState
        self.onClose = onClose
        self.playerView = playerView
        self.background = SKSpriteNode(color: .black.withAlphaComponent(0.8), size: size)
        self.statsLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        self.closeButton = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        self.waveInfoLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        self.goblinTypeLabels = []
        
        // Call super.init()
        super.init()
        
        // Select random upgrades BEFORE setting up UI
        selectRandomUpgrades()  // Make sure this happens first
        
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
        
        // Calculate total width needed for both buttons
        let totalWidth = (buttonWidth * 2) + padding
        let startX = (size.width - totalWidth) / 2 + buttonWidth / 2
        
        // Position buttons between coin display and close button
        let buttonY = size.height * 0.45  // Adjusted to be lower than middle
        
        // Position the permanent upgrades
        for (index, item) in availableUpgrades.prefix(2).enumerated() {
            let x = startX + CGFloat(index) * (buttonWidth + padding)
            let button = createItemButton(item: item, size: CGSize(width: buttonWidth, height: buttonHeight))
            button.position = CGPoint(x: x, y: buttonY)
            addChild(button)
            itemButtons.append(button)
        }
        
        // Position the spell button below the permanent upgrades
        if let spellItem = availableUpgrades.last {
            let spellButtonY = buttonY - buttonHeight - 40  // Position below the upgrade buttons
            let spellButton = createItemButton(item: spellItem, size: CGSize(width: buttonWidth, height: buttonHeight))
            spellButton.position = CGPoint(x: size.width / 2, y: spellButtonY)
            addChild(spellButton)
            itemButtons.append(spellButton)
        }
        
        // Position close button lower
        closeButton.position = CGPoint(x: size.width/2, y: buttonY - buttonHeight - 130)
        addChild(closeButton)
    }
    
    private func createItemButton(item: ShopItem, size: CGSize) -> SKNode {
        let container = SKNode()
        
        // Button background
        let backgroundColor: SKColor = playerState.hasConsumableSpell(item.name) ? .gray : .darkGray
        let background = SKSpriteNode(color: backgroundColor, size: size)
        background.name = "itemButton_\(item.name)"
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
        descLabel.text = playerState.hasConsumableSpell(item.name) ? "Already Purchased" : item.description
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
        priceLabel.text = playerState.hasConsumableSpell(item.name) ? "" : "\(item.currentPrice) coins"
        priceLabel.fontSize = 12
        priceLabel.fontColor = .yellow
        priceLabel.position = CGPoint(x: 0, y: -30)
        priceLabel.horizontalAlignmentMode = .center
        priceLabel.verticalAlignmentMode = .center
        container.addChild(priceLabel)
        
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
        
        // Check if the item is a spell (not basic rarity) and if it has already been purchased
        if item.rarity != .basic {  // This means it's a spell
            if playerState.hasConsumableSpell(item.name) {
                showMessage("Spell already purchased!")
                return
            }
        }
        
        playerState.coins -= item.currentPrice
        item.effect(playerState, showMessage)
        ShopItem.recordPurchase(of: item.name)
        
        // Add the purchased spell to the player's inventory only if it's a spell
        if item.rarity != .basic {
            playerState.addSpellToInventory(item.name)
        }
        
        // Show level up message
        showMessage("\(item.name) upgraded to Level \(item.level)!")
        
        // Refresh UI to reflect purchase
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
        
        // Calculate total width needed for both buttons - same as setupUI
        let totalWidth = (buttonWidth * 2) + padding
        let startX = (background.frame.width - totalWidth) / 2 + buttonWidth / 2
        let buttonY = background.frame.height * 0.45  // Match setupUI positioning
        
        // Position the permanent upgrades
        for (index, item) in availableUpgrades.prefix(2).enumerated() {
            let x = startX + CGFloat(index) * (buttonWidth + padding)
            let button = createItemButton(item: item, size: CGSize(width: buttonWidth, height: buttonHeight))
            button.position = CGPoint(x: x, y: buttonY)
            addChild(button)
            itemButtons.append(button)
        }
        
        // Position the spell button below the permanent upgrades
        if let spellItem = availableUpgrades.last {
            let spellButtonY = buttonY - buttonHeight - 40  // Position below the upgrade buttons
            let spellButton = createItemButton(item: spellItem, size: CGSize(width: buttonWidth, height: buttonHeight))
            spellButton.position = CGPoint(x: background.frame.width / 2, y: spellButtonY)
            addChild(spellButton)
            itemButtons.append(spellButton)
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
    
    private func selectRandomUpgrades() {
        // Select 2 permanent upgrades
        let permanentUpgrades = Array(ShopItem.permanentUpgrades.shuffled().prefix(2))
        
        // Select 1 random spell
        let randomSpell = ShopItem.spellShopItems.randomElement()!
        
        // Combine permanent upgrades and spell
        availableUpgrades = permanentUpgrades + [randomSpell]
        print("Selected upgrades: \(availableUpgrades.map { $0.name })")
    }
} 
