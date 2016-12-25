//
//  BreakableRocksNode.swift
//  GravityWizard2
//
//  Created by scott mehus on 12/25/16.
//  Copyright © 2016 scott mehus. All rights reserved.
//

import SpriteKit

class BreakableRocksNode: SKSpriteNode {

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
        for node in children {
            guard let body = node.physicsBody else { continue }
            body.isDynamic = false
            body.categoryBitMask = PhysicsCategory.Rock
            body.contactTestBitMask = PhysicsCategory.Edge | PhysicsCategory.Wizard | PhysicsCategory.Ground | PhysicsCategory.Arrow
            body.collisionBitMask = PhysicsCategory.Edge | PhysicsCategory.Wizard | PhysicsCategory.Ground | PhysicsCategory.Arrow
            body.fieldBitMask = PhysicsCategory.None
        }
    }
}

