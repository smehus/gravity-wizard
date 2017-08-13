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
    
    func currentTexture() -> SKTexture {
        switch self {
        case .left:
            return SKTexture(image: #imageLiteral(resourceName: "ice-slide-l"))
        case .right:
            return SKTexture(image: #imageLiteral(resourceName: "ice-slide-r"))
        }
    }
    
    func currentPos() -> CGFloat {
        switch self {
        case .right(let dy), .left(let dy):
            return dy
        }
    }
    
    func currentSprite(sceneSize: CGSize) -> SKSpriteNode {
        let texture = currentTexture()
        let textureSize = sceneSize.width * 0.75
        let sprite = SKSpriteNode(texture: texture, size: CGSize(width: textureSize, height: textureSize))
        sprite.anchorPoint = CGPoint(x: 0, y: 0)
        return sprite
    }
    
    func nextSlide(sceneSize: CGSize) -> (IcePosition, SKSpriteNode)? {
        guard currentPos() < sceneSize.height else { return nil }
        let textureSize = sceneSize.width * 0.75
        
        var nextPosition: IcePosition
        let sprite = SKSpriteNode(texture: nextTexture(), size: CGSize(width: textureSize, height: textureSize))
        sprite.anchorPoint = CGPoint(x: 0, y: 0)
        
        switch self {
        case .left(let dy):
            nextPosition = .right(dy: dy + textureSize)
        case .right(let dy):
            nextPosition = .left(dy: dy + textureSize)
        }
        
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
    private var lastPosition: IcePosition?
    
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
        
        if let slideModel = lastPosition, let nextSlideModel = slideModel.nextSlide(sceneSize: totalSceneSize) {
    
            ///
            /// Generate slides - flipping each side
            ///
            
            let nextSlide = nextSlideModel.1
            switch nextSlideModel.0 {
            case .left(let dy):
                nextSlide.position = CGPoint(x: 0, y: dy)
            case .right(let dy):
                nextSlide.position = CGPoint(x: totalSceneSize.width - nextSlide.size.width, y: dy)
            }
            
            addChild(nextSlide)
            lastPosition = nextSlideModel.0
            
        } else if lastPosition == nil {
            
            ///
            /// Create Initial Slider
            ///
            
            let initialPosition = IcePosition.right(dy: 0)
            let newSlide = initialPosition.currentSprite(sceneSize: totalSceneSize)
            newSlide.position = CGPoint(x: totalSceneSize.width - newSlide.size.width, y: 0)
            
            addChild(newSlide)
            lastPosition = initialPosition
        }
    }
}
