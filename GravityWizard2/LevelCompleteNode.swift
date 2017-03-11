//
//  LevelCompleteNode.swift
//  GravityWizard2
//
//  Created by scott mehus on 3/11/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import Foundation
import SpriteKit

final class LevelCompleteNode: SKSpriteNode {
    fileprivate func setupPhysicsBody() {
        physicsBody?.categoryBitMask = PhysicsCategory.LevelComplete
        physicsBody?.collisionBitMask = PhysicsCategory.None
        physicsBody?.contactTestBitMask = PhysicsCategory.Hero
    }
}

extension LevelCompleteNode: LifecycleListener {
    func didMoveToScene() {
        setupPhysicsBody()
    }
}
