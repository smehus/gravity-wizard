//
//  Level1.swift
//  GravityWizard2
//
//  Created by scott mehus on 12/30/16.
//  Copyright © 2016 scott mehus. All rights reserved.
//

import SpriteKit
import GameplayKit

fileprivate struct Names {
    static let levelComplete = "level-complete"
}

fileprivate struct Physics {
    struct LevelComplete {
        static let categoryBitMask = PhysicsCategory.LevelComplete
        static let collisionBitMask = PhysicsCategory.None
        static let contactTest = PhysicsCategory.Hero
    }
}

class Level1: GameScene {

    var currentLevel: Level {
        return .one
    }
    
    override func levelCompleted() {
        guard let successLevel = LevelCompleteLabel.createLabel(), let camera = camera else { return }
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
    
    func runZoomOutAction() {
        guard
            let rose = rose,
            let camera = camera,
            !isIpad()
        else {
                return
        }
        
        let zoomAction = SKAction.scale(to: 1.0, duration: 2.0)
        let scaleAction = SKAction.customAction(withDuration: 2.0) { _ in
            let playerConstraint = SKConstraint.distance(SKRange(constantValue: 0), to: rose)
            camera.constraints = [playerConstraint, self.cameraEdgeConstraint(with: camera.xScale, cy: camera.yScale)]
        }
        
        camera.run(SKAction.group([zoomAction, scaleAction]))
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
    
    override func setupNodes() {
        super.setupNodes()
        setupLevelCompleteNode()
    }
    
    fileprivate func setupLevelCompleteNode() {
        guard
            let completeNode = childNode(withName: "//\(Names.levelComplete)"),
            let completeBody = completeNode.physicsBody
        else {
            assertionFailure("Level 1 - Missing level complete node")
            return
        }
        
        completeBody.categoryBitMask = Physics.LevelComplete.categoryBitMask
        completeBody.collisionBitMask = Physics.LevelComplete.collisionBitMask
        completeBody.contactTestBitMask = Physics.LevelComplete.contactTest
    }
}

extension Level1 {
    override func didSimulatePhysics() {
        updateFollowNodePosition(followNode: light, originNode: rose)
    }
}
