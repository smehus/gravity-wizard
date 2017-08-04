//
//  AngledIcePlatform.swift
//  GravityWizard2
//
//  Created by scott mehus on 8/4/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit

private enum SpriteConfig: SpriteConfiguration {
    case platform
    
    var name: String {
        switch self {
        case .platform:
            return "platform-base"
        }
    }
    
    var categoryBitMask: UInt32 {
        switch self {
        case .platform:
            return PhysicsCategory.Ground
        }
    }
    
    var contactTestBitMask: UInt32 {
        switch self {
        case .platform:
            return PhysicsCategory.enemy | PhysicsCategory.Ground
        }
    }
    
    var collisionBitMask: UInt32 {
        switch self {
        case .platform:
            return PhysicsCategory.enemy
        }
    }

    var isDynamic: Bool {
        switch self {
        case .platform:
            return false
        }
    }
    
    var affectedByGravity: Bool {
        switch self {
        case .platform:
            return false
        }
    }
    
    var allowsRotation: Bool {
        switch self {
        case .platform:
            return false
        }
    }
}

final class AngledIcePlatform: SKNode {
    
    private var platform: SKSpriteNode!
    
    static func instantiate() -> AngledIcePlatform? {
        guard
            let platformScene = SKScene(fileNamed: String(describing: type(of: self))),
            let platformNode = platformScene.childNode(withName: "platform") as? AngledIcePlatform
            else {
                return nil
        }
        
        platformNode.setupNode()
        return platformNode
    }
    
    private func setupNode() {
        guard
            let base = childNode(withName: SpriteConfig.platform.name) as? SKSpriteNode,
            let _ = base.physicsBody
        else {
            conditionFailure(with: "Failed to resolve platform sprite")
            return
        }
        
        base.configure(with: SpriteConfig.platform)
        base.physicsBody?.friction = 0.001
        platform = base
    }
}

extension AngledIcePlatform: LifecycleListener {
    func didMoveToScene() {
        setupNode()
    }
}
