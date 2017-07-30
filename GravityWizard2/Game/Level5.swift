//
//  Level5.swift
//  GravityWizard2
//
//  Created by scott mehus on 7/30/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit

final class Level5: GameScene {
    
    // MARK: Super Properties
    
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
    
    
    // MARK: - Private Properties
    
    private var maxXPosition: CGFloat {
        let cameraPosition = convert(camera!.position, from: camera!.parent!)
        return cameraPosition.x + scene!.size.width
    }
    
    
    private var lastPlatformPosition: CGFloat? {
        didSet {
            print("🐭 setting position \(lastPlatformPosition)")
        }
    }
    
    // MARK: - Super Functions
    
    override func setupNodes() {
        super.setupNodes()
        anchorPoint = CGPoint(x: 0, y: 0)
        lastPlatformPosition = 1000
        populatePlatforms()
    }
    
    override func update(levelWith currentTime: TimeInterval, delta: TimeInterval) {
        roseCheck()
        populatePlatforms()
    }
    
    // MARK: - Private Functions
    
    private func roseCheck() {
        guard let rose = rose else { return }
        let rosePosition = convert(rose.position, from: rose.parent!)
        
        if rosePosition.y < 0 {
            gameOver()
        }
    }
    
    private func populatePlatforms() {
        guard var lastPosition = lastPlatformPosition, lastPosition < maxXPosition else {
            return
        }
        
        while lastPosition < maxXPosition {
            // TODO: Make 300 a random number
            lastPosition += 300
            generatePlatform(at: lastPosition)
            lastPlatformPosition = lastPosition
        }
        
    }
    
    private func generatePlatform(at x: CGFloat) {
        guard
            let platformScene = SKScene(fileNamed: "CollapsablePlatform"),
            let platformNode = platformScene.childNode(withName: "platform")
        else {
            conditionFailure(with: "Failed to init collapsable platform")
            return
        }
        
        let nextPosition = CGPoint(x: x, y: platformScene.size.height/4)
        platformNode.position = nextPosition
        platformNode.zPosition = 10
        platformNode.move(toParent: self)
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
