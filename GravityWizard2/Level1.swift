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
    
    override var shouldAddScenePhysicsEdge: Bool {
        return true
    }
    
    /// Sprites
    fileprivate var light: SKNode?
    fileprivate var levelComplete: SKNode?
    
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
        setupLightAnimation()
    }
    
    fileprivate func setupLightAnimation() {
        light = childNode(withName: "FollowLight")
        
        guard
            let rose = rose,
            let complete = levelComplete
        else {
            assertionFailure("Failed to load rose")
            return
        }
        light?.position = complete.position
        let finalPosition = convert(rose.position, from: rose.parent!)
        let action = SKAction.move(to: finalPosition, duration: 2.0)
        light?.run(action)
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
        levelComplete = completeNode
    }
}

extension Level1 {
    override func didSimulatePhysics() {
        if !isRunningStartingAnimation {
            updateFollowNodePosition(followNode: light, originNode: rose)
        }
    }
}
