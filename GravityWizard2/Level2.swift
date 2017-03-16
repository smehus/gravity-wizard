//
//  Level2.swift
//  GravityWizard2
//
//  Created by scott mehus on 1/7/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit

fileprivate struct Names {
    static let movingPlatform = "MovingPlatformContainer"
}

fileprivate struct Constants {
    static let platformVelocityX: CGFloat = 300
}

class Level2: GameScene {
    
    var currentLevel: Level {
        return .two
    }
    
    fileprivate var movingPlatform: StonePlatform?
    
    override func setupNodes() {
        super.setupNodes()
        setupPlatform()
    }
    
    override func update(subClassWith currentTime: TimeInterval) {
        movingPlatform?.animate(with: Constants.platformVelocityX)
    }
    
    fileprivate func setupPlatform() {
        guard
            let platform = childNode(withName: "//\(Names.movingPlatform)") as? StonePlatform
        else {
            assertionFailure("Failed to find moving platform node")
            return
        }
          
        movingPlatform = platform
    }
}

extension Level2 {
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
    
    override func gameOver() {
        guard let gameOverLabel = LevelCompleteLabel.createLabel(with: "Game Over"), let camera = camera else { return }
        gameOverLabel.position = convert(gameOverLabel.position, from: camera)
        gameOverLabel.scaleAsPoint = CGPoint(x: 2.0, y: 2.0)
        gameOverLabel.move(toParent: camera)
        
        runZoomOutAction()
        
        let presentScene = SKAction.afterDelay(2.0) {
            guard let reloadLevel = self.currentLevel.levelScene() else {
                assertionFailure("Failed to load level scene on game over")
                return
            }
            reloadLevel.scaleMode = self.scaleMode
            let transition = SKTransition.doorsOpenHorizontal(withDuration: 1.0)
            self.view?.presentScene(reloadLevel, transition: transition)
            
        }
        
        run(presentScene)
    }
}
