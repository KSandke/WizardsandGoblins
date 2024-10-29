//
//  WGGameScene.swift
//  WizardsandGoblins
//
//  Created by Kevin Sandke on 10/24/24.
//

import SpriteKit
import GameplayKit
import Foundation

extension CGVector{
    func normalized() -> CGVector {
        let length = sqrt(dx * dx + dy * dy)
        return length > 0 ? CGVector(dx: dx / length, dy: dy / length) : .zero
    }
}

class GameScene: SKScene {
    
    // Wizards
    var playerOne: SKSpriteNode!
    var playerTwo: SKSpriteNode!
    
    // Mana Info
    var playerOneMana: CGFloat = 100
    var playerTwoMana: CGFloat = 100
    let maxMana: CGFloat = 100
    let spellCost: CGFloat = 20
    let manaRegenRate: CGFloat = 5
    
    //Mana bars
    var playerOneManaBar: SKShapeNode!
    var playerTwoManaBar: SKShapeNode!
    var playerOneManaFill: SKShapeNode!
    var playerTwoManaFill: SKShapeNode!
    
    override func didMove(to view: SKView) {
        backgroundColor = .green
        
        wizardSetup()
        manaSetup()
        
        let regenerateMana = SKAction.run {
            [weak self] in self?.regenerateMana()
        }
        let wait = SKAction.wait(forDuration: 1.0)
        let regenSequence = SKAction.sequence([wait, regenerateMana])
        run(SKAction.repeatForever(regenSequence))
    }
    
    
    func wizardSetup() {
        
        // Left Wizard
        playerOne = SKSpriteNode(imageNamed: "Wizard1")
        playerOne.size = CGSize(width: 75, height: 75)
        playerOne.position = CGPoint(x: size.width * 0.25, y: 50)
        addChild(playerOne)
        
        //Right Wizard
        playerTwo = SKSpriteNode(imageNamed: "Wizard2")
        playerTwo.size = CGSize(width: 75, height: 75)
        playerTwo.position = CGPoint(x: size.width * 0.75, y: 50)
        addChild(playerTwo)
    }
    
    func manaSetup() {
        // Player One Mana Bar (Background)
        playerOneManaBar = SKShapeNode(rectOf: CGSize(width: 100, height: 10))
        playerOneManaBar.fillColor = .gray
        playerOneManaBar.strokeColor = .black
        playerOneManaBar.position = CGPoint(x: playerOne.position.x, y: playerOne.position.y - 50)
        addChild(playerOneManaBar)
        
        // Player One Mana Fill
        playerOneManaFill = SKShapeNode(rectOf: CGSize(width: 100, height: 10))
        playerOneManaFill.fillColor = .blue
        playerOneManaFill.strokeColor = .clear
        playerOneManaFill.position = playerOneManaBar.position
        addChild(playerOneManaFill)
        
        // Player Two Mana Bar (Background)
        playerTwoManaBar = SKShapeNode(rectOf: CGSize(width: 100, height: 10))
        playerTwoManaBar.fillColor = .gray
        playerTwoManaBar.strokeColor = .black
        playerTwoManaBar.position = CGPoint(x: playerTwo.position.x, y: playerTwo.position.y - 50)
        addChild(playerTwoManaBar)
        
        // Player Two Mana Fill
        playerTwoManaFill = SKShapeNode(rectOf: CGSize(width: 100, height: 10))
        playerTwoManaFill.fillColor = .blue
        playerTwoManaFill.strokeColor = .clear
        playerTwoManaFill.position = playerTwoManaBar.position
        addChild(playerTwoManaFill)
        
        updateManaBars()
    }
    func regenerateMana() {
        playerOneMana = min(maxMana, playerOneMana + manaRegenRate)
        playerTwoMana = min(maxMana, playerTwoMana + manaRegenRate)
        updateManaBars()
    }
    
    func updateManaBars() {
        // Update the width of the mana fill bars based on current mana
        playerOneManaFill.xScale = playerOneMana / maxMana
        playerTwoManaFill.xScale = playerTwoMana / maxMana
    }
    
    func castSpell(from castingPlayer: SKSpriteNode, to location: CGPoint) -> Bool {
        // Check which player is casting and get their mana
        let playerMana = castingPlayer == playerOne ? playerOneMana : playerTwoMana
        
        // Check if enough mana
        if playerMana < spellCost {
            return false
        }
        
        // Deduct mana
        if castingPlayer == playerOne {
            playerOneMana -= spellCost
        } else {
            playerTwoMana -= spellCost
        }
        
        // Create spell
        let spell = SKSpriteNode(imageNamed: "spell1")
        spell.size = CGSize(width: 50, height: 50)
        spell.position = castingPlayer.position
        addChild(spell)
        
        // Calculate direction
        let dx = location.x - castingPlayer.position.x
        let dy = location.y - castingPlayer.position.y
        
        // Calculate rotation angle (in radians)
        let angle = atan2(dy, dx)
        let angleDegrees = angle * (180 / .pi)
        
        // Rotate spell to face movement direction
        spell.zRotation = angle + .pi/2 + .pi
        
        // Move spell
        let moveAction = SKAction.move(by: CGVector(dx: dx, dy: dy), duration: 1.0)
        spell.run(SKAction.sequence([moveAction, SKAction.removeFromParent()]))
        
        // Update mana display
        updateManaBars()
        return true
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first,
              let p1 = playerOne,
              let p2 = playerTwo else { return }
        
        let touchLocation = touch.location(in: self)
        
        // Calculate distances to each wizard
        let dx1 = touchLocation.x - p1.position.x
        let dy1 = touchLocation.y - p1.position.y
        let dx2 = touchLocation.x - p2.position.x
        let dy2 = touchLocation.y - p2.position.y
        
        let distance1 = sqrt(dx1 * dx1 + dy1 * dy1)
        let distance2 = sqrt(dx2 * dx2 + dy2 * dy2)
        
        // Determine primary and backup casters based on distance
        let (primaryCaster, backupCaster) = distance1 < distance2 ?
        (p1, p2) : (p2, p1)
        
        // Try to cast with primary caster, if fails try backup caster
        if !castSpell(from: primaryCaster, to: touchLocation) {
            _ = castSpell(from: backupCaster, to: touchLocation)
        }
    }
}
