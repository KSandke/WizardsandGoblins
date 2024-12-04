import SpriteKit

class PlayerView: SKNode {
    // UI Components
    private var castle: SKSpriteNode
    private var castleHealthBar: SKShapeNode
    private var castleHealthFill: SKShapeNode
    
    private var wizard: SKSpriteNode
    private var chargeSegments: [SKShapeNode] = []
    
    private var scoreLabel: SKLabelNode!
    private var coinLabel: SKLabelNode!
    private var waveLabel: SKLabelNode!
    
    private weak var parentScene: SKScene?
    private var state: PlayerState
    // Add public getters for tutorial access
    var tutorialCastleHealthBar: SKShapeNode { castleHealthBar }
    var tutorialPlayerCharges: [SKShapeNode] { chargeSegments }
    var tutorialScoreLabel: SKLabelNode { scoreLabel }
    var tutorialWaveLabel: SKLabelNode { waveLabel }
    var tutorialCoinLabel: SKLabelNode { coinLabel }
    var tutorialChargeSegments: [SKShapeNode] { chargeSegments }

    var playerPosition: CGPoint { wizard.position }
    
    internal var spellIcon: SKSpriteNode!
    
    var isInventoryOpen = false
    private var inventoryButton: SKSpriteNode!
    private var inventoryView: SKNode?
    
    // Add new properties for animation
    private var castingFrames: [SKTexture] = []
    private var isAnimatingCast = false
    
    init(scene: SKScene, state: PlayerState) {
        self.parentScene = scene
        self.state = state
        
        // Initialize UI components
        castle = SKSpriteNode(color: .gray, size: CGSize(width: scene.size.width, height: 125))
        castleHealthBar = SKShapeNode(rectOf: CGSize(width: 200, height: 20))
        castleHealthFill = SKShapeNode(rectOf: CGSize(width: 200, height: 20))
        
        wizard = SKSpriteNode(imageNamed: "Wizard")
        
        super.init()
        
        setupBindings()
        setupUI()
    }
    
    // Add required initializer
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupBindings() {
        // Bind state changes to UI updates
        state.onCastleHealthChanged = { [weak self] health in
            self?.updateCastleHealthBar(health: health)
        }
        
        state.onPlayerChargesChanged = { [weak self] charges in
            self?.updateCharges(charges: charges)
        }

        state.onScoreChanged = { [weak self] score in
            self?.updateScoreLabel(score: score)
        }

        state.onCoinsChanged = { [weak self] coins in
            self?.updateCoinsLabel(coins: coins)
        }

        // Add new binding for max charges
        state.onMaxSpellChargesChanged = { [weak self] maxCharges in
            self?.updateMaxCharges(maxCharges: maxCharges)
        }

        // Add this with the other bindings
        state.onSpellChanged = { [weak self] spell in
            self?.updateSpellIcon()
        }
    }
    
    private func setupUI() {
        setupCastle()
        setupWizards()
        setupManaBars()
        setupScoreLabel()
        setupCoinsLabel()
        setupWaveLabel()
        setupSpellIcons()
        setupInventoryButton()
    }
    
    private func setupCastle() {
        guard let scene = parentScene else { return }
        
        castle.position = CGPoint(x: scene.size.width/2, y: 60)
        scene.addChild(castle)
        
        castleHealthBar.fillColor = .gray
        castleHealthBar.strokeColor = .black
        castleHealthBar.position = CGPoint(x: scene.size.width/2, y: 25)
        scene.addChild(castleHealthBar)
        
        castleHealthFill.fillColor = .red
        castleHealthFill.strokeColor = .clear
        castleHealthFill.position = castleHealthBar.position
        scene.addChild(castleHealthFill)


        
        updateCastleHealthBar(health: state.castleHealth)
    }
    
    private func setupWizards() {
        guard let scene = parentScene else { return }
        
        // Load casting animation frames
        loadCastingAnimation()
        
        wizard.size = CGSize(width: 125, height: 125)
        wizard.position = CGPoint(x: scene.size.width * 0.5, y: 100)
        scene.addChild(wizard)
    }
    
    private func loadCastingAnimation() {
        // Load all frames from your gif/sprite sheet
        // Adjust the frame count and names based on your actual assets
        let frameCount = 12 // Update this to match your animation frame count
        castingFrames = (1...frameCount).map { frameNumber in
            SKTexture(imageNamed: "WizardCast\(frameNumber)")
        }
    }
    
