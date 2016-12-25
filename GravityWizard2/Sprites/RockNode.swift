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
        physicsBody?.contactTestBitMask = PhysicsCategory.Wizard | PhysicsCategory.Arrow | PhysicsCategory.Ground
        physicsBody?.collisionBitMask = PhysicsCategory.Wizard | PhysicsCategory.Ground | PhysicsCategory.Edge | PhysicsCategory.Rock
        
    }
}
