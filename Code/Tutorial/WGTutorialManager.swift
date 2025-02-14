import Foundation
import SpriteKit
import CoreGraphics
import GameplayKit

class TutorialManager {
    enum TutorialStep {
        case welcome
        case castleHealth
        case manaSystem
        case spellTypes
        case spellSwapping
        case specialAbilities
        case goblinTypes
        case scoring
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
    
    private var highlightMessageBoxes: [SKSpriteNode] = []
    
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
        hasCompletedTutorial = true
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
        guard let scene = scene,
              let gameScene = scene as? GameScene else { return }
        
        // Remove previous highlights
        scene.children.filter { $0.name == "tutorial-highlight" }.forEach { $0.removeFromParent() }
        
        switch currentStep {
        case .welcome:
            showMessage("Welcome to Wizards & Goblins!\nLet's learn how to defend your castle!")
            
        case .castleHealth:
            highlightUIElement(node: gameScene.playerView.tutorialCastleHealthBar, 
                             description: "This is your castle's health.\nDon't let goblins reach it!")
            
        case .manaSystem:
            if let firstSegment = gameScene.playerView.tutorialChargeSegments.first {
                highlightUIElement(node: firstSegment, 
                                 description: "Mana bars show available spell charges.\nThey regenerate over time.")
            }
            
        case .spellTypes:
            highlightUIElement(node: gameScene.playerView.spellIcon, 
                             description: "Different spells have different effects!\nSome do direct damage, others slow or chain between enemies.")
            
        case .spellSwapping:
            highlightUIElement(node: gameScene.playerView.spellIcon,
                             description: "Swipe left or right on the spell icon to switch between your available spells!")
            
        case .specialAbilities:
            if let specialButton = gameScene.playerView.tutorialSpecialButtons.first {
                highlightUIElement(node: specialButton,
                                 description: "Special abilities are powerful skills with cooldowns.\nTap the icons to use them when ready!")
            }
            
        case .goblinTypes:
            showMessage("Watch out for different goblin types!\nRanged goblins attack from afar,\nwhile larger goblins are tougher to defeat.")
            
        case .scoring:
            highlightUIElement(node: gameScene.playerView.tutorialScoreLabel, 
                             description: "Defeat goblins to earn points and coins.\nChain kills to build up your combo multiplier!")
            
        case .complete:
            showMessage("You're ready to defend your castle!\nGood luck, wizard!")
        }
    }
    
    func handleTap(_ touch: UITouch) {
        if !isActive { return }
        
        // Only handle taps on the message box
        guard let messageBox = messageBox else { return }
        let touchLocation = touch.location(in: messageBox.parent!)
        
        switch currentStep {
        case .welcome:
            currentStep = .castleHealth
        case .castleHealth:
            currentStep = .manaSystem
        case .manaSystem:
            currentStep = .spellTypes
        case .spellTypes:
            currentStep = .spellSwapping
        case .spellSwapping:
            currentStep = .specialAbilities
        case .specialAbilities:
            currentStep = .goblinTypes
        case .goblinTypes:
            currentStep = .scoring
        case .scoring:
            currentStep = .complete
        case .complete:
            endTutorial()
            return
        }
        
        transitionToNextStep()
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
        
        // Clean up highlight message boxes
        highlightMessageBoxes.forEach { box in
            box.run(fadeOut) { 
                box.removeFromParent()
            }
        }
        highlightMessageBoxes.removeAll()
        
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
        highlight.run(fadeIn)
    }
    
    private func highlightUIElement(node: SKNode, description: String) {
        guard let scene = scene else { return }
        
        // Clean up previous highlight message boxes
        highlightMessageBoxes.forEach { $0.removeFromParent() }
        highlightMessageBoxes.removeAll()
        
        // Create highlight frame
        let frame = SKShapeNode(rect: node.frame.insetBy(dx: -10, dy: -10), cornerRadius: 8)
        frame.strokeColor = .yellow
        frame.lineWidth = 2
        frame.name = "tutorial-highlight"
        frame.zPosition = 1000
        scene.addChild(frame)
        
        // Position message box near the highlighted element
        let messageBox = createMessageBox(text: description)
        let boxSize = messageBox.size
        let yOffset: CGFloat = node.frame.minY > scene.size.height/2 ? -100 : 100
        let basePosition = CGPoint(x: node.frame.midX, y: node.frame.midY + yOffset)
        messageBox.position = getMessageBoxPosition(basePosition: basePosition, boxSize: boxSize)
        
        scene.addChild(messageBox)
        highlightMessageBoxes.append(messageBox)
    }
    
