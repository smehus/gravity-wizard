//
//  EdgeNode.swift
//  GravityWizard2
//
//  Created by scott mehus on 7/29/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit

class EdgeNode: SKSpriteNode {
    
    private func setupNode() {
        guard let body = physicsBody else {
            conditionFailure(with: "Failed to unwrap physics boyd")
            return
        }
        
        body.categoryBitMask = PhysicsCategory.Edge
        body.contactTestBitMask = PhysicsCategory.enemy | PhysicsCategory.Hero
    }
}

extension EdgeNode: LifecycleListener {
    func didMoveToScene() {
        setupNode()
    }
}


