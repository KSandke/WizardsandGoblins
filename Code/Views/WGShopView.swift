import SpriteKit

struct ShopItem {
    let name: String
    let description: String
    let price: Int
    let icon: String  // Name of image asset
    let effect: (PlayerState) -> Void
    
    // Predefined shop items
    static let items: [ShopItem] = [
        ShopItem(
            name: "Max Health +20",
            description: "Increase maximum health by 20",
            price: 5,
            icon: "health_upgrade",
            effect: { state in
                state.maxHealth += 20
            }
        ),
        ShopItem(
            name: "Max Spell Charges +1",
            description: "Increase spell charges by 1",
            price: 10,
            icon: "SpellCharges",
            effect: { state in
                state.maxSpellCharges += 1
                state.playerOneSpellCharges += 1
                state.playerTwoSpellCharges += 1
            }
        ),
        ShopItem(
            name: "Spell Power +10%",
            description: "Increase spell damage",
            price: 5,
            icon: "power_upgrade",
            effect: { state in
                state.spellPowerMultiplier *= 1.1
            }
        )
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
        
        // Create coin display with larger font and icon
        statsLabel.fontSize = 32  // Increased from 24
        statsLabel.fontColor = .yellow  // Make coins yellow
        statsLabel.position = CGPoint(x: size.width/2 + 25, y: size.height - 120)  // Shifted right to make room for icon
        addChild(statsLabel)
        
        // Add coin icon
        let coinIcon = SKSpriteNode(imageNamed: "coin_icon")  // Make sure you have this asset
        coinIcon.size = CGSize(width: 40, height: 40)  // Adjust size as needed
        coinIcon.position = CGPoint(x: statsLabel.position.x - 100, y: statsLabel.position.y)
        addChild(coinIcon)
        
        // Create grid of item buttons
        let gridWidth = 2
        let gridHeight = 2
        let buttonWidth: CGFloat = 200
        let buttonHeight: CGFloat = 200
        let padding: CGFloat = 20
        
        let startX = size.width/2 - CGFloat(gridWidth-1) * (buttonWidth + padding)/2
        let startY = size.height/2 + CGFloat(gridHeight-1) * (buttonHeight + padding)/2
        
        for (index, item) in ShopItem.items.enumerated() {
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
               let item = ShopItem.items.first(where: { "itemButton_\($0.name)" == buttonName }) {
                purchaseItem(item)
                return
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
} 