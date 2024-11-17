import Foundation
import SpriteKit
import CoreGraphics
import GameplayKit

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
    
    // Add completion handler
    private var completionHandler: (() -> Void)?
    
    init(scene: GameScene) {
        self.scene = scene
    }
    
    func startTutorial(completion: (() -> Void)? = nil) {
        isActive = true
        completionHandler = completion
        showCurrentStep()
    }
    
    private func endTutorial() {
        isActive = false
        cleanup()
        completionHandler?()
    }
    
    private func showCurrentStep() {
        guard let scene = scene else { return }
        
        // Create semi-transparent overlay
        let overlay = SKShapeNode(rectOf: scene.size)
        overlay.fillColor = .black
        overlay.alpha = 0.5
        overlay.position = CGPoint(x: scene.size.width/2, y: scene.size.height/2)
        overlay.zPosition = 1000 // Ensure it's above everything
        self.overlay = overlay
        scene.addChild(overlay)
        
        // Create message box with rounded corners and better styling
        let messageBox = SKSpriteNode(color: .white, size: CGSize(width: 300, height: 150))
        messageBox.position = CGPoint(x: scene.size.width/2, y: scene.size.height/2)
        messageBox.zPosition = 1001 // Above overlay
        messageBox.alpha = 0.9
        
        // Add border and corner radius using a shape node
        let border = SKShapeNode(rectOf: messageBox.size, cornerRadius: 15)
        border.fillColor = .white
        border.strokeColor = .blue
        border.lineWidth = 3
        messageBox.addChild(border)
        
        self.messageBox = messageBox
        scene.addChild(messageBox)
        
        // Create message label with better styling
        let messageLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        messageLabel.fontSize = 20
        messageLabel.numberOfLines = 0
        messageLabel.fontColor = .black
        messageLabel.position = CGPoint(x: 0, y: 20) // Adjust for better centering
        messageLabel.zPosition = 1002 // Above message box
        self.messageLabel = messageLabel
        messageBox.addChild(messageLabel)
        
        // Add continue button
        let continueButton = SKLabelNode(fontNamed: "HelveticaNeue")
        continueButton.text = "Tap to continue"
        continueButton.fontSize = 16
        continueButton.fontColor = .gray
        continueButton.position = CGPoint(x: 0, y: -40)
        continueButton.zPosition = 1002
        messageBox.addChild(continueButton)
        
        // Add fade-in animation
        messageBox.alpha = 0
        let fadeIn = SKAction.fadeIn(withDuration: 0.3)
        messageBox.run(fadeIn)
        
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
    
    func handleTap(_ touch: UITouch) {
        if !isActive { return }
        
        // Only handle taps on the message box
        guard let messageBox = messageBox else { return }
        let touchLocation = touch.location(in: messageBox.parent!)
        
        if messageBox.contains(touchLocation) {
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
            
            transitionToNextStep()
        }
    }
    
    private func transitionToNextStep() {
        guard let messageBox = messageBox else { return }
        
        // Fade out current message
        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        let fadeIn = SKAction.fadeIn(withDuration: 0.2)
        
        messageBox.run(fadeOut) { [weak self] in
            guard let self = self else { return }
            
            // Update the message
            self.updateMessage()
            
            // Fade in new message
            messageBox.run(fadeIn)
        }
    }
    
    private func cleanup() {
        // Fade out all tutorial elements
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        overlay?.run(fadeOut) { [weak self] in
            self?.overlay?.removeFromParent()
            self?.overlay = nil
        }
        
        messageBox?.run(fadeOut) { [weak self] in
            self?.messageBox?.removeFromParent()
            self?.messageBox = nil
            self?.messageLabel = nil
        }
        
        // Remove any highlights
        scene?.children.filter { $0.name?.contains("tutorial-highlight") ?? false }
            .forEach { $0.removeFromParent() }
    }
    
    var isTutorialActive: Bool {
        return isActive
    }
    
    private func highlightElement(at position: CGPoint, size: CGSize) {
        let highlight = SKShapeNode(rectOf: size)
        highlight.fillColor = .clear
        highlight.strokeColor = .yellow
        highlight.lineWidth = 3
        highlight.position = position
        highlight.zPosition = 999 // Just below overlay
        
        // Add glow effect
        highlight.glowWidth = 5
        highlight.alpha = 0
        
        scene?.addChild(highlight)
        
        // Animate the highlight
        let fadeIn = SKAction.fadeIn(withDuration: 0.3)
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.5),
            SKAction.scale(to: 1.0, duration: 0.5)
        ])
        
        highlight.run(fadeIn)
        highlight.run(SKAction.repeatForever(pulse))
    }
} 