    private func showMessage(_ text: String) {
        guard let scene = scene else { return }
        
        // Remove any existing message box
        messageBox?.removeFromParent()
        
        // Create message box with rounded corners
        let boxWidth: CGFloat = 350  // Increased from 300
        let boxHeight: CGFloat = 170 // Increased from 150
        messageBox = SKSpriteNode(color: .white, size: CGSize(width: boxWidth, height: boxHeight))
        messageBox?.position = CGPoint(x: scene.size.width/2, y: scene.size.height/2)
        messageBox?.zPosition = 1001
        messageBox?.alpha = 0.9
        let boxSize = CGSize(width: boxWidth, height: boxHeight)
        let basePosition = CGPoint(x: scene.size.width/2, y: scene.size.height/2)
        messageBox?.position = getMessageBoxPosition(basePosition: basePosition, boxSize: boxSize)
        
        // Add border and corner radius
        let border = SKShapeNode(rectOf: CGSize(width: boxWidth, height: boxHeight), cornerRadius: 15)
        border.fillColor = .white
        border.strokeColor = .blue
        border.lineWidth = 3
        messageBox?.addChild(border)
        
        // Create message label
        messageLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        messageLabel?.numberOfLines = 0
        messageLabel?.text = text
        messageLabel?.fontSize = 20
        messageLabel?.fontColor = .black
        messageLabel?.preferredMaxLayoutWidth = boxWidth - 40
        messageLabel?.verticalAlignmentMode = .center
        messageLabel?.position = CGPoint(x: 0, y: 0)
        messageBox?.addChild(messageLabel!)
        
        // Add continue hint
        let continueHint = SKLabelNode(fontNamed: "HelveticaNeue")
        continueHint.text = "Tap to continue"
        continueHint.fontSize = 16
        continueHint.fontColor = .gray
        continueHint.position = CGPoint(x: 0, y: -(boxHeight/2 - 25))
        messageBox?.addChild(continueHint)
        
        scene.addChild(messageBox!)
        
        // Add fade in animation
        messageBox?.alpha = 0
        let fadeIn = SKAction.fadeIn(withDuration: 0.3)
        messageBox?.run(fadeIn)
    }
    
    private func createMessageBox(text: String) -> SKSpriteNode {
        // Create message box with rounded corners
        let boxWidth: CGFloat = 350  // Increased from 300
        let boxHeight: CGFloat = 120 // Increased from 100
        let messageBox = SKSpriteNode(color: .white, size: CGSize(width: boxWidth, height: boxHeight))
        messageBox.alpha = 0.9
        messageBox.zPosition = 1001
        
        // Add border and corner radius
        let border = SKShapeNode(rectOf: CGSize(width: boxWidth, height: boxHeight), cornerRadius: 15)
        border.fillColor = .white
        border.strokeColor = .blue
        border.lineWidth = 3
        messageBox.addChild(border)
        
        // Create message label
        let messageLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        messageLabel.numberOfLines = 0
        messageLabel.text = text
        messageLabel.fontSize = 18
        messageLabel.fontColor = .black
        messageLabel.preferredMaxLayoutWidth = boxWidth - 40
        messageLabel.verticalAlignmentMode = .center
        messageLabel.position = CGPoint(x: 0, y: 0)
        messageBox.addChild(messageLabel)
        
        // Add fade in animation
        messageBox.alpha = 0
        let fadeIn = SKAction.fadeIn(withDuration: 0.3)
        messageBox.run(fadeIn)
        
        return messageBox
    }
    
    private func getMessageBoxPosition(basePosition: CGPoint, boxSize: CGSize) -> CGPoint {
        guard let scene = scene else { return basePosition }
        
        // Calculate safe margins
        let margin: CGFloat = 20
        
        // Calculate bounds
        let minX = margin + boxSize.width/2
        let maxX = scene.size.width - margin - boxSize.width/2
        let minY = margin + boxSize.height/2
        let maxY = scene.size.height - margin - boxSize.height/2
        
        // Clamp position within bounds
        let clampedX = min(maxX, max(minX, basePosition.x))
        let clampedY = min(maxY, max(minY, basePosition.y))
        
        return CGPoint(x: clampedX, y: clampedY)
    }
} 
