//W//  GameContext.swift
//  Test
// 
//  Created by Hyung Lee on 10/20/24.
//

import Combine
import GameplayKit
import SwiftUI

class WGGameContext: GameContext {
    var gameScene: WGGameScene {
        scene as? WGGameScene
    }
    let gameMode: GameModeType
    var gameInfo: WGGameInfo
    var layoutInfo: WGLayoutInfo = .init(screenSize: .zero)
    
    private(set) var stateMachine: GKStateMachine?
    
    init
}
