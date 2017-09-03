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
        rose?.jumpRestorationType = .actionRestore
        rose?.jumpCount = 0
        guard
            let background = childNode(withName: Keys.backgroundLayer.rawValue),
            let target = childNode(withName: Keys.targetLayer.rawValue) as? TargetLayer,
            let platform = childNode(withName: Keys.platformLayer.rawValue) as? PlatformLayer,
            let camera = camera
        else {
            conditionFailure(with: "Failed to setup nodes")
            return
        }
        
        background.position = CGPoint(x: -(frame.size.width / 2), y: -(playableHeight / 2))
        background.move(toParent: camera)
        
        backgroundLayer = background
        targetLayer = target
        platformLayer = platform
    }

    override func update(levelWith currentTime: TimeInterval, delta: TimeInterval) {
        targetLayer?.update(levelWith: currentTime, delta: delta)
        platformLayer?.update(levelWith: currentTime, delta: delta)
    }
    
    override func didSimulatePhysicsForLevel() {

    }
    
    override func contactDidBegin(with contact: SKPhysicsContact) {
        super.contactDidBegin(with: contact)
        
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        ArrowCollision: if collision.collisionCombination() == .arrowCollidesWithEnemy {
            let enemyNode = contact.bodyA.categoryBitMask == PhysicsCategory.enemy ? contact.bodyA.node : contact.bodyB.node
            guard let enemy = enemyNode as? FlyingEnemy else { break ArrowCollision }
            guard !enemy.isHit  else { break ArrowCollision }
            
            enemy.isHit = true
            rose?.jumpCount += 1
        }
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
