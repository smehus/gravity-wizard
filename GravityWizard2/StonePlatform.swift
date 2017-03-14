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
    
    func startAnimating(with initial: CGFloat, repeating: CGFloat) {
        
        let initialAction = SKAction.moveBy(x: -initial, y: 0, duration: 1.5)
        let moveAction = SKAction.moveBy(x: repeating, y: 0, duration: 3.0)
        let repeatingAction = SKAction.repeatForever(SKAction.sequence([moveAction, moveAction.reversed()]))
        run(SKAction.sequence([initialAction, repeatingAction]))
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
        physicsBody?.allowsRotation = false
    }
}

extension StonePlatform: LifecycleListener {
    func didMoveToScene() {
        setupTileBodies()
    }
}
