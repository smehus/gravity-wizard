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
    static let container = "container"
    static let anchor = "StaticAnchor"
}

final class StonePlatform: SKNode {
    
    fileprivate var anchor: SKNode?
    
    fileprivate func setupAnchorBody() {
        guard let node = childNode(withName: Names.anchor) else {
//            assertionFailure("Failed to find anchor")
            return
        }
        
        anchor = node
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
        physicsBody = SKPhysicsBody(bodies: bodies)
        physicsBody?.affectedByGravity = false
        if let body = physicsBody {
            body.velocity = CGVector(dx: -40, dy: 0)
        }
    }
}

extension StonePlatform: LifecycleListener {
    func didMoveToScene() {
        setupAnchorBody()
        setupTileBodies()
    }
}