    func animateSpellCast() {
        // Remove any existing animations
        wizard.removeAllActions()
        
        // Store the original texture to revert back to
        let originalTexture = wizard.texture
        
        // Create the animation action
        let animationDuration = 0.7 // Adjust timing to match your gif
        let animate = SKAction.animate(with: castingFrames, timePerFrame: animationDuration/Double(castingFrames.count))
        
        // Return to original state after animation
        let revert = SKAction.run { [weak self] in
            self?.wizard.texture = originalTexture
            self?.isAnimatingCast = false
        }
        
        // Run the complete sequence
        wizard.run(SKAction.sequence([animate, revert]))
    }
    
    private func setupManaBars() {
        setupChargeSegments(segments: &chargeSegments, atPosition: wizard.position)
        updateCharges(charges: state.spellCharges)
    }
    
    private func setupChargeSegments(segments: inout [SKShapeNode], atPosition pos: CGPoint) {
        guard let scene = parentScene else { return }
        
        // Calculate maximum available width
        let maxAvailableWidth = scene.size.width * 0.3  // 30% of screen width
        
        // Base segment sizes
        let baseSegmentWidth: CGFloat = 18
        let baseSegmentHeight: CGFloat = 10
        let baseSpacing: CGFloat = 2
        
        // Calculate total width needed for base sizes
        let baseWidth = (baseSegmentWidth * CGFloat(state.maxSpellCharges)) + 
                       (baseSpacing * CGFloat(state.maxSpellCharges - 1))
        
        // Calculate scale factor if needed
        let scaleFactor = min(1.0, maxAvailableWidth / baseWidth)
        
        // Apply scale to measurements
        let segmentWidth = baseSegmentWidth * scaleFactor
        let segmentHeight = baseSegmentHeight * scaleFactor
        let spacing = baseSpacing * scaleFactor
        
        // Calculate total width with scaled measurements
        let totalWidth = (segmentWidth * CGFloat(state.maxSpellCharges)) + 
                        (spacing * CGFloat(state.maxSpellCharges - 1))
        
        // Center the segments below the wizard
        let startX = pos.x - (totalWidth / 2)
        
        for i in 0..<state.maxSpellCharges {
            let segment = SKShapeNode(rectOf: CGSize(width: segmentWidth, height: segmentHeight))
            segment.fillColor = .blue
            segment.strokeColor = .black
            segment.position = CGPoint(
                x: startX + (CGFloat(i) * (segmentWidth + spacing)) + (segmentWidth / 2),
                y: pos.y - 50
            )
            scene.addChild(segment)
            segments.append(segment)
        }
    }
    
    private func updateCharges(charges: Int) {
        let previousCharges = chargeSegments.filter { $0.fillColor == .blue }.count
        
        if charges > previousCharges {
            for (index, segment) in chargeSegments.enumerated() {
                if index < charges {
                    if index >= previousCharges {
                        animateChargeSegment(segment)
                    } else {
                        segment.fillColor = .blue
                    }
                } else {
                    segment.fillColor = .gray
                }
            }
        } else {
            for (index, segment) in chargeSegments.enumerated() {
                segment.fillColor = index < charges ? .blue : .gray
            }
        }
    }

    private func animateChargeSegment(_ segment: SKShapeNode) {
        // Create flash animation sequence
        let flashDuration = 0.15
        
        // Start with white flash
        let flashWhite = SKAction.run { segment.fillColor = .white }
        let waitFlash = SKAction.wait(forDuration: flashDuration)
        
        // Then transition to bright blue
        let flashBrightBlue = SKAction.run { segment.fillColor = SKColor(red: 0.3, green: 0.7, blue: 1.0, alpha: 1.0) }
        let waitBright = SKAction.wait(forDuration: flashDuration)
        
        // Finally settle to regular blue
        let setNormalBlue = SKAction.run { segment.fillColor = .blue }
        
        // Combine into sequence
        let sequence = SKAction.sequence([
            flashWhite,
            waitFlash,
            flashBrightBlue,
            waitBright,
            setNormalBlue
        ])
        
        // Run the animation
        segment.run(sequence)
    }

