import SpriteKit

class PlayerView {
    // UI Components
    private var castle: SKSpriteNode
    private var castleHealthBar: SKShapeNode
    private var castleHealthFill: SKShapeNode
    
    private var playerOne: SKSpriteNode
    private var playerTwo: SKSpriteNode
    
    private var playerOneChargeSegments: [SKShapeNode] = []
    private var playerTwoChargeSegments: [SKShapeNode] = []
    private var scoreLabel: SKLabelNode!
    private var coinLabel: SKLabelNode!
    private var waveLabel: SKLabelNode!
    
    private weak var parentScene: SKScene?
    private var state: PlayerState
    // Add public getters for tutorial access
    var tutorialCastleHealthBar: SKShapeNode { castleHealthBar }
    var tutorialPlayerOneCharges: [SKShapeNode] { playerOneChargeSegments }
    var tutorialPlayerTwoCharges: [SKShapeNode] { playerTwoChargeSegments }
    var tutorialScoreLabel: SKLabelNode { scoreLabel }
    var tutorialWaveLabel: SKLabelNode { waveLabel }
    var tutorialCoinLabel: SKLabelNode { coinLabel }

    var playerOnePosition: CGPoint { playerOne.position }
    var playerTwoPosition: CGPoint { playerTwo.position }
    
    private var primarySpellIcon: SKSpriteNode!
    private var secondarySpellIcon: SKSpriteNode!
    private var primaryCycleButton: SKSpriteNode!
    private var secondaryCycleButton: SKSpriteNode!
    
    private var primarySpellLabel: SKLabelNode!
    private var secondarySpellLabel: SKLabelNode!
    
    init(scene: SKScene, state: PlayerState) {
        self.parentScene = scene
        self.state = state
        
        // Initialize UI components
        castle = SKSpriteNode(color: .gray, size: CGSize(width: scene.size.width, height: 100))
        castleHealthBar = SKShapeNode(rectOf: CGSize(width: 200, height: 20))
        castleHealthFill = SKShapeNode(rectOf: CGSize(width: 200, height: 20))
        
        playerOne = SKSpriteNode(imageNamed: "Wizard1")
        playerTwo = SKSpriteNode(imageNamed: "Wizard2")
        
        setupBindings()
        setupUI()
    }
    
