//
//  ExplodingBlock.swift
//  GravityWizard2
//
//  Created by scott mehus on 9/16/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit

class ExplodingBlock: SKSpriteNode {
    
    private func setupSprite() {
        guard let body = physicsBody else {
            conditionFailure(with: "failed to unwrap physics body")
            return
        }
        
        body.categoryBitMask = PhysicsCategory.explodingBlock
        body.collisionBitMask = PhysicsCategory.arrow | PhysicsCategory.Hero | PhysicsCategory.Ground | PhysicsCategory.explodingBlock
        body.contactTestBitMask = PhysicsCategory.arrow
        body.fieldBitMask = PhysicsCategory.RadialGravity
    }
}

extension ExplodingBlock: LifecycleListener {
    func didMoveToScene() {
        setupSprite()
    }
}
