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
    static let breakableStoneStructure = "BreakableStoneStructure"
}

fileprivate struct Constants {
    static let platformVelocityX: CGFloat = 300
}

@objcMembers
final class Level2: GameScene {
    
    var currentLevel: Level {
        return .two
    }
    
    override var shouldAddScenePhysicsEdge: Bool {
        return true
    }
    
    fileprivate var movingPlatform: StonePlatform?
    fileprivate var destructableStoneStructure: BreakableStoneStructure?
    
    override func setupNodes() {
        super.setupNodes()
        setupPlatform()
        setupBreakableStoneStructure()
    }
    
    override func update(levelWith currentTime: TimeInterval, delta: TimeInterval) {
        movingPlatform?.animate(with: Constants.platformVelocityX)
    }
    
    override func contactDidBegin(with contact: SKPhysicsContact) {
        super.contactDidBegin(with: contact)
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
                assertionFailure("Failed to load level scene on game over")
                return
            }
            reloadLevel.scaleMode = self.scaleMode
            let transition = SKTransition.doorsOpenHorizontal(withDuration: 1.0)
            self.view?.presentScene(reloadLevel, transition: transition)
            
        }
        
        run(presentScene)
    }
    
    fileprivate func setupBreakableStoneStructure() {
        guard
            let structure = childNode(withName: "//\(Names.breakableStoneStructure)") as? BreakableStoneStructure
            else {
                assertionFailure("Failed to get stone structure")
                return
        }
        
        destructableStoneStructure = structure
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
