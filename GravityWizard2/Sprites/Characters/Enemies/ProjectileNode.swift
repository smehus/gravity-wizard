//
//  ProjectileNode.swift
//  GravityWizard2
//
//  Created by scott mehus on 7/26/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit

fileprivate enum Texture: String, SpriteConfiguration, StringInitable {
    case largeSandRock = "large-sand-rock"
    case smallSandRock = "small-sand-rock"
    
    init?(string: String) {
        self.init(rawValue: string)
    }
    
    var largeRockVariation: UIImage {
        let array = [#imageLiteral(resourceName: "sand-rock-1"),
                     #imageLiteral(resourceName: "sand-rock-2"),
                     #imageLiteral(resourceName: "sand-rock-3"),
                     #imageLiteral(resourceName: "sand-rock-4")]
        
        return array.random()
    }
    
    
    var texture: SKTexture? {
        switch self {
        case .smallSandRock:
            return SKTexture(image: #imageLiteral(resourceName: "small-sand-rock"))
        case .largeSandRock:
            return SKTexture(image: largeRockVariation)
        }
    }
    
    var name: String {
        return "\(rawValue)"
    }
    
    var categoryBitMask: UInt32 {
        switch self {
        case .smallSandRock, .largeSandRock:
            return PhysicsCategory.enemy
        }
    }
    
    var contactTestBitMask: UInt32 {
        switch self {
        case .smallSandRock, .largeSandRock:
            return PhysicsCategory.Hero
        }
    }
    
    var collisionBitMask: UInt32 {
        switch self {
        case .smallSandRock, .largeSandRock:
            return PhysicsCategory.Hero
        }
    }
    
    // Physics
    
    var isDynamic: Bool {
        switch self {
        case .smallSandRock, .largeSandRock:
            return true
        }
    }
    
    var affectedByGravity: Bool {
        switch self {
        case .smallSandRock, .largeSandRock:
            return true
        }
    }
    
    var allowsRotation: Bool {
        switch self {
        case .smallSandRock, .largeSandRock:
            return true
        }
    }
}

/// Use the rotation property in the Scene editor node to change the direciton
/// of the projectile shooter thingy
/// Also, use the scene editor custom proprty things that were used in the tile map game
/// to change the texture of projectile to shoot
final class ProjectileNode: SKNode {
    
    fileprivate var baseProjectile: SKSpriteNode?
    fileprivate var timer: TimeInterval = 0
    fileprivate var direction: Direction?
    
    fileprivate func setupNode() {
        
        guard
            let texture: Texture = userData?[ .texture ],
            let nodeDirection: Direction = userData?[ .direction ],
            let spriteTexture = texture.texture
            else {
                conditionFailure(with: "Failed to create setup node")
                return
        }
        
        self.direction = nodeDirection
        
        baseProjectile = SKSpriteNode(texture: texture.texture)
        baseProjectile?.zPosition = 10
        baseProjectile?.physicsBody = SKPhysicsBody(texture: spriteTexture, size: spriteTexture.size())
        baseProjectile?.configure(with: texture)
    }
    
    fileprivate func shootProjectile() {
        guard
            let projectile = baseProjectile?.copy() as? SKSpriteNode,
            let _ = projectile.physicsBody
        else {
            conditionFailure(with: "Failed to create copy of sprite")
            return
        }

        
        addChild(projectile)
        
        if let vector = direction?.projectileVector(velocity: 500) {
            projectile.physicsBody?.velocity = vector
        }
    }
}

extension ProjectileNode: GameLoopListener {
    func update(withDelta deltaTime: Double) {
        
        ///
        /// Get Heros position
        ///
        
        guard
            let gameScene = scene as? GameScene,
            let rose = gameScene.rose
            else {
                conditionFailure(with: "Failed to cast scene as game scene")
                return
        }
        
        let rosePosition = gameScene.convert(rose.position, from: rose.parent!)
        
        
        ///
        /// Shoot projectile every three seconds
        ///
        
        timer += deltaTime
        
        switch timer {
        case _ where timer > 3.0 && ((position.x - rosePosition.x) / 1000.0) < 1.0:
            timer = 0
            shootProjectile()
        case _ where timer > 3.0:
            timer = 0
        default: break
        }
        
    }
}

extension ProjectileNode: LifecycleListener {
    func didMoveToScene() {
        setupNode()
    }
}