    private func setupScoreLabel() {
        guard let scene = parentScene else { return }
        scoreLabel = SKLabelNode(text: "Score: \(state.score)")
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = .black
        scoreLabel.position = CGPoint(x: scene.size.width - 125, y: scene.size.height - 65)
        scoreLabel.fontName = "AvenirNext-Bold"
        scoreLabel.horizontalAlignmentMode = .left
        
        let shadowLabel = SKLabelNode(text: scoreLabel.text)
        shadowLabel.fontSize = scoreLabel.fontSize
        shadowLabel.fontColor = .gray
        shadowLabel.position = CGPoint(x: 2, y: -2)
        shadowLabel.fontName = scoreLabel.fontName
        shadowLabel.horizontalAlignmentMode = .left
        scoreLabel.addChild(shadowLabel)
        
        scene.addChild(scoreLabel)
    }

    private func setupCoinsLabel() {
        guard let scene = parentScene else { return }
        coinLabel = SKLabelNode(text: "Coins: \(state.coins)")
        coinLabel.fontSize = 24
        coinLabel.fontColor = .black
        coinLabel.position = CGPoint(x: scene.size.width - 125, y: scene.size.height - 95)
        coinLabel.fontName = "AvenirNext-Bold"
        coinLabel.horizontalAlignmentMode = .left
        
        let shadowLabel = SKLabelNode(text: coinLabel.text)
        shadowLabel.fontSize = coinLabel.fontSize
        shadowLabel.fontColor = .gray
        shadowLabel.position = CGPoint(x: 2, y: -2)
        shadowLabel.fontName = coinLabel.fontName
        shadowLabel.horizontalAlignmentMode = .left
        coinLabel.addChild(shadowLabel)
        
        scene.addChild(coinLabel)
    }

    private func setupWaveLabel() {
        guard let scene = parentScene else { return }
        waveLabel = SKLabelNode(text: "Wave: 1")
        waveLabel.fontSize = 24
        waveLabel.fontColor = .black
        waveLabel.position = CGPoint(x: scene.size.width - 125, y: scene.size.height - 125)
        waveLabel.fontName = "AvenirNext-Bold"
        waveLabel.horizontalAlignmentMode = .left

        // Add a shadow effect
        let shadowLabel = SKLabelNode(text: waveLabel.text)
        shadowLabel.fontSize = waveLabel.fontSize
        shadowLabel.fontColor = .gray
        shadowLabel.position = CGPoint(x: 2, y: -2)
        shadowLabel.fontName = waveLabel.fontName
        shadowLabel.horizontalAlignmentMode = .left
        waveLabel.addChild(shadowLabel)

        scene.addChild(waveLabel)
    }

    private func updateCastleHealthBar(health: CGFloat) {
        castleHealthFill.xScale = health / state.maxCastleHealth
    }
    
    private func updateScoreLabel(score: Int) {
        scoreLabel.text = "Score: \(score)"
        if let shadowLabel = scoreLabel.children.first as? SKLabelNode {
            shadowLabel.text = scoreLabel.text
        }
    }

    private func updateCoinsLabel(coins: Int) {
        coinLabel.text = "Coins: \(coins)"
        if let shadowLabel = coinLabel.children.first as? SKLabelNode {
            shadowLabel.text = coinLabel.text
        }
    }

    func updateWaveLabel(wave: Int) {
        waveLabel.text = "Wave: \(wave)"
        if let shadowLabel = waveLabel.children.first as? SKLabelNode {
            shadowLabel.text = waveLabel.text
        }
    }
    
    // Public accessors for positions
    var castlePosition: CGPoint {
        castle.position
    }


    // Add new function to handle max charges change
    private func updateMaxCharges(maxCharges: Int) {
        // Remove existing charge segments
        chargeSegments.forEach { $0.removeFromParent() }
        chargeSegments.removeAll()
        
        // Setup new charge segments
        setupChargeSegments(segments: &chargeSegments, atPosition: wizard.position)
        
        // Update visual state
        updateCharges(charges: state.spellCharges)
    }

    private func setupSpellIcons() {
        guard let scene = parentScene else { return }
        
        spellIcon = SKSpriteNode(imageNamed: state.getCurrentSpell().name)
        spellIcon.size = CGSize(width: 40, height: 40)
        spellIcon.position = CGPoint(x: wizard.position.x + 50, y: wizard.position.y)
        spellIcon.name = "cycleSpell"
        
        let spellLabel = SKLabelNode(fontNamed: "HelveticaNeue")
        spellLabel.fontSize = 12
        spellLabel.text = state.getCurrentSpell().name
        spellLabel.position = CGPoint(x: 0, y: 25)
        spellIcon.addChild(spellLabel)
        
        scene.addChild(spellIcon)
    }

