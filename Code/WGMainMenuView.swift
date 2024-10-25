//
//  WGMainMenuView.swift
//  WizardsandGoblins
//
//  Created by Kevin Sandke on 10/24/24.
//

import SwiftUI
import SpriteKit

struct MainMenuView: View {
    @State private var showGameView = false

    var body: some View {
        ZStack {
            Color.blue.edgesIgnoringSafeArea(.all) // Background color for main menu
            VStack {
                Text("Main Menu")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                
                Button(action: {
                    showGameView = true
                }) {
                    Text("Start Game")
                        .font(.title)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.blue)
                        .cornerRadius(10)
                }
            }
        }
        .fullScreenCover(isPresented: $showGameView) {
            GameView()
        }
    }
}
#Preview {
    MainMenuView()
}