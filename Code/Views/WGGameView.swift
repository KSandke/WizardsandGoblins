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
    @Environment(\.dismiss) private var dismiss
    
    var scene: SKScene {
        let scene = GameScene()
        scene.size = CGSize(width: UIScreen.main.bounds.width, 
                           height: UIScreen.main.bounds.height)
        scene.scaleMode = .resizeFill
        return scene
    }

    var body: some View {
        SpriteView(scene: scene)
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                setupNotificationObserver()
            }
    }
    
    private func setupNotificationObserver() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("ReturnToMainMenu"),
            object: nil,
            queue: .main
        ) { _ in
            dismiss()
        }
    }
}

#Preview {
    GameView()
}
