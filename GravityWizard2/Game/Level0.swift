//
//  Level0.swift
//  GravityWizard2
//
//  Created by scott mehus on 1/7/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit

class Level0: GameScene {
    
    var currentLevel: Level {
        return .zero
    }
    
    override var shouldAddScenePhysicsEdge: Bool {
        return true
    }
    
    @objc override func levelCompleted() {
        guard let successLevel = LevelCompleteLabel.createLabel(), let camera = camera else {
            assertionFailure("Failed to create level complete lable")
            return
        }
        successLevel.move(toParent: camera)
        successLevel.position = CGPoint.zero
        
        let presentScene = SKAction.afterDelay(2.0) {
            
            guard let nextLevel = self.currentLevel.nextLevel()?.levelScene() else { return }
            nextLevel.scaleMode = self.scaleMode
            let transition = SKTransition.doorsOpenHorizontal(withDuration: 1.0)
            self.view?.presentScene(nextLevel, transition: transition)
            
        }
        
        run(presentScene)
    }
}

