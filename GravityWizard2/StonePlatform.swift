//
//  StonePlatform.swift
//  GravityWizard2
//
//  Created by scott mehus on 3/10/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import Foundation
import SpriteKit

fileprivate struct Names {
    static let tile = "tile"
    static let movingPlatform = "MovingPlatform"
    static let platformBase = "PlatformBase"

}

final class StonePlatform: SKNode {
    
    fileprivate var movingPlatform: SKNode?
    fileprivate var platformBase: SKNode?
    
    func startAnimating(with initial: CGFloat, repeating: CGFloat) {
        
        let initialAction = SKAction.moveBy(x: -initial, y: 0, duration: 1.5)
        let moveAction = SKAction.moveBy(x: repeating, y: 0, duration: 3.0)
        let repeatingAction = SKAction.repeatForever(SKAction.sequence([moveAction, moveAction.reversed()]))
        movingPlatform?.run(SKAction.sequence([initialAction, repeatingAction]))
    }
    
    fileprivate func setupTileBodies() {
        var bodies: [SKPhysicsBody] = []
        enumerateChildNodes(withName: "//\(Names.tile)") { node, _ in
            guard
                let sprite = node as? SKSpriteNode,
                let body = sprite.physicsBody
            else {
                assertionFailure("Failed to cast tile as sprite node")
                return
            }
            
            sprite.physicsBody?.categoryBitMask = PhysicsCategory.Ground
            bodies.append(body)
        }
        
        guard !bodies.isEmpty else {
            assertionFailure("Tile bodies array is empty")
            return
        }
        
        setupContainerBody(with: bodies)
    }
    
    fileprivate func setupContainerBody(with bodies: [SKPhysicsBody]) {
        guard let platform = childNode(withName: Names.movingPlatform) else {
            assertionFailure("Failed to find moving platform")
            return
        }
        
        platform.physicsBody = SKPhysicsBody(bodies: bodies)
        platform.physicsBody?.categoryBitMask = PhysicsCategory.Ground
        platform.physicsBody?.affectedByGravity = false
        platform.physicsBody?.allowsRotation = false
        movingPlatform = platform
    }
    
    fileprivate func setupBaseBody() {
        guard let base = childNode(withName: Names.platformBase) as? SKSpriteNode else {
            assertionFailure("Failed to find platform base")
            return
        }
        
        base.physicsBody?.categoryBitMask = PhysicsCategory.travelatorBase
        base.physicsBody?.collisionBitMask = PhysicsCategory.Ground
        base.physicsBody?.affectedByGravity = false
        base.physicsBody?.isDynamic = false
        base.physicsBody?.friction = 1.0
    }
}

extension StonePlatform: LifecycleListener {
    func didMoveToScene() {
        setupBaseBody()
        setupTileBodies()
    }
}
