//
//  RockNode.swift
//  GravityWizard2
//
//  Created by scott mehus on 12/23/16.
//  Copyright © 2016 scott mehus. All rights reserved.
//

import SpriteKit

class RockNode: SKSpriteNode {

}

extension RockNode: LifecycleListener {
    func didMoveToScene() {
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask = PhysicsCategory.Rock
        physicsBody?.contactTestBitMask = PhysicsCategory.Hero | PhysicsCategory.arrow | PhysicsCategory.Ground
        physicsBody?.collisionBitMask = PhysicsCategory.Hero | PhysicsCategory.Ground | PhysicsCategory.Edge | PhysicsCategory.Rock
        physicsBody?.fieldBitMask = PhysicsCategory.None
        
    }
}
