//
//  WizardNode.swift
//  GravityWizard2
//
//  Created by scott mehus on 12/20/16.
//  Copyright © 2016 scott mehus. All rights reserved.
//

import SpriteKit

class WizardNode: SKSpriteNode {
    
    /// Actions
    var jumpAction: SKAction?
    

    fileprivate func setupActions() {
        jumpAction = SKAction.moveBy(x: 40, y: 500, duration: 0.4)
        
    }
    
    func jump() {
        guard let action = jumpAction else { return }
        run(action)
    }
}

extension WizardNode: LifecycleListener {
    func didMoveToScene() {
        physicsBody?.categoryBitMask = PhysicsCategory.Wizard
        physicsBody?.contactTestBitMask = PhysicsCategory.Ground
        physicsBody?.collisionBitMask = PhysicsCategory.Ground
        
        setupActions()
        
    }
}
