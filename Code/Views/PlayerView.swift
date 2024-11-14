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
    }
    
    private func setupCastle() {
        guard let scene = parentScene else { return }
        
        castle.position = CGPoint(x: scene.size.width/2, y: 50)
        castle.zPosition = 0
        //setup physics
        let castlePhysicsBody = SKPhysicsBody(rectangleOf: castle.size)
        castlePhysicsBody.isDynamic = false
        castlePhysicsBody.affectedByGravity = false
        castlePhysicsBody.allowsRotation = false
        castlePhysicsBody.categoryBitMask = PhysicsCategory.castle
        castlePhysicsBody.contactTestBitMask = PhysicsCategory.enemyProjectile
        castlePhysicsBody.collisionBitMask = PhysicsCategory.none
        castle.physicsBody = castlePhysicsBody
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
        for (index, segment) in playerOneChargeSegments.enumerated() {
            segment.fillColor = index < charges ? .blue : .gray
        }
    }
    
    private func updatePlayerTwoCharges(charges: Int) {
        for (index, segment) in playerTwoChargeSegments.enumerated() {
            segment.fillColor = index < charges ? .blue : .gray
        }
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
    
    var playerOnePosition: CGPoint {
        playerOne.position
    }
    
    var playerTwoPosition: CGPoint {
        playerTwo.position
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
} 