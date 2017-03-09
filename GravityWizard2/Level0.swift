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
    
    override func levelCompleted() {
        isPaused = true
        guard let successLevel = LevelCompleteLabel.createLabel(), let camera = camera else {
            assertionFailure("Failed to create level complete lable")
            return
        }
        successLevel.position = convert(successLevel.position, from: camera)
        successLevel.scaleAsPoint = CGPoint(x: 2.0, y: 2.0)
        successLevel.move(toParent: camera)
        
        let presentScene = SKAction.afterDelay(2.0) {
            guard let nextLevel = self.currentLevel.nextLevel()?.levelScene() else { return }
            nextLevel.scaleMode = self.scaleMode
            let transition = SKTransition.doorsOpenHorizontal(withDuration: 1.0)
            self.view?.presentScene(nextLevel, transition: transition)
            
        }
        
        run(presentScene)
    }
}

