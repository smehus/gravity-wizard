//
//  SnakeNode.swift
//  GravityWizard2
//
//  Created by scott mehus on 4/18/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit

fileprivate struct Physics {
    static let category = PhysicsCategory.enemy
    static let contact = PhysicsCategory.arrow | PhysicsCategory.Hero
    static let collision = PhysicsCategory.None
}

final class SnakeNode: SKSpriteNode {
    
    fileprivate var hitCount = 0
    
    fileprivate func setup() {
        guard let body = physicsBody else {
            assertionFailure("Snake node has no physics body")
            return
        }
        
        body.categoryBitMask = Physics.category
        body.contactTestBitMask = Physics.contact
        body.collisionBitMask = Physics.collision
        body.isDynamic = false
        body.affectedByGravity = false
        lightingBitMask = 1
    }
}

extension SnakeNode: Enemy {
    func hitWithArrow() {
        
    }
}

extension SnakeNode: LifecycleListener {
    func didMoveToScene() {
        setup()
    }
}
