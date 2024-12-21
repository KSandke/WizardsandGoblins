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
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            // Background image
            Image("Background")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
            
            // Content overlay
            VStack(spacing: 30) {
                // Title
                Text("Wizards & Goblins")
                    .font(.custom("HelveticaNeue-Bold", size: 48))
                    .foregroundColor(.white)
                    .shadow(color: .black, radius: 2, x: 2, y: 2)
                    .padding(.top, 50)
                
                Spacer()
                
                // Start Game Button
                Button(action: {
                    SoundManager.shared.playSound("button_click")
                    showGameView = true
                }) {
                    Text("Start Game")
                        .font(.custom("HelveticaNeue-Bold", size: 24))
                        .padding(.horizontal, 40)
                        .padding(.vertical, 15)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.blue.opacity(0.8))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.white, lineWidth: 2)
                                )
                        )
                        .foregroundColor(.white)
                        .shadow(radius: 5)
                }
                .buttonStyle(ScaleButtonStyle())
                
                // Version number
                Text("v1.0")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.bottom, 20)
            }
        }
        .fullScreenCover(isPresented: $showGameView) {
            GameView()
        }
    }
}

// Custom button style for scale animation
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    MainMenuView()
}