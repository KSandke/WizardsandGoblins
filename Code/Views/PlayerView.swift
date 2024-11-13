import SpriteKit

class PlayerView {
    // UI Components
    private let castle: SKSpriteNode
    private let castleHealthBar: SKShapeNode
    private let castleHealthFill: SKShapeNode
    
    private let playerOne: SKSpriteNode
    private let playerTwo: SKSpriteNode
    
    private let playerOneManaBar: SKShapeNode
    private let playerTwoManaBar: SKShapeNode
    private let playerOneManaFill: SKShapeNode
    private let playerTwoManaFill: SKShapeNode
    
    private weak var parentScene: SKScene?
    private let state: PlayerState
    
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
    }
    
    private func setupUI() {
        setupCastle()
        setupWizards()
        setupManaBars()
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
    
    private func updateCastleHealthBar(health: CGFloat) {
        castleHealthFill.xScale = health / state.maxCastleHealth
    }
    
    private func updatePlayerOneManaBar(mana: CGFloat) {
        playerOneManaFill.xScale = mana / state.maxMana
    }
    
    private func updatePlayerTwoManaBar(mana: CGFloat) {
        playerTwoManaFill.xScale = mana / state.maxMana
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