//
//  SwingingPlatformNode.swift
//  GravityWizard2
//
//  Created by scott mehus on 7/8/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit

fileprivate enum Sprites: String, SpriteConfiguration {
    case rope = "rope"
    case anchor = "anchor"
    case platform = "platform"
    
    var name: String {
        return "//\(rawValue)"
    }
    
    var categoryBitMask: UInt32 {
        switch self {
        case .rope:
            return PhysicsCategory.None
        case .platform:
            return PhysicsCategory.Ground
        case .anchor:
            return PhysicsCategory.None
        }
    }
    
    var contactTestBitMask: UInt32 {
        switch self {
        case .rope:
            return PhysicsCategory.None
        case .platform:
            return PhysicsCategory.Hero
        case .anchor:
            return PhysicsCategory.None
        }
    }
    
    var collisionBitMask: UInt32 {
        switch self {
        case .rope:
            return PhysicsCategory.None
        case .platform:
            return PhysicsCategory.Hero
        case .anchor:
            return PhysicsCategory.None
        }
    }
    
    // Physics
    
    var isDynamic: Bool {
        switch self {
        case .rope:
            return true
        case .anchor:
            return false
        case .platform:
            return true
        }
    }
    
    var affectedByGravity: Bool {
        switch self {
        case .rope:
            return true
        case .anchor:
            return false
        case .platform:
            return true
        }
    }
}

final class SwingingPlatformNode: SKNode {
    fileprivate var rope: SKSpriteNode?
    fileprivate var platform: SKSpriteNode?
    fileprivate var anchor: SKSpriteNode?
    
    fileprivate func setupSprites() {
        guard
            let ropeNode = childNode(withName: Sprites.rope.name) as? SKSpriteNode,
            let anchorNode = childNode(withName: Sprites.anchor.name) as? SKSpriteNode,
            let platformNode = childNode(withName: Sprites.platform.name) as? SKSpriteNode
        else {
            conditionFailure(with: "Failed to resolve sprites")
            return
        }
        
        ropeNode.zPosition = 10
        platformNode.zPosition = 10
        anchorNode.zPosition = 10
        
        rope = ropeNode
        platform = platformNode
        anchor = anchorNode
    }
    
    fileprivate func setupPhysics() {
        platform?.configure(with: Sprites.platform)
        rope?.configure(with: Sprites.rope)
        anchor?.configure(with: Sprites.anchor)
    }
    
    fileprivate func setupJoints() {
        guard
            let ropeBody = rope?.physicsBody,
            let anchorSprite = anchor,
            let anchorBody = anchor?.physicsBody,
            let _ = platform?.physicsBody,
            let gameScene = scene as? GameScene
        else {
            conditionFailure(with: "Failed to unwrap physics bodies in joint setup")
            return
        }
        
        let anchorPoint = gameScene.convert(anchorSprite.position, from: anchorSprite.parent!)
        let joint = SKPhysicsJointPin.joint(withBodyA: anchorBody, bodyB: ropeBody, anchor: anchorPoint)
        
        gameScene.add(joint: joint)
    }
    
    fileprivate func push() {
        let pushVect = CGVector(dx: 500, dy: 0)
        rope?.physicsBody?.velocity = pushVect
    }
}

extension SwingingPlatformNode: LifecycleListener {
    func didMoveToScene() {
        setupSprites()
        setupPhysics()
        setupJoints()
        push()
    }
}
