class TutorialManager {
    enum TutorialStep {
        case welcome
        case moveWizards
        case castSpell
        case killGoblin
        case useShop
        case complete
    }
    
    private var currentStep: TutorialStep = .welcome
    private var isActive: Bool = false
    private weak var scene: GameScene?
    
    // Overlay nodes
    private var overlay: SKShapeNode?
    private var messageBox: SKSpriteNode?
    private var messageLabel: SKLabelNode?
    
    private let tutorialKey = "WGTutorialCompleted"
    
    private var hasCompletedTutorial: Bool {
        get {
            UserDefaults.standard.bool(forKey: tutorialKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: tutorialKey)
        }
    }
    
    init(scene: GameScene) {
        self.scene = scene
    }
    
    func startTutorial() {
        isActive = true
        showCurrentStep()
    }
    
    func endTutorial() {
        isActive = false
        cleanup()
    }
    
    private func showCurrentStep() {
        guard let scene = scene else { return }
        
        // Create semi-transparent overlay
        let overlay = SKShapeNode(rectOf: scene.size)
        overlay.fillColor = .black
        overlay.alpha = 0.5
        overlay.position = CGPoint(x: scene.size.width/2, y: scene.size.height/2)
        self.overlay = overlay
        scene.addChild(overlay)
        
        // Create message box
        let messageBox = SKSpriteNode(color: .white, size: CGSize(width: 300, height: 150))
        messageBox.position = CGPoint(x: scene.size.width/2, y: scene.size.height/2)
        self.messageBox = messageBox
        scene.addChild(messageBox)
        
        // Create message label
        let messageLabel = SKLabelNode(fontNamed: "HelveticaNeue")
        messageLabel.fontSize = 20
        messageLabel.numberOfLines = 0
        messageLabel.position = CGPoint(x: 0, y: 0)
        self.messageLabel = messageLabel
        messageBox.addChild(messageLabel)
        
        // Set message based on current step
        updateMessage()
    }
    
    private func updateMessage() {
        switch currentStep {
        case .welcome:
            messageLabel?.text = "Welcome to Wizards & Goblins!\nTap to continue"
        case .moveWizards:
            messageLabel?.text = "Tap anywhere to cast spells\nwith your wizards!"
        case .castSpell:
            messageLabel?.text = "Tap on a wizard to switch\ntheir spell type"
        case .killGoblin:
            messageLabel?.text = "Defeat the goblins before\nthey reach your castle!"
        case .useShop:
            messageLabel?.text = "Use coins in the shop to\nupgrade your wizards"
        case .complete:
            messageLabel?.text = "You're ready to play!\nGood luck!"
        }
    }
    
    func handleTap() {
        if !isActive { return }
        
        // Advance to next step
        switch currentStep {
        case .welcome:
            currentStep = .moveWizards
        case .moveWizards:
            currentStep = .castSpell
        case .castSpell:
            currentStep = .killGoblin
        case .killGoblin:
            currentStep = .useShop
        case .useShop:
            currentStep = .complete
        case .complete:
            endTutorial()
            return
        }
        
        updateMessage()
    }
    
    private func cleanup() {
        overlay?.removeFromParent()
        messageBox?.removeFromParent()
        overlay = nil
        messageBox = nil
        messageLabel = nil
    }
    
    var isTutorialActive: Bool {
        return isActive
    }
} 