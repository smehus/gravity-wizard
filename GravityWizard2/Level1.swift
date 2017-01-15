//
//  Level1.swift
//  GravityWizard2
//
//  Created by scott mehus on 12/30/16.
//  Copyright © 2016 scott mehus. All rights reserved.
//

import SpriteKit
import GameplayKit

class Level1: GameScene {

    var currentLevel: Level {
        return .one
    }
    
    override func levelCompleted() {
        guard let successLevel = LevelCompleteLabel.createLabel(), let scene = scene else { return }
        successLevel.position = scene.zeroAnchoredCenter()
        successLevel.move(toParent: scene)
        
        let presentScene = SKAction.afterDelay(2.0) {
            guard let nextLevel = self.currentLevel.nextLevel()?.levelScene() else { return }
            nextLevel.scaleMode = self.scaleMode
            let transition = SKTransition.doorsOpenHorizontal(withDuration: 1.0)
            self.view?.presentScene(nextLevel, transition: transition)
            
        }
        
        run(presentScene)
    }
}

extension Level1 {
    override func didSimulatePhysics() {
        updateFollowNodePosition(followNode: light, originNode: rose)
    }
}
