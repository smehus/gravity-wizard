//
//  Level9.swift
//  GravityWizard2
//
//  Created by scott mehus on 9/13/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit

private enum Sprite: SpriteConfiguration {
    case roseFlower
    
    var name: String {
        switch self {
        case .roseFlower: return "rose-flower"
        }
    }
    
    var categoryBitMask: UInt32 {
        switch self {
        case .roseFlower:
            return PhysicsCategory.LevelComplete
        }
    }
    
    var contactTestBitMask: UInt32 {
        switch self {
        case .roseFlower:
            return PhysicsCategory.Hero
        }
    }
    
    var collisionBitMask: UInt32 {
        switch self {
        case .roseFlower:
            return PhysicsCategory.None
        }
    }
    
    var isDynamic: Bool {
        switch self {
        case .roseFlower: return false
        }
    }
    
    var affectedByGravity: Bool {
        switch self {
        case .roseFlower: return false
        }
    }
    
    var allowsRotation: Bool {
        switch self {
        case .roseFlower: return false
        }
    }
}

class Level9: GameScene {
    
    var currentLevel: Level {
        return .nine
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
        let width = size.width * xConstraintMultiplier
        let height = playableHeight * yConstraintMultiplier
        return CGSize(width: width, height: height)
    }
    
    override func setupNodes() {
        super.setupNodes()
        
        guard let roseFlower = childNode(withName: Sprite.roseFlower.name) as? SKSpriteNode else {
            conditionFailure(with: "Failed to resolve rose flower")
            return
        }
        
        roseFlower.configure(with: Sprite.roseFlower)
        rose?.MAX_JUMP_COUNT = 3
    }
    
    override func update(levelWith currentTime: TimeInterval, delta: TimeInterval) {

    }
    
    override func didSimulatePhysicsForLevel() {
        
    }
    
    override func contactDidBegin(with contact: SKPhysicsContact) {
        super.contactDidBegin(with: contact)
        let _ = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
    }
    
    override func levelCompleted() {
        guard let successLevel = LevelCompleteLabel.createLabel(with: "You Win!"), let camera = camera else { return }
        successLevel.move(toParent: camera)
        successLevel.position = CGPoint.zero
        
        
        let presentScene = SKAction.afterDelay(2.0) {

            ///
            /// Present menu screen
            ///
            
            let completedScene = GameCompleted.instantiate()
            let transition = SKTransition.crossFade(withDuration: 2.0)
            self.view?.presentScene(completedScene, transition: transition)
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
