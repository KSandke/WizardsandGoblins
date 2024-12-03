import SpriteKit
import Foundation


struct ShopItem {
    let name: String
    let description: String
    var basePrice: Int
    let icon: String  // Name of image asset
    let effect: (PlayerState, @escaping (String) -> Void) -> Void
    
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
    
    private var currentWaveUpgrades: [ShopItem] = []
    
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
        
        // Setup UI after initialization
        setupUI(size: size)
        setupWaveInfo(config, size: size)
        updateStats()
        selectRandomUpgrades(currentWave: currentWave)
        
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
        
        // Create coin display with larger font and icon
        statsLabel.fontSize = 32  // Increased from 24
        statsLabel.fontColor = .yellow  // Make coins yellow
        statsLabel.position = CGPoint(x: size.width/2 + 25, y: size.height - 120)  // Shifted right to make room for icon
        addChild(statsLabel)
        
        // Add coin icon
        let coinIcon = SKSpriteNode(imageNamed: "coin")  // Make sure you have this asset
        coinIcon.size = CGSize(width: 40, height: 40)  // Adjust size as needed
        coinIcon.position = CGPoint(x: statsLabel.position.x - 100, y: statsLabel.position.y)
        addChild(coinIcon)
        
        // Create grid of item buttons
        let gridWidth = 2
        let gridHeight = 2
        let buttonWidth: CGFloat = 180
        let buttonHeight: CGFloat = 120
        let padding: CGFloat = 20
        
        let startX = size.width/2 - CGFloat(gridWidth-1) * (buttonWidth + padding)/2
        let startY = size.height/2 + CGFloat(gridHeight-1) * (buttonHeight + padding)/2
        
        for (index, item) in ShopItem.permanentUpgrades.enumerated() {
            let row = index / gridWidth
            let col = index % gridWidth
            
            let x = startX + CGFloat(col) * (buttonWidth + padding)
            let y = startY - CGFloat(row) * (buttonHeight + padding)
            
            let button = createItemButton(item: item, size: CGSize(width: buttonWidth, height: buttonHeight))
            button.position = CGPoint(x: x, y: y)
            addChild(button)
            itemButtons.append(button)
        }
        
        // Position close button at bottom
        closeButton.position = CGPoint(x: size.width/2, y: 100)
        addChild(closeButton)
    }
    
    private func createItemButton(item: ShopItem, size: CGSize) -> SKNode {
        let container = SKNode()
        
        // Button background
        let background = SKSpriteNode(color: .gray.withAlphaComponent(0.3), size: size)
        background.name = "itemButton_\(item.name)"
        container.addChild(background)
        
        // Item name (without level)
        let nameLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        nameLabel.text = item.name
        nameLabel.fontSize = 16
        nameLabel.position = CGPoint(x: 0, y: 40)
        container.addChild(nameLabel)
        
        // Level display
        let levelLabel = SKLabelNode(fontNamed: "HelveticaNeue")
        levelLabel.text = "Level \(item.level)"
        levelLabel.fontSize = 14
        levelLabel.fontColor = .green
        levelLabel.position = CGPoint(x: 0, y: 20)
        container.addChild(levelLabel)
        
        // Description
        let descLabel = SKLabelNode(fontNamed: "HelveticaNeue")
        descLabel.text = item.description
        descLabel.fontSize = 12
        descLabel.position = CGPoint(x: 0, y: 0)
        container.addChild(descLabel)
        
        // Price
        let priceLabel = SKLabelNode(fontNamed: "HelveticaNeue")
        priceLabel.text = "\(item.currentPrice) coins"
        priceLabel.fontSize = 14
        priceLabel.fontColor = .yellow
        priceLabel.position = CGPoint(x: 0, y: -20)
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
               let item = ShopItem.permanentUpgrades.first(where: { "itemButton_\($0.name)" == buttonName }) {
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
        item.effect(playerState, showMessage)
        ShopItem.recordPurchase(of: item.name)
        
        // Show level up message
        showMessage("\(item.name) upgraded to Level \(item.level)!")
        
        refreshItemButtons()
        updateStats()
    }
    
    // Add method to refresh item buttons
    private func refreshItemButtons() {
        // Remove existing buttons
        itemButtons.forEach { $0.removeFromParent() }
        itemButtons.removeAll()
        
        // Recreate buttons with updated prices
        let gridWidth = 2
        let gridHeight = 2
        let buttonWidth: CGFloat = 180
        let buttonHeight: CGFloat = 120
        let padding: CGFloat = 20
        
        let startX = background.frame.width/2 - CGFloat(gridWidth-1) * (buttonWidth + padding)/2
        let startY = background.frame.height/2 + CGFloat(gridHeight-1) * (buttonHeight + padding)/2
        
        for (index, item) in ShopItem.permanentUpgrades.enumerated() {
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
            x: statsLabel.position.x,
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
        // Add "Next Wave:" header
        waveInfoLabel.text = "Next Wave Composition:"
        waveInfoLabel.fontSize = 24
        waveInfoLabel.fontColor = .white
        waveInfoLabel.position = CGPoint(x: size.width/2, y: size.height - 200)
        addChild(waveInfoLabel)
        
        // Calculate total goblins
        let totalGoblins = config.maxGoblins
        
        // Create labels for each goblin type
        var yOffset: CGFloat = waveInfoLabel.position.y - 40
        for (type, probability) in config.goblinTypeProbabilities {
            let count = Int(round(Double(totalGoblins) * probability / 100.0))
            let typeLabel = SKLabelNode(fontNamed: "HelveticaNeue")
            typeLabel.fontSize = 18
            typeLabel.fontColor = .white
            typeLabel.text = "\(goblinTypeName(type)): \(count)"
            typeLabel.position = CGPoint(x: size.width/2, y: yOffset)
            addChild(typeLabel)
            yOffset -= 25
        }
        
        // Add total count
        let totalLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        totalLabel.fontSize = 20
        totalLabel.fontColor = .yellow
        totalLabel.text = "Total Goblins: \(totalGoblins)"
        totalLabel.position = CGPoint(x: size.width/2, y: yOffset - 10)
        addChild(totalLabel)
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
    
    private func selectRandomUpgrades(currentWave: Int) {
        // Randomly select 2 permanent upgrades
        currentWaveUpgrades = Array(ShopItem.permanentUpgrades.shuffled().prefix(2))
        
        // Add consumable powerup if it's a reset wave (every 2 waves)
        if currentWave % 2 == 0 {
            // TODO: Implement powerUpItems
            // currentWaveUpgrades.append(powerUpItems.randomElement()!)
        }
        
        // Add rare item on boss waves (every 4 waves)
        if currentWave % 4 == 0 {
            // TODO: Implement rareItems
            // currentWaveUpgrades.append(rareItems.randomElement()!)
        }
    }
} 
