import SpriteKit

struct ShopItem {
    enum Category: String {
        case spells
        case oneTimePowerups
        case spellUpgrades
        case playerUpgrades
    }
    
    let name: String
    let description: String
    let price: Int
    let icon: String  // Name of image asset
    let category: Category
    let effect: (PlayerState) -> Void
    
    // Predefined shop items
    static let items: [ShopItem] = [
        // Player Upgrades
        ShopItem(
            name: "Max Health +20",
            description: "Increase maximum health by 20",
            price: 5,
            icon: "health_upgrade",
            category: .playerUpgrades,
            effect: { state in
                state.maxHealth += 20
            }
        ),
        ShopItem(
            name: "Max Spell Charges +1",
            description: "Increase spell charges by 1",
            price: 10,
            icon: "SpellCharges",
            category: .playerUpgrades,
            effect: { state in
                state.maxSpellCharges += 1
                state.playerOneSpellCharges = state.maxSpellCharges
                state.playerTwoSpellCharges = state.maxSpellCharges
            }
        ),
        ShopItem(
            name: "Spell Power +10%",
            description: "Increase spell damage by 10%",
            price: 5,
            icon: "power_upgrade",
            category: .playerUpgrades,
            effect: { state in
                state.spellPowerMultiplier *= 1.1
            }
        ),
        // Spells
        ShopItem(
            name: "Lightning Spell",
            description: "Unlock the Lightning Spell",
            price: 15,
            icon: "LightningSpell",
            category: .playerUpgrades,//to be made .spells eventually
            effect: { state in
                let lightningSpell = LightningSpell()
                state.unlockedSpells.append(lightningSpell)
            }
        )/*,
        ShopItem(
            name: "Ice Spell",
            description: "Unlock the Ice Spell",
            price: 12,
            icon: "IceSpell",
            category: .spells,
            effect: { state in
                let iceSpell = IceSpell()
                state.unlockedSpells.append(iceSpell)
            }
        )*,
        // One-Time Use Powerups
        ShopItem(
            name: "Health Potion",
            description: "Restore 50 health when used",
            price: 8,
            icon: "HealthPotion",
            category: .oneTimePowerups,
            effect: { state in
                if state.powerups.count < 2 {
                    let healthPotion = PowerUp(
                        name: "Health Potion",
                        icon: "HealthPotion",
                        effect: { state in
                            state.castleHealth = min(state.maxHealth, state.castleHealth + 50)
                        }
                    )
                    state.powerups.append(healthPotion)
                }
            }
        ),
        // Spell Upgrades
        ShopItem(
            name: "Fireball Damage +10",
            description: "Increase Fireball damage by 10",
            price: 10,
            icon: "FireballUpgrade",
            category: .spellUpgrades,
            effect: { state in
                if let fireball = state.unlockedSpells.first(where: { $0.name == "Fireball" }) {
                    fireball.damage += 10
                }
            }
        )*/
    ]
}

class ShopView: SKNode {
    private let playerState: PlayerState
    private var onClose: () -> Void
    
    // UI Elements
    private let background: SKSpriteNode
    private let statsLabel: SKLabelNode
    private var itemButtons: [SKNode] = []
    private let closeButton: SKLabelNode
    private let equipButton: SKLabelNode
    private let sectionButtons: [SKLabelNode]
    private var selectedCategory: ShopItem.Category = .playerUpgrades
    
    // Equip Screen Elements
    private var equipScreen: SKNode?
    
