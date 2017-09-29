//
//  Level4.swift
//  GravityWizard2
//
//  Created by scott mehus on 6/9/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit

final class Level4: GameScene {
    
    var currentLevel: Level {
        return .four
    }
    
    override var totalSceneSize: CGSize {
        guard let background = childNode(withName: "//background") else {
            return CGSize(width: 0, height: 0)
        }
        
        return CGSize(width: background.frame.size.width, height: background.frame.size.height)
    }
    
    override var shouldAddScenePhysicsEdge: Bool {
        return false
    }
    
    override var yConstraintMultiplier: CGFloat {
        return 4
    }

    override var xConstraintMultiplier: CGFloat {
        return 5
    }
    
    override func setupNodes() {
        super.setupNodes()
        rose?.MAX_JUMP_COUNT = 3
        // add shaders
    }
    
    override func levelCompleted() {
        guard let successLevel = LevelCompleteLabel.createLabel(), let camera = camera else { return }
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
    
   override func gameOver() {
        
        guard let gameOverLabel = LevelCompleteLabel.createLabel(with: "Game Over"), let camera = camera else { return }
        gameOverLabel.move(toParent: camera)
        gameOverLabel.position = CGPoint.zero
        
        runZoomOutAction()
        let presentScene = SKAction.afterDelay(2.0) {
            guard let reloadLevel = self.currentLevel.levelScene() else {
                self.conditionFailure(with: "Failed to load level scene on game over")
                return
            }
            
            reloadLevel.scaleMode = self.scaleMode
            let transition = SKTransition.doorsOpenHorizontal(withDuration: 1.0)
            self.view?.presentScene(reloadLevel, transition: transition)
            
        }
        
        run(presentScene)
    }
    
}
