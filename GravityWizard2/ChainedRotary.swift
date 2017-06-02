//
//  ChainedRotary.swift
//  GravityWizard2
//
//  Created by scott mehus on 5/31/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit

fileprivate struct Names {
    static let base = "base"
    static let enemy = "enemy"
}

fileprivate enum Physics {
    case enemy
    case base
    
    var categoryBitMask: UInt32 {
        switch self {
        case .enemy: return PhysicsCategory.enemy
        case .base: return PhysicsCategory.Ground
        }
    }
    
    var contactTestBitMask: UInt32 {
        switch self {
        case .enemy: return PhysicsCategory.Hero
        case .base: return PhysicsCategory.None
        }
    }
    
    var collisionBitMask: UInt32 {
        switch self {
        case .enemy: return PhysicsCategory.Hero | PhysicsCategory.Edge
        case .base: return PhysicsCategory.None
        }
    }
}

final class ChainedRotary: SKNode {
    
    fileprivate var enemy: SKSpriteNode?
    fileprivate var base: SKSpriteNode?
    fileprivate var rope: SKShapeNode?
    
    fileprivate func setupSprites() {
        guard
            let rotary  = childNode(withName: Names.enemy) as? SKSpriteNode,
            let rotaryBase = childNode(withName: Names.base) as? SKSpriteNode
        else {
              conditionFailure(with: "Failed to resolve chained rotary sprites")
            return
        }
        
        enemy = rotary
        base = rotaryBase
    }
    
    fileprivate func setupSpritePhysics() {
        guard
            let enemyBody = enemy?.physicsBody,
            let baseBody = base?.physicsBody
        else {
            conditionFailure(with: "Missing sprite physics bodies")
            return
        }
        
        enemyBody.categoryBitMask = Physics.enemy.categoryBitMask
        enemyBody.contactTestBitMask = Physics.enemy.contactTestBitMask
        enemyBody.collisionBitMask = Physics.enemy.collisionBitMask
        enemyBody.isDynamic = true
        enemyBody.affectedByGravity = false

        baseBody.categoryBitMask = Physics.base.categoryBitMask
        baseBody.contactTestBitMask = Physics.base.contactTestBitMask
        baseBody.collisionBitMask = Physics.base.collisionBitMask
        baseBody.isDynamic = false
        baseBody.affectedByGravity = false
    }
    
    fileprivate func setupJoint() {
        guard
            let enemySprite = enemy,
            let baseSprite = base,
            let enemyBody = enemy?.physicsBody,
            let baseBody = base?.physicsBody,
            let gameScene = scene as? GameScene
            else {
                conditionFailure(with: "Failed to setup joint")
                return
        }

        let enemyPOS = gameScene.convert(enemySprite.position, from: enemySprite.parent!)
        let basePOS = gameScene.convert(baseSprite.position, from: baseSprite.parent!)
        
        let joint = SKPhysicsJointLimit.joint(withBodyA: baseBody, bodyB: enemyBody, anchorA: basePOS, anchorB: enemyPOS)
        joint.maxLength = 2730 / 4
        
        gameScene.add(joint: joint)
    }
}

extension ChainedRotary: GameLoopListener {
    func update(withDelta deltaTime: Double) {
        updateRotary()
        drawLine()
    }
    
    fileprivate func updateRotary() {
        guard
            let enemySprite = enemy,
            let gameScene = scene as? GameScene,
            let hero = gameScene.rose
            else {
                conditionFailure(with: "Failed to resolve sprites for update")
                return
        }
        
        
        let heroPos = gameScene.convert(hero.position, from: hero.parent!)
        let enemyPos = gameScene.convert(enemySprite.position, from: enemySprite.parent!)
        let diff = (heroPos - enemyPos) * 0.02
        enemy?.position += diff
    }
    
    fileprivate func drawLine() {
        guard
            let enemySprite = enemy,
            let baseSprite = base
            else {
                conditionFailure(with: "Failed to resolve sprites for update")
                return
        }
        
        let path = CGMutablePath()
        path.move(to: baseSprite.position)
        path.addLine(to: enemySprite.position)
        if rope == nil {
            let line = SKShapeNode(path: path)
            line.isAntialiased = true
            line.strokeColor = .brown
            line.zPosition = -1
            rope = line
            addChild(line)
        } else {
            rope?.path = path
        }
    }
}

extension ChainedRotary: LifecycleListener {
    func didMoveToScene() {
        setupSprites()
        setupSpritePhysics()
        setupJoint()
    }
}

extension ChainedRotary: Obstacle {
    func collision(at contactPoint: CGPoint) {
        
    }
}
