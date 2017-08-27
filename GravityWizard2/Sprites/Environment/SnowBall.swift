//
//  SnowBall.swift
//  GravityWizard2
//
//  Created by scott mehus on 8/27/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit

private enum SpriteConfig: SpriteConfiguration {
    case snowball
    
    var name: String {
        switch self {
        case .snowball:
            return "snowball-base"
        }
    }
    
    var categoryBitMask: UInt32 {
        switch self {
        case .snowball:
            return PhysicsCategory.Ground
        }
    }
    
    var contactTestBitMask: UInt32 {
        switch self {
        case .snowball:
            return PhysicsCategory.enemy | PhysicsCategory.Ground
        }
    }
    
    var collisionBitMask: UInt32 {
        switch self {
        case .snowball:
            return PhysicsCategory.enemy | PhysicsCategory.Ground
        }
    }
    
    var isDynamic: Bool {
        switch self {
        case .snowball:
            return true
        }
    }
    
    var affectedByGravity: Bool {
        switch self {
        case .snowball:
            return true
        }
    }
    
    var allowsRotation: Bool {
        switch self {
        case .snowball:
            return true
        }
    }
}

class SnowBall: SKSpriteNode {
    
    private typealias `Self` = SnowBall
    static let SIZE_MULTIPLIER: CGFloat = 6
    
    static func generate() -> SnowBall {
        let texture = SKTexture(image: #imageLiteral(resourceName: "snowball0"))
        let sprite = SnowBall(texture: texture, color: .white, size: texture.size() * Self.SIZE_MULTIPLIER)
        sprite.setupPhysics()
        return sprite
    }
    
    private func setupPhysics() {
        physicsBody = SKPhysicsBody(texture: texture!, size: texture!.size() * Self.SIZE_MULTIPLIER)
        configure(with: SpriteConfig.snowball)
    }
}
