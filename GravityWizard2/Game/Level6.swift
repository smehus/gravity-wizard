//
//  Level6.swift
//  GravityWizard2
//
//  Created by scott mehus on 8/3/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit

enum IcePosition {
    case left(dy: CGFloat)
    case right(dy: CGFloat)
    
    func nextSlide() -> (IcePosition, SKSpriteNode)? {
        var nextPosition: IcePosition
        switch self {
        case .left(let dy):
            nextPosition = .right(dy: dy + nextTexture().size().height)
        case .right(let dy):
            nextPosition = .left(dy: dy + nextTexture().size().height)
        }
        
        let sprite = SKSpriteNode(texture: nextTexture(), size: nextTexture().size())
        return (nextPosition, sprite)
    }
    
    func nextTexture() -> SKTexture {
        switch self {
        case .left:
            return SKTexture(image: #imageLiteral(resourceName: "ice-slide-r"))
        case .right:
            return SKTexture(image: #imageLiteral(resourceName: "ice-slide-l"))
        }
    }
}

final class Level6: GameScene {
    
    // MARK: Super Properties
    
    var currentLevel: Level {
        return .six
    }
    
    override var shouldAddScenePhysicsEdge: Bool {
        return false
    }
    
    override var yConstraintMultiplier: CGFloat {
        return 6
    }
    
    override var xConstraintMultiplier: CGFloat {
        return 1
    }
    
    override var totalSceneSize: CGSize {
        guard let scene = scene else { return CGSize.zero }
        let halfScene = scene.size.width / 2
        // xConstraintMultiplier is the multipier for half scene segments - specifically for constraints.
        // Kinda weird but whatever
        let totalWidth = (halfScene * xConstraintMultiplier) + halfScene
        return CGSize(width: totalWidth, height: scene.size.height)
    }
    
    private var maxYPosition: CGFloat {
        let cameraPosition = convert(camera!.position, from: camera!.parent!)
        let returnValue = cameraPosition.y + (scene!.size.height / 2)
        return returnValue
    }
    
    private var lastPlatformPosition: CGFloat?
    
    // MARK: - Super Functions
    
    override func setupNodes() {
        super.setupNodes()
    }
    
    override func update(levelWith currentTime: TimeInterval, delta: TimeInterval) {
        populatePlatforms()
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

extension Level6 {
    
    private func populatePlatforms() {
        
    }
}
