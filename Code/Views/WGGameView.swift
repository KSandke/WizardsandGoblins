//
//  WGGameView.swift
//  WizardsandGoblins
//
//  Created by Kevin Sandke on 10/24/24.
//
import SwiftUI
import SpriteKit
import GameplayKit

struct GameView: View {
    var scene: SKScene {
        let scene = GameScene()
        scene.size = CGSize(width: 400, height: 600) // Customize for screen size
        scene.scaleMode = .resizeFill
        return scene
    }

    var body: some View {
        SpriteView(scene: scene)
            .edgesIgnoringSafeArea(.all)
    }
}

