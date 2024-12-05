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
    var tutorialComboLabel: SKLabelNode { comboLabel }

    var playerPosition: CGPoint { wizard.position }
    
    internal var spellIcon: SKSpriteNode!
    internal var inactiveSpellIcon: SKSpriteNode!
    
    // Add new properties for animation
    private var castingFrames: [SKTexture] = []
    private var isAnimatingCast = false
    
    private var comboLabel: SKLabelNode!
    private var comboTimerBar: SKShapeNode!
    private var comboTimerFill: SKShapeNode!
    
    // Add new property for multiplier label
    private var multiplierLabel: SKLabelNode!
    
    // Add new properties
    private var cooldownOverlay: SKShapeNode?
    private var cooldownLabel: SKLabelNode?
    
    // Add new properties for inventory
    private var inventoryContainer: SKShapeNode!
    private var inventorySlots: [SKShapeNode] = []
    private var inventorySpells: [String: Int] = [:]
    
    init(scene: SKScene, state: PlayerState) {
        self.parentScene = scene
        self.state = state
        
        // Initialize UI components
        castle = SKSpriteNode(color: .gray, size: CGSize(width: scene.size.width, height: 125))
        castleHealthBar = SKShapeNode(rectOf: CGSize(width: 200, height: 20))
        castleHealthFill = SKShapeNode(rectOf: CGSize(width: 200, height: 20))
        
        wizard = SKSpriteNode(imageNamed: "Wizard")
        
        // Initialize inventory container
        inventoryContainer = SKShapeNode(rectOf: CGSize(width: 60, height: 260))
        
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

        // Add combo binding
        state.onComboChanged = { [weak self] combo in
            self?.updateComboLabel(combo: combo)
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
        setupComboLabel()
        setupInventory()
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
        // Don't start a new animation if one is already running
        if isAnimatingCast { return }
        
        isAnimatingCast = true
        wizard.removeAllActions()
        
        // Create the animation action
        let animationDuration = 0.7 // Adjust timing to match your gif
        let animate = SKAction.animate(with: castingFrames, timePerFrame: animationDuration/Double(castingFrames.count))
        
        // Return to original state after animation
        let revert = SKAction.run { [weak self] in
            self?.wizard.texture = SKTexture(imageNamed: "Wizard") // Explicitly set back to original texture
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
        scoreLabel.zPosition = 500
        
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
        coinLabel.zPosition = 500
        
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
        waveLabel.zPosition = 500

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
        
        // Update spell icon with rarity border
        spellIcon = SKSpriteNode(imageNamed: state.getCurrentSpell().name)
        spellIcon.size = CGSize(width: 50, height: 50)
        spellIcon.position = CGPoint(x: 50, y: scene.size.height * 0.10)
        
        // Add colored border based on rarity
        let border = SKShapeNode(rectOf: spellIcon.size)
        border.strokeColor = state.getCurrentSpell().rarity.color
        border.lineWidth = 2
        spellIcon.addChild(border)
        
        scene.addChild(spellIcon)
        
        // Update inactive spell icon with rarity border
        let inactiveSpell = state.getInactiveSpell()
        inactiveSpellIcon = SKSpriteNode(imageNamed: inactiveSpell.name)
        inactiveSpellIcon.size = CGSize(width: 40, height: 40)  // Slightly smaller
        inactiveSpellIcon.position = CGPoint(x: 100, y: scene.size.height * 0.10)
        inactiveSpellIcon.alpha = 0.7  // Slightly transparent
        
        // Add colored border for inactive spell
        let inactiveBorder = SKShapeNode(rectOf: inactiveSpellIcon.size)
        inactiveBorder.strokeColor = inactiveSpell.rarity.color
        inactiveBorder.lineWidth = 2
        inactiveSpellIcon.addChild(inactiveBorder)
        
        scene.addChild(inactiveSpellIcon)
        
        // Add cooldown overlay (initially hidden)
        cooldownOverlay = SKShapeNode(rectOf: spellIcon.size)
        cooldownOverlay?.fillColor = .black
        cooldownOverlay?.strokeColor = .clear
        cooldownOverlay?.alpha = 0.6
        cooldownOverlay?.isHidden = true
        spellIcon.addChild(cooldownOverlay!)
        
        // Add cooldown label
        cooldownLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        cooldownLabel?.fontSize = 16
        cooldownLabel?.fontColor = .white
        cooldownLabel?.verticalAlignmentMode = .center
        cooldownLabel?.isHidden = true
        spellIcon.addChild(cooldownLabel!)
        
        // Start cooldown update timer
        let updateAction = SKAction.run { [weak self] in
            self?.updateCooldownDisplay()
        }
        let wait = SKAction.wait(forDuration: 0.1) // Update 10 times per second
        run(SKAction.repeatForever(SKAction.sequence([updateAction, wait])))
    }

    private func updateCooldownDisplay() {
        let currentSpell = state.getCurrentSpell()
        
        if currentSpell.isOnCooldown {
            // Show cooldown overlay and update remaining time
            cooldownOverlay?.isHidden = false
            cooldownLabel?.isHidden = false
            
            let remainingTime = currentSpell.remainingCooldown
            cooldownLabel?.text = String(format: "%.1f", remainingTime)
            
            // Update overlay height based on remaining cooldown
            let progress = CGFloat(remainingTime / currentSpell.cooldownDuration)
            cooldownOverlay?.yScale = progress
            
        } else {
            // Hide cooldown display when not on cooldown
            cooldownOverlay?.isHidden = true
            cooldownLabel?.isHidden = true
        }
        
        // Update one-time use spell count
        if currentSpell.isOneTimeUse {
            let count = state.getConsumableSpellCount(currentSpell.name)
            updateSpellCount(count)
        }
    }
    
    private func updateSpellCount(_ count: Int) {
        // Remove existing count label if any
        spellIcon.children.forEach { node in
            if node.name == "countLabel" {
                node.removeFromParent()
            }
        }
        
        // Add new count label
        let countLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        countLabel.text = "x\(count)"
        countLabel.fontSize = 16
        countLabel.fontColor = .white
        countLabel.position = CGPoint(x: spellIcon.frame.width/2 - 5, y: -spellIcon.frame.height/2 + 5)
        countLabel.horizontalAlignmentMode = .right
        countLabel.name = "countLabel"
        spellIcon.addChild(countLabel)
    }
    
    private func updateSpellIcon() {
        spellIcon.texture = SKTexture(imageNamed: state.getCurrentSpell().name)
        if let border = spellIcon.children.first as? SKShapeNode {
            border.strokeColor = state.getCurrentSpell().rarity.color
        }
        
        let inactiveSpell = state.getInactiveSpell()
        inactiveSpellIcon.texture = SKTexture(imageNamed: inactiveSpell.name)
        if let border = inactiveSpellIcon.children.first as? SKShapeNode {
            border.strokeColor = inactiveSpell.rarity.color
        }
        
        // Update cooldown and count display
        updateCooldownDisplay()
    }

    func handleSpellCycleTouch(_ touchedNode: SKNode) {
        if touchedNode.name == "cycleSpell" {
            state.cycleSpell()
            updateSpellIcon()
        }
    }

    private func setupComboLabel() {
        guard let scene = parentScene else { return }
        comboLabel = SKLabelNode(text: "Combo: 0")
        comboLabel.fontSize = 24
        comboLabel.fontColor = .yellow
        comboLabel.position = CGPoint(x: scene.size.width - 125, y: scene.size.height - 155)
        comboLabel.fontName = "AvenirNext-Bold"
        comboLabel.horizontalAlignmentMode = .left
        comboLabel.zPosition = 500
        
        let shadowLabel = SKLabelNode(text: comboLabel.text)
        shadowLabel.fontSize = comboLabel.fontSize
        shadowLabel.fontColor = .gray
        shadowLabel.position = CGPoint(x: 2, y: -2)
        shadowLabel.fontName = comboLabel.fontName
        shadowLabel.horizontalAlignmentMode = .left
        comboLabel.addChild(shadowLabel)
        
        // Setup combo timer bar
        comboTimerBar = SKShapeNode(rectOf: CGSize(width: 80, height: 4))
        comboTimerBar.fillColor = .darkGray
        comboTimerBar.strokeColor = .clear
        comboTimerBar.position = CGPoint(x: comboLabel.position.x + 40, y: comboLabel.position.y - 12)
        comboTimerBar.zPosition = 500
        
        comboTimerFill = SKShapeNode(rectOf: CGSize(width: 80, height: 4))
        comboTimerFill.fillColor = .yellow
        comboTimerFill.strokeColor = .clear
        comboTimerFill.position = comboTimerBar.position
        comboTimerFill.zPosition = 500
        
        multiplierLabel = SKLabelNode(text: "x1.0")
        multiplierLabel.fontSize = 20
        multiplierLabel.fontColor = .yellow
        multiplierLabel.position = CGPoint(x: comboLabel.position.x, y: comboTimerBar.position.y - 24)
        multiplierLabel.fontName = "AvenirNext-Bold"
        multiplierLabel.horizontalAlignmentMode = .left
        multiplierLabel.zPosition = 500
        
        let multiplierShadow = SKLabelNode(text: multiplierLabel.text)
        multiplierShadow.fontSize = multiplierLabel.fontSize
        multiplierShadow.fontColor = .gray
        multiplierShadow.position = CGPoint(x: 2, y: -2)
        multiplierShadow.fontName = multiplierLabel.fontName
        multiplierShadow.horizontalAlignmentMode = .left
        multiplierLabel.addChild(multiplierShadow)
        
        scene.addChild(comboLabel)
        scene.addChild(comboTimerBar)
        scene.addChild(comboTimerFill)
        scene.addChild(multiplierLabel)
    }

    private func updateComboLabel(combo: Int) {
        comboLabel.text = "Combo: \(combo)"
        if let shadowLabel = comboLabel.children.first as? SKLabelNode {
            shadowLabel.text = comboLabel.text
        }
        
        // Update multiplier label
        let multiplier = min(5.0, 1.0 + Double(combo - 1) * 0.1)
        multiplierLabel.text = String(format: "x%.1f", multiplier)
        if let shadowLabel = multiplierLabel.children.first as? SKLabelNode {
            shadowLabel.text = multiplierLabel.text
        }
        
        // Add visual feedback for combo
        if combo > 0 {
            let scaleUp = SKAction.scale(to: 1.2, duration: 0.1)
            let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
            comboLabel.run(SKAction.sequence([scaleUp, scaleDown]))
            multiplierLabel.run(SKAction.sequence([scaleUp, scaleDown]))
            
            // Reset and animate timer bar
            comboTimerFill.removeAllActions()
            comboTimerFill.xScale = 1.0
            
            let depleteAction = SKAction.scaleX(to: 0, duration: state.comboTimeout)
            depleteAction.timingMode = .linear
            comboTimerFill.run(depleteAction)
        } else {
            // Reset timer bar and multiplier when combo ends
            comboTimerFill.removeAllActions()
            comboTimerFill.xScale = 0
            multiplierLabel.text = "x1.0"
            if let shadowLabel = multiplierLabel.children.first as? SKLabelNode {
                shadowLabel.text = multiplierLabel.text
            }
        }
    }

    public func createDamageNumber(damage: Int, at position: CGPoint, isCritical: Bool = false, isCastleDamage: Bool = false) {
        guard let scene = parentScene else { return }
        
        // Create the damage label
        let damageLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        damageLabel.text = "\(damage)"
        damageLabel.fontSize = isCritical ? 28 : 24
        damageLabel.fontColor = isCastleDamage ? .red : .white
        damageLabel.position = position
        damageLabel.zPosition = 100
        
        // Add stroke effect for better visibility
        let strokeLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        strokeLabel.text = damageLabel.text
        strokeLabel.fontSize = damageLabel.fontSize
        strokeLabel.fontColor = .black  // Always black stroke for better visibility
        strokeLabel.position = CGPoint(x: 1, y: -1)
        strokeLabel.zPosition = 99
        damageLabel.addChild(strokeLabel)
        
        scene.addChild(damageLabel)
        
        // Animate the damage number
        let moveUp = SKAction.moveBy(x: 0, y: 50, duration: 0.8)
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let remove = SKAction.removeFromParent()
        
        // Add a slight random horizontal movement
        let randomX = CGFloat.random(in: -20...20)
        let moveHorizontal = SKAction.moveBy(x: randomX, y: 0, duration: 0.8)
        
        let group = SKAction.group([moveUp, moveHorizontal])
        let sequence = SKAction.sequence([group, fadeOut, remove])
        
        damageLabel.run(sequence)
    }

    func shakeScreen(intensity: CGFloat = 6.0, duration: TimeInterval = 0.3) {
        guard let scene = parentScene else { return }
        
        // Create a container node for all scene contents if it doesn't exist
        let worldNode = scene.childNode(withName: "worldNode") ?? {
            let node = SKNode()
            node.name = "worldNode"
            // Move all existing children to the world node
            while let child = scene.children.first {
                child.removeFromParent()
                node.addChild(child)
            }
            scene.addChild(node)
            return node
        }()
        
        // Create shake actions
        let shakeCount = 6 // Number of shakes
        var actions: [SKAction] = []
        
        for _ in 0..<shakeCount {
            let dx = CGFloat.random(in: -intensity...intensity)
            let dy = CGFloat.random(in: -intensity...intensity)
            actions.append(SKAction.moveBy(x: dx, y: dy, duration: duration/TimeInterval(shakeCount*2)))
        }
        
        // Add final action to return to original position
        actions.append(SKAction.move(to: .zero, duration: duration/TimeInterval(shakeCount*2)))
        
        // Run the sequence
        worldNode.run(SKAction.sequence(actions))
    }

    private func setupInventory() {
        guard let scene = parentScene else { return }
        
        // Create container for inventory slots
        inventoryContainer = SKShapeNode(rectOf: CGSize(width: 60, height: 260))
        inventoryContainer.fillColor = .white.withAlphaComponent(0.3)
        inventoryContainer.strokeColor = .black
        inventoryContainer.position = CGPoint(x: 40, y: scene.size.height - 150)
        inventoryContainer.zPosition = 100
        scene.addChild(inventoryContainer)  // Add to scene, not self
        
        // Create 4 inventory slots
        let slotSize = CGSize(width: 50, height: 50)
        let spacing: CGFloat = 10
        
        for i in 0..<4 {
            let slot = SKShapeNode(rectOf: slotSize)
            slot.fillColor = .gray.withAlphaComponent(0.5)
            slot.strokeColor = .black
            slot.position = CGPoint(
                x: 0,
                y: 95 - CGFloat(i) * (slotSize.height + spacing)
            )
            slot.name = "inventorySlot\(i)"
            slot.zPosition = 101
            inventoryContainer.addChild(slot)
            inventorySlots.append(slot)
        }
    }

    // Change access level to internal or public
    func updateInventoryDisplay() {
        // Clear existing spell displays
        inventorySlots.forEach { slot in
            slot.children.forEach { $0.removeFromParent() }
        }
        
        // Display current inventory
        var slotIndex = 0
        for (spellName, count) in state.consumableSpells {
            guard slotIndex < inventorySlots.count else { break }
            
            let slot = inventorySlots[slotIndex]
            
            // Add spell icon
            let spellIcon = SKSpriteNode(imageNamed: spellName)
            spellIcon.size = CGSize(width: 40, height: 40)
            spellIcon.position = .zero
            spellIcon.name = "spell_\(spellName)"
            slot.addChild(spellIcon)
            
            // Add count label
            let countLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
            countLabel.text = "x\(count)"
            countLabel.fontSize = 16
            countLabel.fontColor = .white
            countLabel.position = CGPoint(x: 15, y: -15)
            slot.addChild(countLabel)
            
            slotIndex += 1
        }
    }

    public func addSpellToInventory(_ spellName: String) {
        state.addSpellToInventory(spellName)
        updateInventoryDisplay()
    }

    public func handleSpellSelection(at position: CGPoint) {
        for slot in inventorySlots {
            let slotPosition = slot.convert(position, from: parentScene!)
            if slot.contains(slotPosition),
               let spellNode = slot.children.first(where: { $0.name?.hasPrefix("spell_") ?? false }),
               let spellName = spellNode.name?.dropFirst(6) { // Remove "spell_" prefix
                
                // Use the spell
                if let count = state.consumableSpells[String(spellName)], count > 0 {
                    state.consumableSpells[String(spellName)] = count - 1
                    if count - 1 <= 0 {
                        state.consumableSpells.removeValue(forKey: String(spellName))
                    }
                    // Trigger spell use in game logic
                    state.useInventorySpell(String(spellName))
                    updateInventoryDisplay()
                }
            }
        }
    }
} 
