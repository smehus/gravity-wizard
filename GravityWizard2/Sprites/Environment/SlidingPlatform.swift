//
//  SlidingPlatform.swift
//  GravityWizard2
//
//  Created by scott mehus on 6/6/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit


fileprivate struct Names {
    static let parent = "sliding_platform"
    static let base = "base"
    static let platform = "platform"
}

fileprivate enum Physics {
    case base
    case platform
    
    var categoryBitMask: UInt32 {
        switch self {
        case .base: return PhysicsCategory.None
        case .platform: return PhysicsCategory.Ground
        }
    }
    
    var contactTestBitMask: UInt32 {
        switch self {
        case .base: return PhysicsCategory.None
        case .platform: return PhysicsCategory.None
        }
    }
    
    var collisionBitMask: UInt32 {
        switch self {
        case .base: return PhysicsCategory.None
        case .platform: return PhysicsCategory.Hero
        }
    }
}

let MOVE_VELOCITY: CGFloat = 150

final class SlidingPlatform: SKNode {
    
    fileprivate var base: SKSpriteNode!
    fileprivate var platform: SKSpriteNode!
    
    fileprivate func setupSprites() {
        guard
            let baseSprite = childNode(withName: Names.base) as? SKSpriteNode,
            let platformSprite = childNode(withName: Names.platform) as? SKSpriteNode
        else {
            conditionFailure(with: "Failed to resolve sprites")
            return
        }
        
        base = baseSprite
        platform = platformSprite
    }
    
    fileprivate func setupPhysics() {
        guard let _ = base.physicsBody , let _ = platform.physicsBody else {
            conditionFailure(with: "Failed to resolve physics bodies")
            return
        }
        
        base.physicsBody?.categoryBitMask = Physics.base.categoryBitMask
        base.physicsBody?.contactTestBitMask = Physics.base.contactTestBitMask
        base.physicsBody?.collisionBitMask = Physics.base.collisionBitMask
        base.physicsBody?.isDynamic = false
        base.physicsBody?.affectedByGravity = false
        base.physicsBody?.allowsRotation = false
        
        platform.physicsBody?.categoryBitMask = Physics.platform.categoryBitMask
        platform.physicsBody?.contactTestBitMask = Physics.platform.contactTestBitMask
        platform.physicsBody?.collisionBitMask = Physics.platform.collisionBitMask
        platform.physicsBody?.isDynamic = true
        platform.physicsBody?.affectedByGravity = false
        platform.physicsBody?.allowsRotation = false
    }
    
    fileprivate func setupJoint() {
        guard
            let baseBody = base.physicsBody,
            let platformBody = platform.physicsBody,
            let gameScene = scene as? GameScene
        else {
            conditionFailure(with: "Failed to resolve phhysics bodies")
            return
        }
        
        let axis = CGVector(dx: 1, dy: 0)
        
        let basePOS = gameScene.convert(base.position, from: base.parent!)
        let joint = SKPhysicsJointSliding.joint(withBodyA: baseBody, bodyB: platformBody, anchor: basePOS, axis: axis)
        
        joint.shouldEnableLimits = true
        joint.lowerDistanceLimit = -base.size.width/2
        joint.upperDistanceLimit = base.size.width/2
        
        gameScene.add(joint: joint)
    }
    
    fileprivate func animate() {
        guard let body = platform.physicsBody else {
            conditionFailure(with: "Failed to resolve physics body")
            return
        }
        
        let currentXPosition = platform.position.x
        
        if body.velocity.dx > 0 {
            // Going forwards
            
            if currentXPosition >= base.upperWidthPosition() {
                // Moved past limit - turn around
                body.velocity = CGVector(dx: -MOVE_VELOCITY, dy: 0)
            } else {
                body.velocity = CGVector(dx: MOVE_VELOCITY, dy: 0)
            }
            
        } else if body.velocity.dx < 0 {
            // Going backwards
            
            if currentXPosition <= base.lowerWidthPosition() {
                // Moved past limit - turn around
                body.velocity = CGVector(dx: MOVE_VELOCITY, dy: 0)
            } else {
                body.velocity = CGVector(dx: -MOVE_VELOCITY, dy: 0)
            }
            
        } else {
            // Haven't started animating yet
            body.velocity = CGVector(dx: -MOVE_VELOCITY, dy: 0)
        }
    }
}

extension SKSpriteNode {
    func lowerWidthPosition() -> CGFloat {
        guard anchorPoint.x == 0.5 else {
            conditionFailure(with: "lowerWidthPosition - anchor point expected to be 0.5")
            return 0
        }
        
        let halfWidth = size.width / 2
        return position.x - halfWidth
    }
    
    func upperWidthPosition() -> CGFloat {
        guard anchorPoint.x == 0.5 else {
            conditionFailure(with: "lowerWidthPosition - anchor point expected to be 0.5")
            return 0
        }
        
        let halfWidth = size.width / 2
        return position.x + halfWidth
    }
}

extension SlidingPlatform: LifecycleListener {
    func didMoveToScene() {
        setupSprites()
        setupPhysics()
        setupJoint()
    }
}

extension SlidingPlatform: GameLoopListener {
    func update(withDelta deltaTime: Double) {
        animate()
    }
}
