import SpriteKit
import Foundation

class ScoreScreen: SKNode {
    private let playerState: PlayerState
    private let waveNumber: Int
    private let onContinue: () -> Void
    private let size: CGSize
    
    init(size: CGSize, playerState: PlayerState, waveNumber: Int, onContinue: @escaping () -> Void) {
        self.size = size
        self.playerState = playerState
        self.waveNumber = waveNumber
        self.onContinue = onContinue
        super.init()
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // Semi-transparent background
        let background = SKSpriteNode(color: .black.withAlphaComponent(0.8), size: size)
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(background)
        
        // Wave completed title
        let titleLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        titleLabel.text = "Wave \(waveNumber) Completed!"
        titleLabel.fontSize = 36
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: size.width/2, y: size.height * 0.8)
        addChild(titleLabel)
        
        // Score display with animation
        let scoreLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        scoreLabel.text = "Score: \(playerState.score)"
        scoreLabel.fontSize = 32
        scoreLabel.fontColor = .yellow
        scoreLabel.position = CGPoint(x: size.width/2, y: size.height * 0.6)
        addChild(scoreLabel)
        
        // Coins earned this wave
        let coinsLabel = SKLabelNode(fontNamed: "HelveticaNeue")
        coinsLabel.text = "Coins: \(playerState.coins)"
        coinsLabel.fontSize = 28
        coinsLabel.fontColor = .yellow
        coinsLabel.position = CGPoint(x: size.width/2, y: size.height * 0.5)
        addChild(coinsLabel)
        
        // Continue to shop button
        let continueButton = SKShapeNode(rectOf: CGSize(width: 200, height: 50), cornerRadius: 10)
        continueButton.fillColor = .blue
        continueButton.strokeColor = .white
        continueButton.position = CGPoint(x: size.width/2, y: size.height * 0.3)
        continueButton.name = "continueButton"
        
        let buttonLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        buttonLabel.text = "Continue to Shop"
        buttonLabel.fontSize = 20
        buttonLabel.fontColor = .white
        buttonLabel.verticalAlignmentMode = .center
        buttonLabel.position = CGPoint(x: 0, y: 0)
        continueButton.addChild(buttonLabel)
        
        addChild(continueButton)
        
        // Add animations
        animateUI()
    }
    
    private func animateUI() {
        // Scale animation for title
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.3)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.2)
        let sequence = SKAction.sequence([scaleUp, scaleDown])
        
        enumerateChildNodes(withName: "//SKLabelNode") { node, _ in
            node.setScale(0)
            node.run(SKAction.sequence([
                SKAction.wait(forDuration: 0.2),
                SKAction.scale(to: 1.0, duration: 0.3)
            ]))
        }
        
        if let continueButton = childNode(withName: "continueButton") {
            continueButton.setScale(0)
            continueButton.run(SKAction.sequence([
                SKAction.wait(forDuration: 0.5),
                SKAction.scale(to: 1.0, duration: 0.3)
            ]))
        }
    }
    
    func handleTap(at point: CGPoint) {
        let nodes = self.nodes(at: point)
        if nodes.contains(where: { $0.name == "continueButton" }) {
            onContinue()
        }
    }
}
