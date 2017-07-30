//
//  Level5.swift
//  GravityWizard2
//
//  Created by scott mehus on 7/30/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit

final class Level5: GameScene {
    
    private var maxXPosition: CGFloat {
        let cameraPosition = convert(camera!.position, from: camera!.parent!)
        return cameraPosition.x + (scene!.size.width / 2)
    }
    
    // MARK: Super Methods
    
    var currentLevel: Level {
        return .five
    }
    
    override var shouldAddScenePhysicsEdge: Bool {
        return false
    }
    
    override var yConstraintMultiplier: CGFloat {
        return 1
    }
    
    override var xConstraintMultiplier: CGFloat {
        return 5
    }
    
    override func setupNodes() {
        super.setupNodes()
        anchorPoint = CGPoint(x: 0, y: 0)
    }
    
    override func update(levelWith currentTime: TimeInterval, delta: TimeInterval) {
        roseCheck()
        let t = maxXPosition
    }
    
    private func roseCheck() {
        guard let rose = rose else { return }
        let rosePosition = convert(rose.position, from: rose.parent!)
        
        if rosePosition.y < 0 {
            gameOver()
        }
    }
    
    private func populatePlatforms() {
        
    }
    
    private func generatePlatform(at position: CGPoint) {
        guard
            let platformScene = SKScene(fileNamed: "CollapsablePlatform"),
            let platformNode = platformScene.childNode(withName: "platform") as? SKNode
        else {
            conditionFailure(with: "Failed to init collapsable platform")
            return
        }
        
        platformNode.position = position
        platformNode.zPosition = 10
        addChild(platformNode)
    }
}

// MARK: - End Level


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
