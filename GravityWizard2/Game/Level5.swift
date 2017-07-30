//
//  Level5.swift
//  GravityWizard2
//
//  Created by scott mehus on 7/30/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit

final class Level5: GameScene {
    
    // MARK: Super Methods
    
    var currentLevel: Level {
        return .five
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
    }
}

// MARK: - End Level

///
/// Level 5 End Level
///

extension Level5 {
    @objc override func levelCompleted() {
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
    
    @objc override func gameOver() {
        
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
