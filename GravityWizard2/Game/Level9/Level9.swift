//
//  Level9.swift
//  GravityWizard2
//
//  Created by scott mehus on 9/13/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit

private enum Sprite: SpriteConfiguration {
    case moveable
    
    var name: String {
        switch self {
        case .moveable: return "//movable"
        }
    }
    
    var categoryBitMask: UInt32 {
        switch self {
        case .moveable:
            return PhysicsCategory.movable
        }
    }
    
    var contactTestBitMask: UInt32 {
        switch self {
        case .moveable:
            return PhysicsCategory.Hero
        }
    }
    
    var collisionBitMask: UInt32 {
        switch self {
        case .moveable:
            return PhysicsCategory.Hero | PhysicsCategory.Ground | PhysicsCategory.enemy | PhysicsCategory.movable
        }
    }
    
    var isDynamic: Bool {
        switch self {
        case .moveable: return true
        }
    }
    
    var affectedByGravity: Bool {
        switch self {
        case .moveable: return true
        }
    }
    
    var allowsRotation: Bool {
        switch self {
        case .moveable: return true
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
        
        enumerateChildNodes(withName: Sprite.moveable.name) { (node, stop) in
            guard let sprite = node as? SKSpriteNode else { return }
            sprite.configure(with: Sprite.moveable)
        }
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
