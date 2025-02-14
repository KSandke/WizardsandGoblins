import SpriteKit
import Foundation

class ScoreScreen: SKNode {
    private let playerState: PlayerState
    private let waveNumber: Int
    private let onContinue: () -> Void
    private let size: CGSize
    private let damageTaken: CGFloat
    private let perfectWaveBonus: Bool
    
    private var potionEffectBar: SKShapeNode?
    private var potionEffectLabel: SKLabelNode?
    
    init(size: CGSize, playerState: PlayerState, waveNumber: Int, damageTaken: CGFloat, perfectWaveBonus: Bool, onContinue: @escaping () -> Void) {
        self.size = size
        self.playerState = playerState
        self.waveNumber = waveNumber
        self.damageTaken = damageTaken
        self.perfectWaveBonus = perfectWaveBonus
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
        scoreLabel.position = CGPoint(x: size.width/2, y: size.height * 0.55)
        addChild(scoreLabel)
        
        // Coins earned this wave
        let coinsLabel = SKLabelNode(fontNamed: "HelveticaNeue")
        coinsLabel.text = "Coins: \(playerState.coins)"
        coinsLabel.fontSize = 28
        coinsLabel.fontColor = .yellow
        coinsLabel.position = CGPoint(x: size.width/2, y: size.height * 0.5)
        addChild(coinsLabel)
        
        // Castle damage taken
        let damageLabel = SKLabelNode(fontNamed: "HelveticaNeue")
        damageLabel.text = "Castle Damage Taken: \(Int(damageTaken))"
        damageLabel.fontSize = 28
        damageLabel.fontColor = .red
        damageLabel.position = CGPoint(x: size.width/2, y: size.height * 0.4)
        addChild(damageLabel)
        
        // Add highest combo display after damage label
        let comboLabel = SKLabelNode(fontNamed: "HelveticaNeue")
        comboLabel.text = "Highest Combo: \(playerState.highestCombo)"
        comboLabel.fontSize = 28
        comboLabel.fontColor = .yellow
        comboLabel.position = CGPoint(x: size.width/2, y: size.height * 0.35)
        addChild(comboLabel)
        
        // Castle health remaining
        let healthLabel = SKLabelNode(fontNamed: "HelveticaNeue")
        let healthPercentage = Int((playerState.castleHealth / playerState.maxCastleHealth) * 100)
        healthLabel.text = "Castle Health: \(healthPercentage)%"
        healthLabel.fontSize = 28
        healthLabel.fontColor = healthPercentage > 50 ? .green : .red
        healthLabel.position = CGPoint(x: size.width/2, y: size.height * 0.3)
        addChild(healthLabel)
        
        // Continue to shop button
        let continueButton = SKShapeNode(rectOf: CGSize(width: 200, height: 50), cornerRadius: 10)
        continueButton.fillColor = .blue
        continueButton.strokeColor = .white
        continueButton.position = CGPoint(x: size.width/2, y: size.height * 0.2)
        continueButton.name = "continueButton"
        
        let buttonLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        buttonLabel.text = "Continue to Shop"
        buttonLabel.fontSize = 20
        buttonLabel.fontColor = .white
        buttonLabel.verticalAlignmentMode = .center
        buttonLabel.position = CGPoint(x: 0, y: 0)
        continueButton.addChild(buttonLabel)
        
        addChild(continueButton)
        
        // Add perfect wave bonus display if earned
        if perfectWaveBonus {
            let bonusLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
            bonusLabel.text = "PERFECT WAVE BONUS!"
            bonusLabel.fontSize = 32
            bonusLabel.fontColor = .yellow
            bonusLabel.position = CGPoint(x: size.width/2, y: size.height * 0.7)
            addChild(bonusLabel)
            
            let bonusDetailsLabel = SKLabelNode(fontNamed: "HelveticaNeue")
            bonusDetailsLabel.text = "+50 points, +10 coins"
            bonusDetailsLabel.fontSize = 24
            bonusDetailsLabel.fontColor = .yellow
            bonusDetailsLabel.position = CGPoint(x: size.width/2, y: size.height * 0.65)
            addChild(bonusDetailsLabel)
        }
        
        // Potion Effect Bar
        let barWidth: CGFloat = 200
        let barHeight: CGFloat = 20
        potionEffectBar = SKShapeNode(rectOf: CGSize(width: barWidth, height: barHeight), cornerRadius: 5)
        potionEffectBar?.fillColor = .blue
        potionEffectBar?.strokeColor = .white
        potionEffectBar?.position = CGPoint(x: size.width - barWidth / 2 - 20, y: size.height * 0.6)
        potionEffectBar?.isHidden = true
        addChild(potionEffectBar!)

        // Potion Effect Label
        potionEffectLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        potionEffectLabel?.fontSize = 14
        potionEffectLabel?.fontColor = .white
        potionEffectLabel?.position = CGPoint(x: 0, y: -barHeight / 2 - 10)
        potionEffectLabel?.verticalAlignmentMode = .center
        potionEffectBar?.addChild(potionEffectLabel!)
        
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

