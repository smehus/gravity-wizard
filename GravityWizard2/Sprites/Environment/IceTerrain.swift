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
            return PhysicsCategory.Ground | PhysicsCategory.Hero
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
        node.setupNode(size: size)
        
        return node
    }
    
    var size: CGSize {
        return ground!.size
    }
    
    private func setupNode(size: CGSize) {
        guard let groundSprite = childNode(withName: "ground") as? SKSpriteNode else {
            conditionFailure(with: "fuckkk")
            return
        }
        
        
        groundSprite.size = size
        self.ground = groundSprite
        groundSprite.physicsBody = SKPhysicsBody(texture: groundSprite.texture!, size: groundSprite.texture!.size())
        groundSprite.configure(with: config!)
    }
}

extension IceTerrain: LifecycleListener {
    func didMoveToScene() {
        
    }
}
