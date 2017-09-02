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
    case platformLayer = "platform-layer"
    case backgroundLayer = "background-layer"
}

class Level7: GameScene {
    
    private var world: SKNode!
    private var targetLayer: TargetLayer?
    private var platformLayer: PlatformLayer?
    private var backgroundLayer: SKNode?
    
    var currentLevel: Level {
        return .seven
    }
    
    override var shouldAddScenePhysicsEdge: Bool {
        return false
    }
    
    override var yConstraintMultiplier: CGFloat {
        return 3
    }
    
    override var xConstraintMultiplier: CGFloat {
        return 1
    }
    
    var cameraOffset: CGPoint {
        let y = camera!.position.y - (playableHeight / 2)
        let x = camera!.position.x - (frame.size.width / 2)
        return CGPoint(x: x, y: y)
    }
    
    override var totalSceneSize: CGSize {
        let width = size.width * xConstraintMultiplier
        let height = playableHeight * yConstraintMultiplier
        return CGSize(width: width, height: height)
    }
    
    override func setupNodes() {
        super.setupNodes()
        
        guard
            let background = childNode(withName: Keys.backgroundLayer.rawValue),
            let target = childNode(withName: Keys.targetLayer.rawValue) as? TargetLayer,
            let platform = childNode(withName: Keys.platformLayer.rawValue) as? PlatformLayer
        else {
            conditionFailure(with: "Failed to setup nodes")
            return
        }
        
        backgroundLayer = background
        targetLayer = target
        platformLayer = platform
    }

    override func update(levelWith currentTime: TimeInterval, delta: TimeInterval) {
        targetLayer?.update(levelWith: currentTime, delta: delta)
        backgroundLayer?.position = cameraOffset
    }
    
    override func didSimulatePhysicsForLevel() {
        backgroundLayer?.position = cameraOffset
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
