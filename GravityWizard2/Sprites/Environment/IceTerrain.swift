//
//  IceTerrain.swift
//  GravityWizard2
//
//  Created by scott mehus on 8/28/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit

private enum SpriteConfig: SpriteConfiguration {
    case ground
    case flippedGround
    
    var name: String {
        switch self {
        case .ground:
            return "IceTerrain"
        case .flippedGround:
            return "IceTerrain-flipped"
        }
    }
    
    var sceneName: String {
        switch self {
        case .ground:
            return "IceTerrain"
        case .flippedGround:
            return "IceTerrain-flipped"
        }
    }
    
    var categoryBitMask: UInt32 {
        switch self {
        case .ground, .flippedGround:
            return PhysicsCategory.Ground
        }
    }
    
    var contactTestBitMask: UInt32 {
        switch self {
        case .ground, .flippedGround:
            return PhysicsCategory.Hero
        }
    }
    
    var collisionBitMask: UInt32 {
        switch self {
        case .ground, .flippedGround:
            return PhysicsCategory.enemy | PhysicsCategory.Hero
        }
    }
    
    var isDynamic: Bool {
        switch self {
        case .ground, .flippedGround:
            return false
        }
    }
    
    var affectedByGravity: Bool {
        switch self {
        case .ground, .flippedGround:
            return false
        }
    }
    
    var allowsRotation: Bool {
        switch self {
        case .ground, .flippedGround:
            return false
        }
    }
    
    init(orientation: Bool) {
        switch orientation {
        case true:
            self = .ground
        case false:
            self = .flippedGround
        }
    }
}

internal final class IceTerrain: SKNode {
    
    private var config: SpriteConfig?
    private var ground: SKSpriteNode?

    static func node(orientation: Bool, size: CGSize) -> IceTerrain {
        let config = SpriteConfig(orientation: orientation)
        let scene = SKScene(fileNamed: config.name)!
        let node = scene.childNode(withName: "root") as! IceTerrain
        
        node.config = config
        node.setupNode(withSize: size, config: config)
        
        return node
    }
    
    var size: CGSize {
        return ground!.size
    }
    
    private func setupNode(withSize newSize: CGSize, config: SpriteConfig) {
        guard let groundSprite = childNode(withName: "ground") as? SKSpriteNode else {
            conditionFailure(with: "Failed to resolve ice terrain")
            return
        }
        
        let sizeRatio: CGSize = newSize / groundSprite.size
        groundSprite.size = newSize
        self.ground = groundSprite
        groundSprite.physicsBody = SKPhysicsBody(texture: groundSprite.texture!, size: newSize)
        groundSprite.configure(with: config)
        
        
        childNode(withName: "foliage-container")?
            .enumerateChildNodes(withName: "foliage") { node, stop in
            guard let sprite = node as? SKSpriteNode else { return }
            sprite.size = sprite.size * sizeRatio
            sprite.position *= sizeRatio.cgPoint
        }
    }
}

extension IceTerrain: LifecycleListener {
    func didMoveToScene() {
        
    }
}
