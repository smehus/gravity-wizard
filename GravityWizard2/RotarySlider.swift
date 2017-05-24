//
//  RotarySlider.swift
//  GravityWizard2
//
//  Created by scott mehus on 5/24/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit

fileprivate struct Names {
    static let rotary = "rotary"
    static let anchor = "anchor"
}

fileprivate enum Physics {
    case rotary
    case anchor
    
    var categoryBitMask: UInt32 {
        switch self {
        case .rotary:
            return PhysicsCategory.indesctructibleObstacle
        case .anchor:
            return PhysicsCategory.travelatorBase
        }
    }
    
    var contactTestBitMask: UInt32 {
        switch self {
        case .rotary:
            return PhysicsCategory.Hero
        case .anchor:
            return PhysicsCategory.None
        }
    }
    
    var collisionBitMask: UInt32 {
        switch self {
        case .rotary:
            return PhysicsCategory.Hero
        case .anchor:
            return PhysicsCategory.None
        }
    }
    
}

final class RotarySlider: SKNode {
    
    fileprivate var rotary: SKSpriteNode?
    fileprivate var anchor: SKSpriteNode?
    
    fileprivate func resolveNodes() {
        guard
            let rotaryNode = childNode(withName: Names.rotary) as? SKSpriteNode,
            let anchorNode = childNode(withName: Names.anchor) as? SKSpriteNode
        else {
                assertionFailure("Rotary Slider failed to resolve sprites")
                return
        }
        
        rotary = rotaryNode
        anchor = anchorNode
    }

    fileprivate func attachPhysics() {
        guard
            let rotaryBody = rotary?.physicsBody,
            let anchorBody = anchor?.physicsBody
        else {
            assertionFailure("Rotary nodes missing physics bodies")
            return
        }
        
        // Rotary Physics
        
        rotaryBody.categoryBitMask = Physics.rotary.categoryBitMask
        rotaryBody.contactTestBitMask = Physics.rotary.contactTestBitMask
        rotaryBody.collisionBitMask = Physics.rotary.collisionBitMask
        rotaryBody.isDynamic = false
        rotaryBody.affectedByGravity = false
        
        // Anchor Physics
        
        anchorBody.categoryBitMask = Physics.anchor.categoryBitMask
        anchorBody.contactTestBitMask = Physics.anchor.contactTestBitMask
        anchorBody.collisionBitMask = Physics.anchor.collisionBitMask
        anchorBody.isDynamic = false
        anchorBody.affectedByGravity = false
    }
    
    fileprivate func setupJoint() {
        guard
            let rotaryBody = rotary?.physicsBody,
            let anchorBody = anchor?.physicsBody
        else {
            assertionFailure("Failed to resolve rotary physics bodies for joint")
            return
        }
        
//        let joint = SKPhysicsJointSliding.joint(withBodyA: rotaryBody, bodyB: anchorBody, anchor: <#T##CGPoint#>, axis: <#T##CGVector#>)
    }
}

extension RotarySlider: LifecycleListener {
    func didMoveToScene() {
        resolveNodes()
        attachPhysics()
        setupJoint()
    }
}
