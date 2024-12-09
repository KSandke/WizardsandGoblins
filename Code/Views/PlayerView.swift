import Foundation
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
    internal var inactiveSpellIconLeft: SKSpriteNode!
    internal var inactiveSpellIconRight: SKSpriteNode!
    
    // Add new properties for animation
    private var castingFrames: [SKTexture] = []
    private var isAnimatingCast = false
    
    private var comboLabel: SKLabelNode!
    private var comboTimerBar: SKShapeNode!
    private var comboTimerFill: SKShapeNode!
    
    // Add new property for multiplier label
    private var multiplierLabel: SKLabelNode!
    
    // Special ability UI
    private var specialButtons: [SKSpriteNode] = []
    private var specialCooldownOverlays: [SKShapeNode] = []
    
    private var lastSpecialTapTime: TimeInterval = 0
    
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
        setupSpecialButton()
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

        // Add binding for temporary spell changes
        state.onTemporarySpellChanged = { [weak self] spell in
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
        setupComboLabel()
        setupInventoryButton()
    }
    
    private func setupCastle() {
        guard let scene = parentScene else { return }
        
        castle.position = CGPoint(x: scene.size.width/2, y: 60)
        scene.addChild(castle)
        
        castleHealthBar.fillColor = .gray
        castleHealthBar.strokeColor = .black
        castleHealthBar.position = CGPoint(x: 120, y: 25)
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
        wizard.position = CGPoint(x: 80, y: 100)
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
        
        let maxAvailableWidth = scene.size.width * 0.3
        let baseSegmentWidth: CGFloat = 18
        let baseSegmentHeight: CGFloat = 10
        let baseSpacing: CGFloat = 2
        
        // Break down the complex width calculations
        let totalSegmentWidth = baseSegmentWidth * CGFloat(state.maxSpellCharges)
        let totalSpacingWidth = baseSpacing * CGFloat(state.maxSpellCharges - 1)
        let baseWidth = totalSegmentWidth + totalSpacingWidth
        
        let scaleFactor = min(1.0, maxAvailableWidth / baseWidth)
        
        let segmentWidth = baseSegmentWidth * scaleFactor
        let segmentHeight = baseSegmentHeight * scaleFactor
        let spacing = baseSpacing * scaleFactor
        
        // Calculate total width separately
        let scaledSegmentWidth = segmentWidth * CGFloat(state.maxSpellCharges)
        let scaledSpacingWidth = spacing * CGFloat(state.maxSpellCharges - 1)
        let totalWidth = scaledSegmentWidth + scaledSpacingWidth
        
        let startX = 20
        
        for i in 0..<state.maxSpellCharges {
            let segment = SKShapeNode(rectOf: CGSize(width: segmentWidth, height: segmentHeight))
            segment.fillColor = .blue
            segment.strokeColor = .black
            
            // Calculate x position in steps
            let offset = CGFloat(i) * (segmentWidth + spacing)
            let halfSegmentWidth = segmentWidth / 2
            let xPosition = CGFloat(startX) + offset + halfSegmentWidth
            
            segment.position = CGPoint(
                x: xPosition,
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
        scoreLabel.position = CGPoint(x: 10, y: scene.size.height - 65)
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
        coinLabel.position = CGPoint(x: 10, y: scene.size.height - 95)
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
        waveLabel.position = CGPoint(x: scene.size.width - 125, y: scene.size.height - 65)
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
        
        // Active spell icon setup
        spellIcon = SKSpriteNode(imageNamed: state.getCurrentSpell().name)
        spellIcon.size = CGSize(width: 45, height: 45)
        spellIcon.position = CGPoint(x: wizard.position.x + 130, y: wizard.position.y - 10)
        spellIcon.name = "cycleSpell"
        
        let spellLabel = SKLabelNode(fontNamed: "HelveticaNeue")
        spellLabel.fontSize = 12
        spellLabel.text = state.getCurrentSpell().name
        spellLabel.position = CGPoint(x: 0, y: 25)
        spellIcon.addChild(spellLabel)
        
        // Create a white border for active spell
        let borderBox = SKShapeNode(rectOf: CGSize(width: 51, height: 51))
        borderBox.strokeColor = .white
        borderBox.lineWidth = 2
        borderBox.fillColor = .clear
        borderBox.position = spellIcon.position
        scene.addChild(borderBox)
        
        // Setup inactive spell icons
        let inactiveSize = CGSize(width: 30, height: 30)
        let spacing: CGFloat = 40
        let baseX = spellIcon.position.x
        
        // Setup left inactive spell
        inactiveSpellIconLeft = SKSpriteNode(imageNamed: "EmptySpell")
        inactiveSpellIconLeft.size = inactiveSize
        inactiveSpellIconLeft.alpha = 0.6
        inactiveSpellIconLeft.position = CGPoint(x: baseX - spacing, y: wizard.position.y)
        inactiveSpellIconLeft.name = "inactiveSpell_left"
        
        let leftBorder = SKShapeNode(rectOf: CGSize(width: inactiveSize.width + 4, height: inactiveSize.height + 4))
        leftBorder.strokeColor = .white
        leftBorder.lineWidth = 1
        leftBorder.position = inactiveSpellIconLeft.position
        leftBorder.name = "inactiveSpellBorder_left"
        leftBorder.alpha = 0.6
        
        // Setup right inactive spell
        inactiveSpellIconRight = SKSpriteNode(imageNamed: "EmptySpell")
        inactiveSpellIconRight.size = inactiveSize
        inactiveSpellIconRight.alpha = 0.6
        inactiveSpellIconRight.position = CGPoint(x: baseX + spacing, y: wizard.position.y)
        inactiveSpellIconRight.name = "inactiveSpell_right"
        
        let rightBorder = SKShapeNode(rectOf: CGSize(width: inactiveSize.width + 4, height: inactiveSize.height + 4))
        rightBorder.strokeColor = .white
        rightBorder.lineWidth = 1
        rightBorder.position = inactiveSpellIconRight.position
        rightBorder.name = "inactiveSpellBorder_right"
        rightBorder.alpha = 0.6
        
        scene.addChild(leftBorder)
        scene.addChild(rightBorder)
        scene.addChild(inactiveSpellIconLeft)
        scene.addChild(inactiveSpellIconRight)
        scene.addChild(spellIcon)
        
        updateSpellIcon() // Initial update of all spell icons
    }

    func handleSpellCycleTouch(_ touchedNode: SKNode) {
        if touchedNode.name == "cycleSpell" {
            state.cycleSpell()
            updateSpellIcon()
        }
    }

    private func updateSpellIcon() {
        // Update main spell icon
        let currentSpell = state.getCurrentSpell()
        spellIcon.texture = SKTexture(imageNamed: currentSpell.name)
        if let spellLabel = spellIcon.children.first as? SKLabelNode {
            spellLabel.text = currentSpell.name
        }
        
        // Update inactive spell icons
        //let inactiveSpells = state.getInactiveSpells()
        
        // Update left inactive spell (previous spell)
        let leftSpell = state.getPreviousSpell()
        inactiveSpellIconLeft.texture = SKTexture(imageNamed: leftSpell.name)
        if let border = scene?.childNode(withName: "inactiveSpellBorder_left") as? SKShapeNode {
            border.strokeColor = leftSpell.rarity.color
        }
        
        // Update right inactive spell (next spell)
        let rightSpell = state.getNextSpell()
        inactiveSpellIconRight.texture = SKTexture(imageNamed: rightSpell.name)
        if let border = scene?.childNode(withName: "inactiveSpellBorder_right") as? SKShapeNode {
            border.strokeColor = rightSpell.rarity.color
        }
        
        // Animate active spell icon update
        spellIcon.run(SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.1),
            SKAction.scale(to: 1.0, duration: 0.1)
        ]))
    }

    private func setupComboLabel() {
        guard let scene = parentScene else { return }
        comboLabel = SKLabelNode(text: "Combo: 0")
        comboLabel.fontSize = 24
        comboLabel.fontColor = .yellow
        comboLabel.position = CGPoint(x: scene.size.width - 125, y: scene.size.height - 95)
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
    
    private func setupInventoryButton() {
        guard let scene = parentScene else { return }
        
        // Create inventory button
        inventoryButton = SKSpriteNode(imageNamed: "inventory_icon") // Add this image to assets
        inventoryButton.size = CGSize(width: 40, height: 40)
        inventoryButton.position = CGPoint(x: scene.size.width - 50, y: 50)
        inventoryButton.name = "inventoryButton"
        scene.addChild(inventoryButton)
    }
    
    func showInventoryDisplay() {
        guard let scene = parentScene else { return }
        
        // Remove existing inventory display if any
        inventoryDisplay?.removeFromParent()
        
        // Create inventory display container
        let container = SKNode()
        
        // Create semi-transparent background
        let background = SKShapeNode(rectOf: CGSize(width: scene.size.width * 0.8, height: scene.size.height * 0.8))
        background.fillColor = .black.withAlphaComponent(0.8)
        background.strokeColor = .white
        background.position = CGPoint(x: scene.size.width/2, y: scene.size.height/2)
        background.name = "inventoryBackground"  // Assign a name for debugging
        container.addChild(background)
        
        // Add title
        let title = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        title.text = "Spell Inventory"
        title.fontSize = 32
        title.fontColor = .white
        title.position = CGPoint(x: scene.size.width/2, y: scene.size.height * 0.8)
        title.name = "inventoryTitle"  // Assign a name for debugging
        container.addChild(title)
        
        // Display spells in a grid
        let spellSize: CGFloat = 60
        let padding: CGFloat = 20
        let spellsPerRow = 4
        var row = 0
        var col = 0
        
        // Calculate starting position
        let startX = scene.size.width/2 - (spellSize + padding) * CGFloat(spellsPerRow-1)/2
        let startY = scene.size.height * 0.6
        
        // Display consumable spells
        for (spellName, count) in state.consumableSpells where count > 0 {
            // Create the spell icon
            let spellIcon = SKSpriteNode(imageNamed: spellName)
            spellIcon.size = CGSize(width: spellSize, height: spellSize)
            spellIcon.name = "inventorySpell_\(spellName)"
            spellIcon.position = CGPoint(
                x: startX + CGFloat(col) * (spellSize + padding),
                y: startY - CGFloat(row) * (spellSize + padding)
            )
            
            // Add count label
            let countLabel = SKLabelNode(fontNamed: "HelveticaNeue")
            countLabel.text = "x\(count)"
            countLabel.fontSize = 16
            countLabel.fontColor = .white
            countLabel.position = CGPoint(x: spellSize/2 - 5, y: -spellSize/2 + 5)
            countLabel.horizontalAlignmentMode = .right
            spellIcon.addChild(countLabel)
            
            container.addChild(spellIcon)
            
            // Update grid position
            col += 1
            if col >= spellsPerRow {
                col = 0
                row += 1
            }
        }
        
        // Add close button
        let closeButton = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        closeButton.text = "Close"
        closeButton.fontSize = 24
        closeButton.fontColor = .white
        closeButton.name = "closeInventory"
        closeButton.position = CGPoint(x: scene.size.width/2, y: scene.size.height * 0.25)
        container.addChild(closeButton)
        
        container.zPosition = 1000
        scene.addChild(container)
        inventoryDisplay = container
    }
    
    func hideInventoryDisplay() {
        inventoryDisplay?.removeFromParent()
        inventoryDisplay = nil
    }
    
    func handleInventoryButton(_ touchedNode: SKNode) {
        print("Handling inventory interaction: \(touchedNode.name ?? "unnamed node")")
        
        if touchedNode.name == "inventoryButton" {
            showInventoryDisplay()
        } else if touchedNode.name == "closeInventory" {
            hideInventoryDisplay()
        } else if let name = touchedNode.name,
                  name.starts(with: "inventorySpell_") {
            let spellName = String(name.dropFirst("inventorySpell_".count))
            print("🎯 Inventory spell icon pressed: \(spellName)")  // Debug: Specific spell icon press
            
            // Add visual feedback
            if let spellIcon = touchedNode as? SKSpriteNode {
                // Flash effect
                let scaleUp = SKAction.scale(to: 1.2, duration: 0.1)
                let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
                let flash = SKAction.sequence([scaleUp, scaleDown])
                
                // White flash overlay
                let overlay = SKSpriteNode(color: .white, size: spellIcon.size)
                overlay.alpha = 0.5
                spellIcon.addChild(overlay)
                
                // Combine animations
                let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                let remove = SKAction.removeFromParent()
                overlay.run(SKAction.sequence([fadeOut, remove]))
                spellIcon.run(flash)
            }
            
            if state.useInventorySpell(spellName) {
                print("✅ Successfully created temporary spell: \(spellName)")  // Debug: Success confirmation
                hideInventoryDisplay()
                
                // Update the spell icons to show the new active spell
                updateSpellIcon()
            } else {
                print("❌ Failed to use inventory spell: \(spellName)")
            }
        }
    }

    private func setupSpecialButton() {
        guard let scene = parentScene else { return }
        
        // Constants for button layout
        let buttonSize = CGSize(width: 60, height: 60)
        let verticalSpacing: CGFloat = 70
        let baseX = scene.frame.maxX - 60
        let baseY = scene.frame.minY + 70
        
        // Create three special buttons
        for i in 0..<3 {
            // Create button with default "empty" state
            let button = SKSpriteNode(imageNamed: "EmptySpecial")
            button.size = buttonSize
            button.position = CGPoint(x: baseX, y: baseY + CGFloat(i) * verticalSpacing)
            button.name = "specialButton\(i)"
            scene.addChild(button)
            specialButtons.append(button)
            
            // Create cooldown overlay for each button
            let cooldownOverlay = SKShapeNode(circleOfRadius: 30)
            cooldownOverlay.fillColor = SKColor.black.withAlphaComponent(0.5)
            cooldownOverlay.strokeColor = .clear
            cooldownOverlay.position = button.position
            cooldownOverlay.isHidden = true
            scene.addChild(cooldownOverlay)
            specialCooldownOverlays.append(cooldownOverlay)
            
            // Update button if there's an active special for this slot
            let specialSlots = state.getSpecialSlots()
            if let currentSpecial = specialSlots[i] {
                button.texture = SKTexture(imageNamed: currentSpecial.name)
            }
        }
        
        let updateAction = SKAction.run { [weak self] in
            self?.updateSpecialCooldowns()
        }
        let wait = SKAction.wait(forDuration: 0.1)
        scene.run(SKAction.repeatForever(SKAction.sequence([updateAction, wait])))
    }
    
    func handleSpecialButtonTap(_ touchedNode: SKNode, _ currentTime: TimeInterval) -> Bool {
        // Extract the button index from the node name
        guard let buttonName = touchedNode.name,
              buttonName.hasPrefix("specialButton"),
              let index = Int(buttonName.dropFirst("specialButton".count)) else {
            print("🎮 Special Button Tap: Invalid button name")
            return false
        }
        
        // Print debug info about the tapped special slot
        let specialSlots = state.getSpecialSlots()
        if let special = specialSlots[index] {
            print("🎮 Special Button \(index) Tapped: \(special.name) (Cooldown: \(special.cooldown)s)")
            if special.canUse() {
                print("✅ Special is ready to use")
            } else {
                if let lastUsed = special.lastUsedTime {
                    let elapsed = special.getEffectiveElapsedTime()
                    print("⏳ Special on cooldown: \(elapsed)/\(special.cooldown) seconds elapsed")
                }
            }
        } else {
            print("🎮 Special Button \(index) Tapped: Empty slot")
        }
        
        return false
    }
    
    private func updateSpecialCooldowns() {
        for i in 0..<specialButtons.count {
            updateSpecialCooldown(at: i)
        }
    }
    
    func updateSpecialCooldown(at index: Int) {
        let specialSlots = state.getSpecialSlots()
        guard let currentSpecial = specialSlots[index] else { return }
        let overlay = specialCooldownOverlays[index]
        
        if !currentSpecial.canUse() {
            overlay.isHidden = false
            
            // Calculate remaining cooldown percentage
            if let lastUsed = currentSpecial.lastUsedTime {
                let effectiveElapsed = currentSpecial.getEffectiveElapsedTime()
                let percentage = max(0, min(1, effectiveElapsed / currentSpecial.cooldown))
                
                // Create arc for remaining cooldown
                let path = CGMutablePath()
                let center = CGPoint.zero
                path.move(to: center)
                path.addArc(center: center,
                           radius: 30,
                           startAngle: -.pi / 2,
                           endAngle: -.pi / 2 + (.pi * 2 * (1 - percentage)),
                           clockwise: false)
                path.addLine(to: center)
                
                overlay.path = path
            }
        } else {
            overlay.isHidden = true
        }
    }
    
    func updateSpecialButton(at index: Int) {
        guard index < specialButtons.count else { return }
        let specialSlots = state.getSpecialSlots()
        if let currentSpecial = specialSlots[index] {
            print("🔄 Updating Special Button \(index): \(currentSpecial.name)")
            specialButtons[index].texture = SKTexture(imageNamed: currentSpecial.name)
        } else {
            print("🔄 Updating Special Button \(index): Empty")
            specialButtons[index].texture = SKTexture(imageNamed: "EmptySpecial")
        }
        updateSpecialCooldown(at: index)
    }
}
