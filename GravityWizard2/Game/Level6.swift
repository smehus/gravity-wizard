//
//  Level6.swift
//  GravityWizard2
//
//  Created by scott mehus on 8/3/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit

/// This whole enum was a bad idea! Whatever, move on
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
        let sprite = GroundNode(texture: texture, size: CGSize(width: textureSize, height: textureSize))
        
        return sprite
    }
    
    func nextSlide(sceneSize: CGSize) -> (IcePosition, SKSpriteNode)? {
        guard currentPos() < sceneSize.height else { return nil }
        let textureSize = sceneSize.width * 0.75
        
        var nextPosition: IcePosition
        let sprite = GroundNode(texture: nextTexture(), size: CGSize(width: textureSize, height: textureSize))
        
        
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
        return 5
    }
    
    override var xConstraintMultiplier: CGFloat {
        return 1
    }
    
    override var totalSceneSize: CGSize {
        guard let scene = scene else { return CGSize.zero }
        let halfWidth = scene.size.width / 2
        let halfHeight = scene.size.height / 2
        // xConstraintMultiplier is the multipier for half scene segments - specifically for constraints.
        // Kinda weird but whatever
        let totalWidth = (halfWidth * xConstraintMultiplier) + halfWidth
        let totalHeight = (halfHeight * yConstraintMultiplier) + halfHeight
        return CGSize(width: totalWidth, height: totalHeight)
    }
    
    private var maxYPosition: CGFloat {
        let cameraPosition = convert(camera!.position, from: camera!.parent!)
        let returnValue = cameraPosition.y + (scene!.size.height / 2)
        return returnValue
    }
    
    private var lastPlatformPosition: CGFloat?
    private var lastPosition: IcePosition?
    private var lastSnowBallTime: TimeInterval?
    private struct Constants {
        static let SNOW_BALL_FREQ: TimeInterval = 5
    }
    
    // MARK: - Super Functions
    
    override func setupNodes() {
        super.setupNodes()
        particleFactory.addWinterSnowyBackground(scene: self)
    }
    
    override func update(levelWith currentTime: TimeInterval, delta: TimeInterval) {
        populatePlatforms()
        generateBall(time: currentTime)
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

///
/// Snowballs
///

extension Level6 {
    
    private func generateBall(time: TimeInterval) {
        switch lastSnowBallTime {
        case .none:
            break
        case .some(let lastTime):
            guard lastTime < (time - Constants.SNOW_BALL_FREQ) else { return }
        }
        
        
        let snowball = SnowBall.generate()
        snowball.position = CGPoint(x: totalSceneSize.width / 2, y: totalSceneSize.height)
        addChild(snowball)
        
        lastSnowBallTime = time
    }
}

///
/// Platforms
///

extension Level6 {
    
    private func populatePlatforms() {
        switch lastPosition {
        case .none:
            generateInitialPlatform()
        case .some(let model):
            generatePlatform(slideModel: model)
        }
    }
    
    private func generatePlatform(slideModel: IcePosition) {
        guard let nextSlideModel = slideModel.nextSlide(sceneSize: totalSceneSize) else {
            return
        }
        
        ///
        /// Generate slides - flipping each side
        ///
        
        let nextSlide = nextSlideModel.1
        switch nextSlideModel.0 {
        case .left(let dy):
            nextSlide.position = CGPoint(x: nextSlide.size.width / 2 , y: dy)
        case .right(let dy):
            nextSlide.position = CGPoint(x: totalSceneSize.width - (nextSlide.size.width / 2), y: dy)
        }
        
        addChild(nextSlide)
        lastPosition = nextSlideModel.0
    }
    
    private func generateInitialPlatform() {
        guard  lastPosition == nil else {
            return
        }
        
        ///
        /// Create Initial Slider
        ///
        
        let newSlide = IcePosition.right(dy: 0).currentSprite(sceneSize: totalSceneSize)
        newSlide.position = CGPoint(x: totalSceneSize.width - (newSlide.size.width / 2), y: newSlide.size.height / 2)
        
        addChild(newSlide)
        lastPosition = IcePosition.right(dy: newSlide.size.height / 2)
    
    }
}
