import SpriteKit

class PlayerView {
    // UI Components
    private var castle: SKSpriteNode
    private var castleHealthBar: SKShapeNode
    private var castleHealthFill: SKShapeNode
    
    private var playerOne: SKSpriteNode
    private var playerTwo: SKSpriteNode
    
    private var playerOneManaBar: SKShapeNode
    private var playerTwoManaBar: SKShapeNode
    private var playerOneManaFill: SKShapeNode
    private var playerTwoManaFill: SKShapeNode
    
    private var scoreLabel: SKLabelNode!
    private var coinLabel: SKLabelNode!
    
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
        
        playerOneManaBar = SKShapeNode(rectOf: CGSize(width: 100, height: 10))
        playerTwoManaBar = SKShapeNode(rectOf: CGSize(width: 100, height: 10))
        playerOneManaFill = SKShapeNode(rectOf: CGSize(width: 100, height: 10))
        playerTwoManaFill = SKShapeNode(rectOf: CGSize(width: 100, height: 10))
        
        setupBindings()
        setupUI()
    }
    
    private func setupBindings() {
        // Bind state changes to UI updates
        state.onCastleHealthChanged = { [weak self] health in
            self?.updateCastleHealthBar(health: health)
        }
        
        state.onPlayerOneManaChanged = { [weak self] mana in
            self?.updatePlayerOneManaBar(mana: mana)
        }
        
        state.onPlayerTwoManaChanged = { [weak self] mana in
            self?.updatePlayerTwoManaBar(mana: mana)
        }

        state.onScoreChanged = { [weak self] score in
            self?.updateScoreLabel(score: score)
        }

        state.onCoinsChanged = { [weak self] coins in
            self?.updateCoinsLabel(coins: coins)
        }
    }
    
    private func setupUI() {
        setupCastle()
        setupWizards()
        setupManaBars()
        setupScoreLabel()
        setupCoinsLabel()
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
        setupManaBar(bar: playerOneManaBar, fill: playerOneManaFill, atPosition: playerOne.position)
        setupManaBar(bar: playerTwoManaBar, fill: playerTwoManaFill, atPosition: playerTwo.position)
        
        updatePlayerOneManaBar(mana: state.playerOneMana)
        updatePlayerTwoManaBar(mana: state.playerTwoMana)
    }
    
    private func setupManaBar(bar: SKShapeNode, fill: SKShapeNode, atPosition pos: CGPoint) {
        guard let scene = parentScene else { return }
        
        bar.fillColor = .gray
        bar.strokeColor = .black
        bar.position = CGPoint(x: pos.x, y: pos.y - 50)
        scene.addChild(bar)
        
        fill.fillColor = .blue
        fill.strokeColor = .clear
        fill.position = bar.position
        scene.addChild(fill)
    }

    private func setupScoreLabel() {
        guard let scene = parentScene else { return }
        scoreLabel = SKLabelNode(text: "Score: \(state.score)")
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = .black
        scoreLabel.position = CGPoint(x: scene.size.width - 100, y: scene.size.height - 90)
        scene.addChild(scoreLabel)
    }

    private func setupCoinsLabel() {
        guard let scene = parentScene else { return }
        coinLabel = SKLabelNode(text: "Coins: \(state.coins)")
        coinLabel.fontSize = 24
        coinLabel.fontColor = .black
        coinLabel.position = CGPoint(x: scene.size.width - 100, y: scene.size.height - 120)
        scene.addChild(coinLabel)
    }

    private func updateCastleHealthBar(health: CGFloat) {
        castleHealthFill.xScale = health / state.maxCastleHealth
    }
    
    private func updatePlayerOneManaBar(mana: CGFloat) {
        playerOneManaFill.xScale = mana / state.maxMana
    }
    
    private func updatePlayerTwoManaBar(mana: CGFloat) {
        playerTwoManaFill.xScale = mana / state.maxMana
    }

    private func updateScoreLabel(score: Int) {
        scoreLabel.text = "Score: \(score)"
    }

    private func updateCoinsLabel(coins: Int) {
        coinLabel.text = "Coins: \(coins)"
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
} 