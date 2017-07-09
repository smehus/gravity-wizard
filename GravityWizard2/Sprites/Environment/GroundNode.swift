//
//  GroundNode.swift
//  GravityWizard2
//
//  Created by scott mehus on 12/20/16.
//  Copyright © 2016 scott mehus. All rights reserved.
//

import SpriteKit

final class MovingPlatform: SKSpriteNode, LifecycleListener {
    func didMoveToScene() {
        guard let body = physicsBody else {
            assertionFailure("Moving Platform node is missing the physics body")
            return
        }
        
        body.isDynamic = true
        body.restitution = 0.0
        body.affectedByGravity = true
        body.categoryBitMask = PhysicsCategory.Ground
        lightingBitMask = LightingMask.defaultMask
    }
}

final class GroundNode: SKSpriteNode, LifecycleListener {
    func didMoveToScene() {
        guard let body = physicsBody else {
            assertionFailure("Ground node is missing the physics body")
            return
        }
        
        body.isDynamic = false
        body.restitution = 0.0
        body.affectedByGravity = false
        body.categoryBitMask = PhysicsCategory.Ground
        lightingBitMask = LightingMask.defaultMask
    }
}