    init(size: CGSize, playerState: PlayerState, onClose: @escaping () -> Void) {
        self.playerState = playerState
        self.onClose = onClose
        
        // Create semi-transparent background
        background = SKSpriteNode(color: .black.withAlphaComponent(0.8), size: size)
        
        // Initialize stats label
        statsLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        statsLabel.fontSize = 24
        
        // Initialize close button
        closeButton = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        closeButton.text = "Close Shop & Start Next Wave"
        closeButton.fontSize = 24
        closeButton.fontColor = .white
        closeButton.name = "closeShopButton"
        
        // Initialize equip button
        equipButton = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        equipButton.text = "Equip"
        equipButton.fontSize = 24
        equipButton.fontColor = .white
        equipButton.name = "equipButton"
        
        // Initialize section buttons
        let categories: [ShopItem.Category] = [.playerUpgrades, .spells, .oneTimePowerups, .spellUpgrades]
        sectionButtons = categories.map { category in
            let button = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
            button.text = category.rawValue.capitalized
            button.fontSize = 20
            button.fontColor = .white
            button.name = "sectionButton_\(category.rawValue)"
            return button
        }
        
        super.init()
        
        setupUI(size: size)
        updateStats()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(size: CGSize) {
        // Add background
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(background)
        
        // Position stats label
        statsLabel.position = CGPoint(x: size.width/2, y: size.height - 100)
        addChild(statsLabel)
        
        // Position equip button at the top right
        equipButton.position = CGPoint(x: size.width - 80, y: size.height - 50)
        addChild(equipButton)
        
        // Position section buttons
        let startX = size.width / 2 - CGFloat(sectionButtons.count - 1) * 100 / 2
        for (index, button) in sectionButtons.enumerated() {
            button.position = CGPoint(x: startX + CGFloat(index) * 100, y: size.height - 150)
            addChild(button)
        }
        
        // Create item buttons for the selected category
        createItemButtons(for: selectedCategory)
        
        // Position close button at bottom
        closeButton.position = CGPoint(x: size.width/2, y: 100)
        addChild(closeButton)
    }
    
    private func createItemButtons(for category: ShopItem.Category) {
        // Remove existing item buttons
        itemButtons.forEach { $0.removeFromParent() }
        itemButtons = []
        
        // Filter items by category
        let items = ShopItem.items.filter { $0.category == category }
        
        // Create grid of item buttons
        let gridWidth = 2
        let buttonWidth: CGFloat = 200
        let buttonHeight: CGFloat = 200
        let padding: CGFloat = 20
        
        let startX = background.size.width/2 - CGFloat(gridWidth-1) * (buttonWidth + padding)/2
        let startY = background.size.height/2 + CGFloat(((items.count + 1) / 2) - 1) * (buttonHeight + padding)/2
        
        for (index, item) in items.enumerated() {
            let row = index / gridWidth
            let col = index % gridWidth
            
            let x = startX + CGFloat(col) * (buttonWidth + padding)
            let y = startY - CGFloat(row) * (buttonHeight + padding)
            
            let button = createItemButton(item: item, size: CGSize(width: buttonWidth, height: buttonHeight))
            button.position = CGPoint(x: x, y: y)
            addChild(button)
            itemButtons.append(button)
        }
    }
    
    private func createItemButton(item: ShopItem, size: CGSize) -> SKNode {
        let container = SKNode()
        
        // Button background
        let background = SKSpriteNode(color: .gray.withAlphaComponent(0.3), size: size)
        background.name = "itemButton_\(item.name)"
        container.addChild(background)
        
        // Item name
        let nameLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        nameLabel.text = item.name
        nameLabel.fontSize = 20
        nameLabel.position = CGPoint(x: 0, y: 30)
        container.addChild(nameLabel)
        
        // Price
        let priceLabel = SKLabelNode(fontNamed: "HelveticaNeue")
        priceLabel.text = "\(item.price) coins"
        priceLabel.fontSize = 18
        priceLabel.fontColor = .yellow
        priceLabel.position = CGPoint(x: 0, y: -30)
        container.addChild(priceLabel)
        
        return container
    }
    
    private func updateStats() {
        statsLabel.text = "Coins: \(playerState.coins) | Score: \(playerState.score)"
    }
    
    func handleTap(at point: CGPoint) {
        let nodes = self.nodes(at: point)
        
        for node in nodes {
            if node.name == "closeShopButton" {
                onClose()
                return
            }
            if node.name == "equipButton" {
                showEquipScreen()
                return
            }
            if let buttonName = node.name {
                if buttonName.starts(with: "sectionButton_") {
                    if let categoryName = buttonName.split(separator: "_").last,
                       let category = ShopItem.Category(rawValue: String(categoryName)) {
                        selectedCategory = category
                        createItemButtons(for: selectedCategory)
                    }
                    return
                } else if buttonName.starts(with: "itemButton_") {
                    let itemName = buttonName.replacingOccurrences(of: "itemButton_", with: "")
                    if let item = ShopItem.items.first(where: { $0.name == itemName }) {
                        purchaseItem(item)
                    }
                    return
                }
            }
        }
    }
    
    private func purchaseItem(_ item: ShopItem) {
        guard playerState.coins >= item.price else {
            showMessage("Not enough coins!")
            return
        }
        
        playerState.coins -= item.price
        item.effect(playerState)
        updateStats()
        showMessage("Purchase successful!")
    }
    
    private func showMessage(_ text: String) {
        let message = SKLabelNode(fontNamed: "HelveticaNeue")
        message.text = text
        message.fontSize = 24
        message.fontColor = .white
        message.position = CGPoint(x: background.frame.midX, y: background.frame.midY)
        message.alpha = 0
        addChild(message)
        
        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
        let wait = SKAction.wait(forDuration: 1.0)
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let remove = SKAction.removeFromParent()
        
        message.run(SKAction.sequence([fadeIn, wait, fadeOut, remove]))
    }
    
    private func showEquipScreen() {
        // Remove item buttons and section buttons
        itemButtons.forEach { $0.removeFromParent() }
        sectionButtons.forEach { $0.removeFromParent() }
        
        // Create equip screen node
        equipScreen = SKNode()
        
        // Top section: Stats comparison
        let statsComparison = createStatsComparison()
        statsComparison.position = CGPoint(x: background.size.width / 2, y: background.size.height - 200)
        equipScreen?.addChild(statsComparison)
        
        // Middle section: Powerups
        let powerupsDisplay = createPowerupsDisplay()
        powerupsDisplay.position = CGPoint(x: background.size.width / 2, y: background.size.height / 2)
        equipScreen?.addChild(powerupsDisplay)
        
        // Bottom section: Equipped spells
        let spellsDisplay = createSpellsDisplay()
        spellsDisplay.position = CGPoint(x: background.size.width / 2, y: 150)
        equipScreen?.addChild(spellsDisplay)
        
        addChild(equipScreen!)
        
        // Change equip button text to "Back"
        equipButton.text = "Back"
        equipButton.name = "backButton"
    }
    
    private func createStatsComparison() -> SKNode {
        let node = SKNode()
        
        let stats = ["Max Health", "Max Spell Charges", "Spell Power Multiplier"]
        let originalValues: [String] = ["100", "5", "1.0"]
        let upgradedValues: [String] = [
            "\(Int(playerState.maxHealth))",
            "\(playerState.maxSpellCharges)",
            String(format: "%.1f", playerState.spellPowerMultiplier)
        ]
        
        for (index, stat) in stats.enumerated() {
            let statLabel = SKLabelNode(fontNamed: "HelveticaNeue")
            statLabel.fontSize = 20
            statLabel.fontColor = .gray
            statLabel.text = "\(stat): \(originalValues[index]) --->"
            statLabel.horizontalAlignmentMode = .left
            statLabel.position = CGPoint(x: -150, y: CGFloat(-30 * index))
            node.addChild(statLabel)
            
            let upgradedLabel = SKLabelNode(fontNamed: "HelveticaNeue")
            upgradedLabel.fontSize = 20
            upgradedLabel.fontColor = .green
            upgradedLabel.text = upgradedValues[index]
            upgradedLabel.horizontalAlignmentMode = .left
            upgradedLabel.position = CGPoint(x: 50, y: CGFloat(-30 * index))
            node.addChild(upgradedLabel)
        }
        
        return node
    }
    
    private func createPowerupsDisplay() -> SKNode {
        let node = SKNode()
        let titleLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        titleLabel.text = "Powerups"
        titleLabel.fontSize = 24
        titleLabel.position = CGPoint(x: 0, y: 50)
        node.addChild(titleLabel)
        
        for (index, powerup) in playerState.powerups.enumerated() {
            let powerupLabel = SKLabelNode(fontNamed: "HelveticaNeue")
            powerupLabel.text = powerup.name
            powerupLabel.fontSize = 20
            powerupLabel.position = CGPoint(x: 0, y: CGFloat(-30 * index))
            node.addChild(powerupLabel)
        }
        return node
    }
    
    private func createSpellsDisplay() -> SKNode {
        let node = SKNode()
        let titleLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        titleLabel.text = "Equipped Spells"
        titleLabel.fontSize = 24
        titleLabel.position = CGPoint(x: 0, y: 50)
        node.addChild(titleLabel)
        
        // Display equipped spells
        for (index, spell) in playerState.equippedSpells.enumerated() {
            let spellLabel = SKLabelNode(fontNamed: "HelveticaNeue")
            spellLabel.text = spell?.name ?? "DefaultSpell"
            spellLabel.fontSize = 20
            spellLabel.position = CGPoint(x: -100, y: CGFloat(-30 * index))
            node.addChild(spellLabel)
            
            // Add change button
            let changeButton = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
            changeButton.text = "Change"
            changeButton.fontSize = 18
            changeButton.fontColor = .blue
            changeButton.name = "changeSpellButton_\(index)"
            changeButton.position = CGPoint(x: 100, y: CGFloat(-30 * index))
            node.addChild(changeButton)
        }
        return node
    }
    
    private func handleEquipScreenTap(at point: CGPoint) {
        let nodes = self.nodes(at: point)
        
        for node in nodes {
            if let name = node.name {
                if name.starts(with: "changeSpellButton_") {
                    let indexString = name.replacingOccurrences(of: "changeSpellButton_", with: "")
                    if let index = Int(indexString) {
                        showSpellSelection(forSlot: index)
                    }
                    return
                } else if name == "backButton" {
                    closeEquipScreen()
                    return
                }
            }
        }
    }
    
    private func showSpellSelection(forSlot slotIndex: Int) {
        // Remove current equip screen
        equipScreen?.removeFromParent()
        
        // Show available spells to equip
        let selectionScreen = SKNode()
        
        let titleLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        titleLabel.text = "Select a Spell"
        titleLabel.fontSize = 24
        titleLabel.position = CGPoint(x: background.size.width / 2, y: background.size.height - 200)
        selectionScreen.addChild(titleLabel)
        
        // List unlocked spells
        for (index, spell) in playerState.unlockedSpells.enumerated() {
            let spellLabel = SKLabelNode(fontNamed: "HelveticaNeue")
            spellLabel.text = spell.name
            spellLabel.fontSize = 20
            spellLabel.name = "spellOption_\(index)_\(slotIndex)"
            spellLabel.position = CGPoint(x: background.size.width / 2, y: background.size.height - 250 - CGFloat(30 * index))
            selectionScreen.addChild(spellLabel)
        }
        
        addChild(selectionScreen)
        equipScreen = selectionScreen
    }
    
    private func handleSpellSelectionTap(at point: CGPoint) {
        let nodes = self.nodes(at: point)
        
        for node in nodes {
            if let name = node.name, name.starts(with: "spellOption_") {
                let components = name.split(separator: "_")
                if components.count == 3,
                   let spellIndex = Int(components[1]),
                   let slotIndex = Int(components[2]) {
                    playerState.equippedSpells[slotIndex] = playerState.unlockedSpells[spellIndex]
                    // Refresh equip screen
                    equipScreen?.removeFromParent()
                    showEquipScreen()
                }
                return
            }
        }
    }
    
    private func closeEquipScreen() {
        equipScreen?.removeFromParent()
        equipScreen = nil
        equipButton.text = "Equip"
        equipButton.name = "equipButton"
        setupUI(size: background.size)
    }
} 
