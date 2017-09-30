//
//  GameCompleted.swift
//  GravityWizard2
//
//  Created by scott mehus on 9/30/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit

class GameCompleted: SKScene {
    
    struct Names {
        static let youWin = "labels/youwin"
        static let thanks = "labels/thanks"
    }
    
    static func instantiate() -> GameCompleted {
        return SKScene(fileNamed: String(describing: GameCompleted.self)) as! GameCompleted
    }
    
    private var youWinLabel: SKLabelNode?
    private var thanksLabel: SKLabelNode?
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        guard
            let youWin = childNode(withName: Names.youWin) as? SKLabelNode,
            let thanks = childNode(withName: Names.thanks) as? SKLabelNode
        else {
            conditionFailure(with: "Failed to resolve nodes")
            return
        }
        
        youWinLabel = youWin
        thanksLabel = thanks
        
        startAnimation()
    }
    
    private func startAnimation() {
        
    }
    
    private func completed() {
        
    }
}
