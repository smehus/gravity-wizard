//
//  DestructibleStone.swift
//  GravityWizard2
//
//  Created by scott mehus on 4/4/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import Foundation
import SpriteKit

final class DesctructibleStone: SKSpriteNode {
    
    fileprivate struct Physics {
        static let category = PhysicsCategory.destructible
        static let contact = PhysicsCategory.Arrow
        static let collision = PhysicsCategory.Arrow | PhysicsCategory.Ground | PhysicsCategory.Hero
    }
    
    func setupPhysicsBody() {
        guard let body = physicsBody else {
            assertionFailure("Destructible stone has no physics body")
            return
        }
        
        body.affectedByGravity = false
        body.isDynamic = false
        body.pinned = false
        body.categoryBitMask = Physics.category
        body.contactTestBitMask = Physics.contact
        body.collisionBitMask  = Physics.collision
    }
}
