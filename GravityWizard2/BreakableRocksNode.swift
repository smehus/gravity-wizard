//
//  BreakableRocksNode.swift
//  GravityWizard2
//
//  Created by scott mehus on 12/25/16.
//  Copyright © 2016 scott mehus. All rights reserved.
//

import SpriteKit

class BreakableRocksNode: SKNode {

    func breakRocks() {
        for node in children {
            guard let body = node.physicsBody else { continue }
            body.isDynamic = true
        }
    }
}

extension BreakableRocksNode: LifecycleListener {
    func didMoveToScene() {
        setupPhysicsBodies()
    }
    
    fileprivate func setupPhysicsBodies() {
        var bodies = [SKPhysicsBody]()
        for node in children {
            guard let body = node.physicsBody else { continue }
            bodies.append(body)
        }
        
        physicsBody = SKPhysicsBody(bodies: bodies)
        physicsBody?.categoryBitMask = PhysicsCategory.BreakableFormation
        physicsBody?.contactTestBitMask = PhysicsCategory.Arrow
        physicsBody?.isDynamic = false
        physicsBody?.affectedByGravity = false
    }
}

