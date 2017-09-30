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
        static let labels = "labels"
        static let youWin = "labels/youwin"
        static let thanks = "labels/thanks"
    }
    
    static func instantiate() -> GameCompleted? {
        return SKScene(fileNamed: String(describing: GameCompleted.self)) as! GameCompleted
    }
    
    private var youWinLabel: SKLabelNode?
    private var thanksLabel: SKLabelNode?
    private var labelsContainer: SKNode?
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        guard
            let labels = childNode(withName: Names.labels),
            let youWin = childNode(withName: Names.youWin) as? SKLabelNode,
            let thanks = childNode(withName: Names.thanks) as? SKLabelNode
        else {
            conditionFailure(with: "Failed to resolve nodes")
            return
        }
        
        labelsContainer = labels
        youWinLabel = youWin
        thanksLabel = thanks
        
        startAnimation()
    }
    
    private func startAnimation() {
        let moveAction = SKAction.moveBy(x: 0, y: -(size.height * 2), duration: 5.0)
        let menuAction  = SKAction.run {
            let menu = MainMenu.instantiate()
            menu?.scaleMode = self.scaleMode
            let transition = SKTransition.doorsCloseHorizontal(withDuration: 2.0)
            self.view?.presentScene(menu!, transition: transition)
        }
        
        labelsContainer?.run(SKAction.sequence([moveAction, menuAction]))
    }
}
