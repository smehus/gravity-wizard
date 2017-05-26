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

let ANIMATION_DURATION = 2.0

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

fileprivate enum RotaryOrientation {
    case horizontal
    case vertical
    
    /// Axis of the joint attached to rotary wheel
    var jointAxis: CGVector {
        switch self {
        case .horizontal:
            return CGVector(dx: 1, dy: 0)
        case .vertical:
            return CGVector(dx: 0, dy: 1)
        }
    }
    
    
    /// Upper limit of the slider joint for rotary wheel
    ///
    /// - Parameter node: Node constant - width / height defines limit
    /// - Returns: Float
    func jointUpperDistanceLimit(with node: SKSpriteNode) -> CGFloat {
        switch self {
        case .horizontal:
            return node.size.width
        case .vertical:
            return node.size.height
        }
    }
}

final class RotarySlider: SKNode {
    
    fileprivate var rotary: SKSpriteNode?
    fileprivate var anchor: SKSpriteNode?
    fileprivate var orientation: RotaryOrientation = .horizontal
    
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
        
        orientation = (anchorNode.size.width > anchorNode.size.height) ? .horizontal : .vertical
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
            let rotaryNode = rotary,
            let anchorNode = anchor,
            let rotaryBody = rotary?.physicsBody,
            let anchorBody = anchor?.physicsBody,
            let scene = scene as? GameScene
        else {
            assertionFailure("Failed to resolve rotary physics bodies for joint")
            return
        }
        
        let joint = SKPhysicsJointSliding.joint(withBodyA: rotaryBody, bodyB: anchorBody, anchor: rotaryNode.position, axis: orientation.jointAxis)
        joint.lowerDistanceLimit = 0
        joint.upperDistanceLimit = orientation.jointUpperDistanceLimit(with: anchorNode)
        joint.shouldEnableLimits = true
        scene.physicsWorld.add(joint)
    }
    
    fileprivate func startHorizontalAnimation() {
        guard
            let rotaryNode = rotary,
            let bar = anchor
        else {
            assertionFailure("Missing rotary sprite in animation functions")
            return
        }
        
        let initialMoveVector = CGVector(dx: -bar.size.width/2, dy: 0)
        let initialMoveAction = SKAction.move(by: initialMoveVector, duration: ANIMATION_DURATION/2)
        
        let repeatedVector = CGVector(dx: bar.size.width, dy: 0)
        let repeatedMoveAction = SKAction.move(by: repeatedVector, duration: ANIMATION_DURATION)
        let repeatAction = SKAction.repeatForever(SKAction.sequence([repeatedMoveAction, repeatedMoveAction.reversed()]))
        let finalMoveAction = SKAction.sequence([initialMoveAction, repeatAction])
        
        let spinAction = SKAction.rotate(byAngle: 360, duration: ANIMATION_DURATION)
        let spinRepeatAction = SKAction.repeatForever(spinAction)
        
        let finalAction = SKAction.group([spinRepeatAction, finalMoveAction])
        rotaryNode.run(finalAction)
    }
    
    fileprivate func startVerticalAnimation() {
        guard
            let rotaryNode = rotary,
            let _ = rotaryNode.physicsBody,
            let _ = anchor
            else {
                assertionFailure("Missing rotary sprite in animation functions")
                return
        }
        
        let impulse = CGVector(dx: 0, dy: 300)
        let action = SKAction.applyImpulse(impulse, duration: 0.5)
        rotaryNode.run(action)
    }
}

extension RotarySlider: LifecycleListener {
    func didMoveToScene() {
        resolveNodes()
        attachPhysics()
        setupJoint()
        switch orientation {
        case .horizontal:
            startHorizontalAnimation()
        case .vertical:
            startVerticalAnimation()
        }
        
    }
}
