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

class Level2: GameScene {
    
    var currentLevel: Level {
        return .two
    }
    
    fileprivate var movingPlatform: StonePlatform?
    fileprivate var destructableStoneStructure: BreakableStoneStructure?
    
    override func setupNodes() {
        super.setupNodes()
        setupPlatform()
        setupBreakableStoneStructure()
    }
    
    override func update(subClassWith currentTime: TimeInterval) {
        movingPlatform?.animate(with: Constants.platformVelocityX)
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

extension Level2 {
    override func collisionDidBegin(with contact: SKPhysicsContact) {
        super.collisionDidBegin(with: contact)
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if collision.collisionCombination() == .arrowCollidesWithDesctructible {
            arrowCollidesWithDesctructable(with: contact)
        }
        
        if collision.collisionCombination() == .arrowCollidesWithEnemy {
            arrowCollidesWithEnemy(with: contact)
        }
        
    }
    
    fileprivate func arrowCollidesWithEnemy(with contact: SKPhysicsContact) {
        let enemyNode = contact.bodyA.categoryBitMask == PhysicsCategory.enemy ? contact.bodyA.node : contact.bodyB.node
        let arrowNode = contact.bodyA.categoryBitMask == PhysicsCategory.arrow ? contact.bodyA.node : contact.bodyB.node
        guard let enemy = enemyNode as? Enemy else {
            assertionFailure("Failed to cast collision node to Enemy type")
            return
        }
        
        createFixedJoint(with: arrowNode, nodeB: enemyNode, position: contact.contactPoint)
        enemy.hitWithArrow()
    }
    
    fileprivate func arrowCollidesWithDesctructable(with contact: SKPhysicsContact) {
        guard
            let node = contact.bodyA.categoryBitMask == PhysicsCategory.destructible ? contact.bodyA.node : contact.bodyB.node,
            let arrowNode = contact.bodyA.categoryBitMask == PhysicsCategory.arrow ? contact.bodyA.node : contact.bodyB.node,
            let arrow = arrowNode as? ArrowNode,
            let arrowBody = arrow.physicsBody,
            let destructible = node as? DesctructibleStone,
            let destructibleBody = destructible.physicsBody
        else {
            return
        }
        
        if destructible.currentTexture != .broken {
            let joint = SKPhysicsJointFixed.joint(withBodyA: arrowBody, bodyB: destructibleBody, anchor: contact.contactPoint)
            physicsWorld.add(joint)
        }
        
        destructible.hit()
    }
    
    fileprivate func createFixedJoint(with nodeA: SKNode?, nodeB: SKNode?, position: CGPoint) {
        guard let bodyA = nodeA?.physicsBody, let bodyB = nodeB?.physicsBody else {
            assertionFailure("Create Static Joint called with nil nodes")
            return
        }
        
        let joint = SKPhysicsJointFixed.joint(withBodyA: bodyA, bodyB: bodyB, anchor: position)
        physicsWorld.add(joint)
    }
}

extension Level2 {
    override func levelCompleted() {
        guard let successLevel = LevelCompleteLabel.createLabel(), let scene = scene else { return }
        successLevel.position = scene.zeroAnchoredCenter()
        successLevel.move(toParent: scene)
        
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
        gameOverLabel.position = convert(gameOverLabel.position, from: camera)
        gameOverLabel.scaleAsPoint = CGPoint(x: 2.0, y: 2.0)
        gameOverLabel.move(toParent: camera)
        
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
}