    func handleSpellCycleTouch(_ touchedNode: SKNode) {
        if touchedNode.name == "cycleSpell" {
            state.cycleSpell()
            updateSpellIcon()
        }
    }

    private func updateSpellIcon() {
        let nextSpell = state.getCurrentSpell()
        spellIcon.texture = SKTexture(imageNamed: nextSpell.name)
        if let spellLabel = spellIcon.children.first as? SKLabelNode {
            spellLabel.text = nextSpell.name
        }
        
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.1)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
        spellIcon.run(SKAction.sequence([scaleUp, scaleDown]))
    }

    private func setupInventoryButton() {
        guard let scene = parentScene else { 
            print("No parent scene available for inventory button")
            return 
        }
        
        inventoryButton = SKSpriteNode(imageNamed: "inventory_icon")
        inventoryButton.size = CGSize(width: 40, height: 40)
        inventoryButton.position = CGPoint(x: 40, y: scene.size.height - 40)
        inventoryButton.name = "inventoryButton"
        inventoryButton.zPosition = 100
        scene.addChild(inventoryButton)
        
        print("Inventory button setup at position: \(inventoryButton.position)")
    }

    func toggleInventory() {
        print("toggleInventory called")  // Debug print
        
        if isInventoryOpen {
            print("Closing inventory")
            inventoryView?.removeFromParent()
            inventoryView = nil
        } else {
            print("Opening inventory")
            createInventoryView()
        }
        
        isInventoryOpen = !isInventoryOpen
        print("Inventory is now \(isInventoryOpen ? "open" : "closed")")
    }

    private func createInventoryView() {
        print("Creating inventory view")
        guard let scene = parentScene else {
            print("No parent scene found")
            return
        }
        
        // Create inventory container
        inventoryView = SKNode()
        
        // Calculate size that fits within screen
        let padding: CGFloat = 20
        let inventoryWidth = min(300, scene.size.width - padding * 2)
        let inventoryHeight = min(400, scene.size.height - padding * 2)
        
        // Create background
        let background = SKShapeNode(rectOf: CGSize(width: inventoryWidth, height: inventoryHeight))
        background.fillColor = .black
        background.strokeColor = .white
        background.alpha = 0.9
        
        // Center the inventory on screen
        let centerX = scene.size.width/2
        let centerY = scene.size.height/2
        inventoryView?.position = CGPoint(x: centerX, y: centerY)
        
        // Add background first
        inventoryView?.addChild(background)
        
        // Add title
        let titleLabel = SKLabelNode(text: "Spell Inventory")
        titleLabel.fontName = "HelveticaNeue-Bold"
        titleLabel.fontSize = 24
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: 0, y: inventoryHeight/2 - 40)
        inventoryView?.addChild(titleLabel)
        
        // Add close button with better touch area
        let closeButtonRadius: CGFloat = 15
        let closeButton = SKShapeNode(circleOfRadius: closeButtonRadius)
        closeButton.fillColor = .red
        closeButton.strokeColor = .white
        closeButton.position = CGPoint(x: inventoryWidth/2 - 30, y: inventoryHeight/2 - 30)
        closeButton.name = "closeInventory"
        closeButton.zPosition = 101  // Make sure it's above other inventory elements
        
        // Add an X symbol to the close button
        let xSymbol = SKLabelNode(text: "×")
        xSymbol.fontSize = 20
        xSymbol.fontName = "HelveticaNeue-Bold"
        xSymbol.fontColor = .white
        xSymbol.verticalAlignmentMode = .center
        xSymbol.horizontalAlignmentMode = .center
        xSymbol.position = CGPoint(x: 0, y: 0)
        closeButton.addChild(xSymbol)
        
        inventoryView?.addChild(closeButton)
        
        // Display spells with adjusted positioning
        displaySpellInventory(containerSize: CGSize(width: inventoryWidth, height: inventoryHeight))
        
        scene.addChild(inventoryView!)
        print("Inventory view added to scene")
    }

    private func displaySpellInventory(containerSize: CGSize) {
        guard let gameScene = parentScene as? GameScene else { return }
        
        let itemsPerRow = 3
        let itemSize: CGFloat = min(60, (containerSize.width - 80) / CGFloat(itemsPerRow))
        let padding: CGFloat = 20
        
        let startX = -((itemSize + padding) * CGFloat(itemsPerRow-1)/2)
        let startY = containerSize.height/2 - 100
        
        var currentRow = 0
        var currentCol = 0
        
        for (spellName, quantity) in gameScene.playerState.consumableSpells where quantity > 0 {
            let x = startX + CGFloat(currentCol) * (itemSize + padding)
            let y = startY - CGFloat(currentRow) * (itemSize + padding)
            
            // Create container node for spell
            let spellContainer = SKNode()
            spellContainer.position = CGPoint(x: x, y: y)
            spellContainer.name = "spell_\(spellName)"  // Add identifier for touch detection
            
            // Spell icon
            let spellIcon = SKSpriteNode(imageNamed: spellName)
            spellIcon.size = CGSize(width: itemSize, height: itemSize)
            spellContainer.addChild(spellIcon)
            
            // Add selection background (initially invisible)
            let selectionBg = SKShapeNode(rectOf: CGSize(width: itemSize + 10, height: itemSize + 10))
            selectionBg.fillColor = .clear
            selectionBg.strokeColor = .yellow
            selectionBg.lineWidth = 2
            selectionBg.name = "selection_\(spellName)"
            selectionBg.alpha = 0
            spellContainer.addChild(selectionBg)
            
            // Quantity label
            let quantityLabel = SKLabelNode(text: "x\(quantity)")
            quantityLabel.fontSize = 16
            quantityLabel.fontName = "HelveticaNeue-Bold"
            quantityLabel.fontColor = .white
            quantityLabel.position = CGPoint(x: itemSize/2 - 10, y: -itemSize/2 + 5)
            spellContainer.addChild(quantityLabel)
            
            inventoryView?.addChild(spellContainer)
            
            currentCol += 1
            if currentCol >= itemsPerRow {
                currentCol = 0
                currentRow += 1
            }
        }
    }

    // Add method to check if a point is within the inventory button
    func isInventoryButtonTouched(at point: CGPoint) -> Bool {
        return inventoryButton.contains(point)
    }

    // Add method to handle spell selection
    func handleSpellSelection(at point: CGPoint) {
        guard let inventoryView = inventoryView else { return }
        
        // Convert point to inventory view's coordinate space
        let localPoint = inventoryView.convert(point, from: parentScene!)
        
        if let touchedNode = inventoryView.nodes(at: localPoint).first,
           let spellName = touchedNode.parent?.name,
           spellName.hasPrefix("spell_") {
            
            let actualSpellName = String(spellName.dropFirst(6)) // Remove "spell_" prefix
            
            // Show selection options
            showSpellSelectionOptions(spellName: actualSpellName, at: touchedNode.parent!.position)
        }
    }

    private func showSpellSelectionOptions(spellName: String, at position: CGPoint) {
        let optionsMenu = SKNode()
        
        let buttonSize = CGSize(width: 120, height: 40)
        let selectButton = SKShapeNode(rectOf: buttonSize)
        selectButton.fillColor = .blue
        selectButton.strokeColor = .white
        selectButton.position = CGPoint(x: 0, y: buttonSize.height/2)
        selectButton.name = "select_\(spellName)"
        
        let selectLabel = SKLabelNode(text: "Select Spell")
        selectLabel.fontSize = 14
        selectLabel.fontColor = .white
        selectLabel.verticalAlignmentMode = .center
        selectButton.addChild(selectLabel)
        
        optionsMenu.addChild(selectButton)
        optionsMenu.position = position
        
        inventoryView?.addChild(optionsMenu)
    }

    // Add method to handle spell assignment
    func assignSpell(_ spellName: String, isPrimary: Bool = true) {
        guard let gameScene = parentScene as? GameScene else { return }
        gameScene.playerState.setSpell(spell: createSpell(named: spellName))
        toggleInventory()
    }

    // Helper method to create spell instance
    private func createSpell(named spellName: String) -> Spell {
        // Add cases for each spell type
        switch spellName {
        case "AC130": return AC130Spell()
        case "TacticalNuke": return TacticalNukeSpell()
        case "PredatorMissile": return PredatorMissileSpell()
        // Add cases for other spells...
        default: return FireballSpell() // Default fallback
        }
    }

} 
