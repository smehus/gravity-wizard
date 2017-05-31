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
            let enemyBody = enemy?.physicsBody,
            let baseBody = base?.physicsBody,
            let gameScene = scene as? GameScene
            else {
                conditionFailure(with: "Failed to setup joint")
                return
        }
    }
    
}

extension ChainedRotary: GameLoopListener {
    func update(withDelta deltaTime: Double) {
        
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
