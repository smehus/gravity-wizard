//
//  WizardNode.swift
//  GravityWizard2
//
//  Created by scott mehus on 12/20/16.
//  Copyright © 2016 scott mehus. All rights reserved.
//

import SpriteKit

class WizardNode: SKSpriteNode {
    
    var isGrounded = true
    
    func jump(towards point: CGPoint) {
        
        var xValue = 0
        if point.x > position.x {
            xValue = 50
        } else {
            xValue = -50
        }
        let jumpVector = CGVector(dx: xValue, dy: 1200)
        physicsBody!.applyImpulse(jumpVector)
    }
}

extension WizardNode: LifecycleListener {
    func didMoveToScene() {
        let newSize = texture!.size()
        physicsBody = SKPhysicsBody(rectangleOf: newSize)
        physicsBody?.allowsRotation = false
        physicsBody?.categoryBitMask = PhysicsCategory.Wizard
        physicsBody?.contactTestBitMask = PhysicsCategory.Ground
        physicsBody?.collisionBitMask = PhysicsCategory.Ground
        physicsBody?.fieldBitMask = PhysicsCategory.RadialGravity
        
    }
}