    private func setupBindings() {
        // Bind state changes to UI updates
        state.onCastleHealthChanged = { [weak self] health in
            self?.updateCastleHealthBar(health: health)
        }
        
        state.onPlayerOneChargesChanged = { [weak self] charges in
            self?.updatePlayerOneCharges(charges: charges)
        }
        
        state.onPlayerTwoChargesChanged = { [weak self] charges in
            self?.updatePlayerTwoCharges(charges: charges)
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
    }
    
    private func setupUI() {
        setupCastle()
        setupWizards()
        setupManaBars()
        setupScoreLabel()
        setupCoinsLabel()
        setupWaveLabel()
        setupSpellIcons()
    }
    
    private func setupCastle() {
        guard let scene = parentScene else { return }
        
        castle.position = CGPoint(x: scene.size.width/2, y: 50)
        scene.addChild(castle)
        
        castleHealthBar.fillColor = .gray
        castleHealthBar.strokeColor = .black
        castleHealthBar.position = CGPoint(x: scene.size.width/2, y: 20)
        scene.addChild(castleHealthBar)
        
        castleHealthFill.fillColor = .red
        castleHealthFill.strokeColor = .clear
        castleHealthFill.position = castleHealthBar.position
        scene.addChild(castleHealthFill)


        
        updateCastleHealthBar(health: state.castleHealth)
    }
    
    private func setupWizards() {
        guard let scene = parentScene else { return }
        
        playerOne.size = CGSize(width: 75, height: 75)
        playerOne.position = CGPoint(x: scene.size.width * 0.25, y: 100)
        scene.addChild(playerOne)
        
        playerTwo.size = CGSize(width: 75, height: 75)
        playerTwo.position = CGPoint(x: scene.size.width * 0.75, y: 100)
        scene.addChild(playerTwo)
    }
    
    private func setupManaBars() {
        setupChargeSegments(segments: &playerOneChargeSegments, atPosition: playerOne.position)
        setupChargeSegments(segments: &playerTwoChargeSegments, atPosition: playerTwo.position)
        
        updatePlayerOneCharges(charges: state.playerOneSpellCharges)
        updatePlayerTwoCharges(charges: state.playerTwoSpellCharges)
    }
    
    private func setupChargeSegments(segments: inout [SKShapeNode], atPosition pos: CGPoint) {
        guard let scene = parentScene else { return }
        
        let screenMidX = scene.size.width / 2
        
        // Calculate maximum available width based on whether this is player one or two
        let maxAvailableWidth: CGFloat
        if pos.x < screenMidX {  // Player One (left side)
            maxAvailableWidth = min(
                pos.x * 1.4,  // Distance from left edge
                screenMidX - pos.x - 20  // Distance to middle, with 20pt buffer
            )
        } else {  // Player Two (right side)
            maxAvailableWidth = min(
                (scene.size.width - pos.x) * 1.4,  // Distance from right edge
                pos.x - screenMidX - 20  // Distance from middle, with 20pt buffer
            )
        }
        
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
        
        // Adjust startX to ensure segments stay on their respective sides
        let startX: CGFloat
        if pos.x < screenMidX {  // Player One (left side)
            startX = min(pos.x - (totalWidth / 2), screenMidX - totalWidth - 20)
        } else {  // Player Two (right side)
            startX = max(pos.x - (totalWidth / 2), screenMidX + 20)
        }
        
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
    
    private func updatePlayerOneCharges(charges: Int) {
        // Get the previous charge count by counting blue segments
        let previousCharges = playerOneChargeSegments.filter { $0.fillColor == .blue }.count
        
        // If charges increased, animate the new segments
        if charges > previousCharges {
            for (index, segment) in playerOneChargeSegments.enumerated() {
                if index < charges {
                    if index >= previousCharges {
                        // Animate new charge segments
                        animateChargeSegment(segment)
                    } else {
                        // Keep existing charged segments blue
                        segment.fillColor = .blue
                    }
                } else {
                    segment.fillColor = .gray
                }
            }
        } else {
            // Regular update without animation
            for (index, segment) in playerOneChargeSegments.enumerated() {
                segment.fillColor = index < charges ? .blue : .gray
            }
        }
    }
    
    private func updatePlayerTwoCharges(charges: Int) {
        // Get the previous charge count by counting blue segments
        let previousCharges = playerTwoChargeSegments.filter { $0.fillColor == .blue }.count
        
        // If charges increased, animate the new segments
        if charges > previousCharges {
            for (index, segment) in playerTwoChargeSegments.enumerated() {
                if index < charges {
                    if index >= previousCharges {
                        // Animate new charge segments
                        animateChargeSegment(segment)
                    } else {
                        // Keep existing charged segments blue
                        segment.fillColor = .blue
                    }
                } else {
                    segment.fillColor = .gray
                }
            }
        } else {
            // Regular update without animation
            for (index, segment) in playerTwoChargeSegments.enumerated() {
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
        scoreLabel.position = CGPoint(x: scene.size.width - 150, y: scene.size.height - 100)
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
        coinLabel.position = CGPoint(x: scene.size.width - 150, y: scene.size.height - 135)
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
        waveLabel.position = CGPoint(x: 80, y: scene.size.height - 60)
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
        playerOneChargeSegments.forEach { $0.removeFromParent() }
        playerTwoChargeSegments.forEach { $0.removeFromParent() }
        playerOneChargeSegments.removeAll()
        playerTwoChargeSegments.removeAll()
        
        // Setup new charge segments
        setupChargeSegments(segments: &playerOneChargeSegments, atPosition: playerOne.position)
        setupChargeSegments(segments: &playerTwoChargeSegments, atPosition: playerTwo.position)
        
        // Update visual state
        updatePlayerOneCharges(charges: state.playerOneSpellCharges)
        updatePlayerTwoCharges(charges: state.playerTwoSpellCharges)
    }

    private func setupSpellIcons() {
        guard let scene = parentScene else { return }
        
        // Primary spell setup
        primarySpellIcon = SKSpriteNode(imageNamed: state.primarySpell.name)
        primarySpellIcon.size = CGSize(width: 40, height: 40)
        primarySpellIcon.position = CGPoint(x: playerOne.position.x - 30, y: playerOne.position.y + 50)
        
        // Primary spell name label
        primarySpellLabel = SKLabelNode(fontNamed: "HelveticaNeue")
        primarySpellLabel.fontSize = 12
        primarySpellLabel.text = state.primarySpell.name
        primarySpellLabel.position = CGPoint(x: primarySpellIcon.position.x, 
                                           y: primarySpellIcon.position.y + 25)
        
        // Secondary spell setup
        secondarySpellIcon = SKSpriteNode(imageNamed: state.secondarySpell.name)
        secondarySpellIcon.size = CGSize(width: 40, height: 40)
        secondarySpellIcon.position = CGPoint(x: playerTwo.position.x - 30, y: playerTwo.position.y + 50)
        
        // Secondary spell name label
        secondarySpellLabel = SKLabelNode(fontNamed: "HelveticaNeue")
        secondarySpellLabel.fontSize = 12
        secondarySpellLabel.text = state.secondarySpell.name
        secondarySpellLabel.position = CGPoint(x: secondarySpellIcon.position.x,
                                             y: secondarySpellIcon.position.y + 25)
        
        scene.addChild(primarySpellIcon)
        scene.addChild(secondarySpellIcon)
        scene.addChild(primarySpellLabel)
        scene.addChild(secondarySpellLabel)
        
        setupCycleButtons()
    }

    private func setupCycleButtons() {
        guard let scene = parentScene else { return }
        
        // Primary cycle button
        primaryCycleButton = SKSpriteNode(imageNamed: "cycle_arrow")  // Create this asset
        primaryCycleButton.size = CGSize(width: 20, height: 20)
        primaryCycleButton.position = CGPoint(x: primarySpellIcon.position.x + 30, y: primarySpellIcon.position.y)
        primaryCycleButton.name = "primaryCycle"
        scene.addChild(primaryCycleButton)
        
        // Secondary cycle button
        secondaryCycleButton = SKSpriteNode(imageNamed: "cycle_arrow")
        secondaryCycleButton.size = CGSize(width: 20, height: 20)
        secondaryCycleButton.position = CGPoint(x: secondarySpellIcon.position.x + 30, y: secondarySpellIcon.position.y)
        secondaryCycleButton.name = "secondaryCycle"
        scene.addChild(secondaryCycleButton)
    }

    func handleSpellCycleTouch(_ touchedNode: SKNode) {
        switch touchedNode.name {
        case "primaryCycle":
            cycleSpell(isPrimary: true)
        case "secondaryCycle":
            cycleSpell(isPrimary: false)
        default:
            break
        }
    }

    private func cycleSpell(isPrimary: Bool) {
        let availableSpells = state.getAvailableSpells()
        guard availableSpells.count > 1 else { return }
        
        let currentSpell = isPrimary ? state.primarySpell : state.secondarySpell
        
        if let currentIndex = availableSpells.firstIndex(where: { $0.name == currentSpell.name }) {
            let nextIndex = (currentIndex + 1) % availableSpells.count
            let nextSpell = availableSpells[nextIndex]
            
            if isPrimary {
                state.primarySpell = nextSpell
                primarySpellIcon.texture = SKTexture(imageNamed: nextSpell.name)
                primarySpellLabel.text = nextSpell.name
            } else {
                state.secondarySpell = nextSpell
                secondarySpellIcon.texture = SKTexture(imageNamed: nextSpell.name)
                secondarySpellLabel.text = nextSpell.name
            }
            
            let scaleUp = SKAction.scale(to: 1.2, duration: 0.1)
            let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
            let sequence = SKAction.sequence([scaleUp, scaleDown])
            
            if isPrimary {
                primarySpellIcon.run(sequence)
            } else {
                secondarySpellIcon.run(sequence)
            }
        }
    }

} 