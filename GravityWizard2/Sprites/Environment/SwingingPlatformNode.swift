//
//  SwingingPlatformNode.swift
//  GravityWizard2
//
//  Created by scott mehus on 7/8/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit

fileprivate enum Sprites: String {
    case rope = "//rope"
    case anchor = "//anchor"
    case platform = "//platform"
    
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
}

final class SwingingPlatformNode: SKNode {
    fileprivate var rope: SKSpriteNode?
    fileprivate var platform: SKSpriteNode?
    fileprivate var anchor: SKSpriteNode?
    
    fileprivate func setupSprites() {
        guard
            let ropeNode = childNode(withName: Sprites.rope.rawValue) as? SKSpriteNode,
            let anchorNode = childNode(withName: Sprites.anchor.rawValue) as? SKSpriteNode,
            let platformNode = childNode(withName: Sprites.platform.rawValue) as? SKSpriteNode
        else {
            conditionFailure(with: "Failed to resolve sprites")
            return
        }
        
        rope = ropeNode
        platform = platformNode
        anchor = anchorNode
    }
    
    fileprivate func setupPhysics() {
        guard
            let ropeBody = rope?.physicsBody,
            let anchorBody = anchor?.physicsBody,
            let platformBody = platform?.physicsBody
        else {
            conditionFailure(with: "Failed to unwrap physics bodies")
            return
        }
        
        
    }
    
    fileprivate func setupJoints() {
        
//        let joint = SKPhysicsJointPin.joint(withBodyA: <#T##SKPhysicsBody#>, bodyB: <#T##SKPhysicsBody#>, anchor: <#T##CGPoint#>)
    }
}

extension SwingingPlatformNode: LifecycleListener {
    func didMoveToScene() {
        setupSprites()
        setupPhysics()
        setupJoints()
    }
}
