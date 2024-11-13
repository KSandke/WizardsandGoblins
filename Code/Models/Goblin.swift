// Model/Goblin.swift
import SpriteKit

class Goblin {
    enum GoblinType {
        case normal
        case small
        case large
    }
    
    let type: GoblinType
    let sprite: SKSpriteNode
    var health: CGFloat
    let maxHealth: CGFloat
    let speed: CGFloat
    let damage: CGFloat
    let healthBar: SKShapeNode
    let healthFill: SKShapeNode
    var isAlive: Bool {
        return health > 0
    }
    
    init(type: GoblinType, position: CGPoint) {
        self.type = type
        
        // Set properties based on type
        switch type {
        case .normal:
            self.maxHealth = 50
            self.speed = 100
            self.damage = 10
        case .small:
            self.maxHealth = 25  // Half of normal
            self.speed = 150     // 1.5x normal
            self.damage = 5      // Half of normal
        case .large:
            self.maxHealth = 100 // 2x normal
            self.speed = 75      // 0.75x normal
            self.damage = 20     // 2x normal
        }
        self.health = maxHealth
        
        // Initialize sprite
        self.sprite = SKSpriteNode(imageNamed: "Goblin1")
        self.sprite.size = CGSize(width: 50, height: 50)
        self.sprite.position = position
        self.sprite.name = "goblin"
        
        // Physics body
        let physicsBody = SKPhysicsBody(rectangleOf: self.sprite.size)
        physicsBody.isDynamic = true
        physicsBody.affectedByGravity = false
        physicsBody.categoryBitMask = 1
        physicsBody.contactTestBitMask = 2
        self.sprite.physicsBody = physicsBody
        
        // Health bar
        let healthBarWidth: CGFloat = 40
        let healthBarHeight: CGFloat = 5
        self.healthBar = SKShapeNode(rectOf: CGSize(width: healthBarWidth, height: healthBarHeight))
        self.healthBar.fillColor = .gray
        self.healthBar.strokeColor = .black
        self.healthBar.position = CGPoint(x: 0, y: self.sprite.size.height/2 + 5)
        
        // Health fill
        self.healthFill = SKShapeNode(rectOf: CGSize(width: healthBarWidth, height: healthBarHeight))
        self.healthFill.fillColor = .red
        self.healthFill.strokeColor = .clear
        self.healthFill.position = self.healthBar.position
        
        // Add health bars as children of goblin
        self.sprite.addChild(self.healthBar)
        self.sprite.addChild(self.healthFill)
    }
    
    func takeDamage(_ amount: CGFloat) {
        self.health -= amount
        if self.health < 0 {
            self.health = 0
        }
        updateHealthBar()
    }
    
    func updateHealthBar() {
        let healthBarWidth: CGFloat = 40
        let healthRatio = self.health / self.maxHealth
        let newWidth = healthBarWidth * healthRatio
        self.healthFill.xScale = healthRatio
        self.healthFill.position = CGPoint(x: self.healthBar.position.x - (healthBarWidth - newWidth) / 2, y: self.healthBar.position.y)
    }
    
    func move(to position: CGPoint, completion: @escaping () -> Void) {
        let distance = self.sprite.position.distance(to: position)
        let duration = TimeInterval(distance / self.speed)
        let moveAction = SKAction.move(to: position, duration: duration)
        let actionSequence = SKAction.sequence([moveAction, SKAction.run(completion)])
        self.sprite.run(actionSequence)
    }
}