//
//  CollapsablePlatform.swift
//  GravityWizard2
//
//  Created by scott mehus on 7/30/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit

private enum SpriteConfig: SpriteConfiguration {
    case baseBlock
    case block
    case platformTop
    
    var name: String {
        switch self {
        case .block:
            return "block"
        case .baseBlock:
            return "base-block"
        case .platformTop:
            return "platform-top"
        }
    }
    
    var categoryBitMask: UInt32 {
        switch self {
        case .block, .baseBlock:
            return PhysicsCategory.border
        case .platformTop:
            return PhysicsCategory.Ground
        }
    }
    
    var contactTestBitMask: UInt32 {
        switch self {
        case .block, .baseBlock:
            return PhysicsCategory.None
        case .platformTop:
            return PhysicsCategory.Hero
        }
    }
    
    var collisionBitMask: UInt32 {
        switch self {
        case .block, .baseBlock:
            return PhysicsCategory.Hero | PhysicsCategory.border | PhysicsCategory.Ground
        case .platformTop:
            return PhysicsCategory.Hero | PhysicsCategory.border | PhysicsCategory.Ground
        }
    }
    
    // Physics
    
    var isDynamic: Bool {
        switch self {
        case .block:
            return true
        case .baseBlock:
            return false
        case .platformTop:
            return true
        }
    }
    
    var affectedByGravity: Bool {
        switch self {
        case .block:
            return true
        case .baseBlock:
            return false
        case .platformTop:
            return true
        }
    }
    
    var allowsRotation: Bool {
        switch self {
        case .baseBlock:
            return false
        case .block:
            return true
        case .platformTop:
            return true
        }
    }
}

final class CollapsablePlatform: SKNode {
    
    static func generate() -> CollapsablePlatform? {
        guard
            let platformScene = SKScene(fileNamed: "CollapsablePlatform"),
            let platformNode = platformScene.childNode(withName: "platform") as? CollapsablePlatform
        else {
            return nil
        }
        
        platformNode.setupNode()
        return platformNode
    }
    
    private func setupNode() {
        enumerateChildNodes(withName: SpriteConfig.baseBlock.name) { (node, stop) in
            guard let sprite = node as? SKSpriteNode, let _ = sprite.physicsBody else {
                self.conditionFailure(with: "Failed to unwrap and cast sprite \(String(describing: node.name))")
                return
            }
            
            sprite.configure(with: SpriteConfig.baseBlock)
        }
        
        enumerateChildNodes(withName: SpriteConfig.block.name) { (node, stop) in
            guard let sprite = node as? SKSpriteNode, let _ = sprite.physicsBody else {
                self.conditionFailure(with: "Failed to unwrap and cast sprite \(String(describing: node.name))")
                return
            }
            
            sprite.configure(with: SpriteConfig.block)
        }
        
        enumerateChildNodes(withName: SpriteConfig.platformTop.name) { (node, stop) in
            guard let sprite = node as? MovingPlatform else {
                print("😡 Platofrm top not a moving platform")
                return
            }
            
            sprite.didMoveToScene()
        }
    }
}
