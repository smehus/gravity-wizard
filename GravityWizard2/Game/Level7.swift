//
//  Level7.swift
//  GravityWizard2
//
//  Created by scott mehus on 9/2/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit

private enum Keys: String {
    case world = "world"
    case targetLayer = "target-layer"
    case playerLayer = "player-layer"
}

class Level7: GameScene {
    
    private var world: SKNode!
    private var targetLayer: SKNode!
    private var playerLayer: SKNode!
    
    var currentLevel: Level {
        return .seven
    }
    
    override var shouldAddScenePhysicsEdge: Bool {
        return false
    }
    
    override var yConstraintMultiplier: CGFloat {
        return 1
    }
    
    override var xConstraintMultiplier: CGFloat {
        return 1
    }
    
    override var totalSceneSize: CGSize {
        return size
    }
    
    override func setupNodes() {
        super.setupNodes()
        
        guard
            let worldNode = childNode(withName: Keys.world.rawValue),
            let target = worldNode.childNode(withName: Keys.targetLayer.rawValue),
            let player = worldNode.childNode(withName: Keys.playerLayer.rawValue)
        else {
            conditionFailure(with: "Failed to setup nodes")
            return
        }
        
        world = worldNode
        targetLayer = target
        playerLayer = player
    }

    override func update(levelWith currentTime: TimeInterval, delta: TimeInterval) {
        
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
