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
let LONG_ANIMATION_DURATION = 4.0

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
            conditionFailure(with: "Rotary nodes missing physics bodies")
            return
        }
        
        // Rotary Physics
        
        rotaryBody.categoryBitMask = Physics.rotary.categoryBitMask
        rotaryBody.contactTestBitMask = Physics.rotary.contactTestBitMask
        rotaryBody.collisionBitMask = Physics.rotary.collisionBitMask
        rotaryBody.isDynamic = true
        rotaryBody.affectedByGravity = false
        
        anchorBody.categoryBitMask = Physics.anchor.categoryBitMask
        anchorBody.contactTestBitMask = Physics.anchor.contactTestBitMask
        anchorBody.collisionBitMask = Physics.anchor.collisionBitMask
        anchorBody.isDynamic = false
        anchorBody.affectedByGravity = false
    }
    
    fileprivate func setupJoint() {
        guard
            let point = rotary?.position,
            let bodyA = anchor?.physicsBody,
            let bodyB = rotary?.physicsBody,
            let gameScene = scene as? GameScene
        else {
            conditionFailure(with: "Setup Joint: failed to unwrapp sprites")
            return
        }
        
        let joint = SKPhysicsJointSliding.joint(withBodyA: bodyA, bodyB: bodyB, anchor: point, axis: orientation.jointAxis)
        joint.lowerDistanceLimit = 0
        joint.upperDistanceLimit = 50
        joint.shouldEnableLimits = true
        
        gameScene.add(joint: joint)
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
        
        let spinAction = SKAction.rotate(byAngle: 360, duration: LONG_ANIMATION_DURATION)
        let spinRepeatAction = SKAction.repeatForever(spinAction)
        
        let finalAction = SKAction.group([spinRepeatAction, finalMoveAction])
        rotaryNode.run(finalAction)
    }
    
    fileprivate func startVerticalAnimation() {
        guard
            let rotaryNode = rotary,
            let _ = rotaryNode.physicsBody,
            let bar = anchor,
            let gameScene = scene as? GameScene
            else {
                conditionFailure(with: "Missing rotary sprite in animation functions")
                return
        }
        

        /// Initial x value vector / action
        let initialXMoveVector = CGVector(dx: -gameScene.frame.size.width/2, dy: 0)
        let initialXAction = SKAction.move(by: initialXMoveVector, duration: LONG_ANIMATION_DURATION/2)
        
        /// Repeated x value vector / action
        let xMoveVector = CGVector(dx: gameScene.frame.size.width, dy: 0)
        let xMoveAction = SKAction.move(by: xMoveVector, duration: LONG_ANIMATION_DURATION)
        let xMoveSequence = SKAction.repeatForever(SKAction.sequence([xMoveAction, xMoveAction.reversed()]))
        
        
        /// Initial move action + repeated move action
        let fullXSequence = SKAction.sequence([initialXAction, xMoveSequence])
    

        /// Move up and down
        let moveVector = CGVector(dx: 0, dy: -bar.size.height)
        let moveAction = SKAction.move(by: moveVector, duration: ANIMATION_DURATION * 0.75)
        let yMoveSequence = SKAction.repeatForever(SKAction.sequence([moveAction, moveAction.reversed()]))
    
        
        let fullMoveGroup = SKAction.group([yMoveSequence, fullXSequence])
        

        /// Spin the rotary
        let spinAction = SKAction.rotate(byAngle: 360, duration: LONG_ANIMATION_DURATION)
        let spinRepeatAction = SKAction.repeatForever(spinAction)
        
        rotaryNode.run(SKAction.group([fullMoveGroup, spinRepeatAction]))
        bar.run(fullXSequence)
    }
}

extension RotarySlider: LifecycleListener {
    func didMoveToScene() {
        resolveNodes()
        attachPhysics()
        setupJoint()
        isUserInteractionEnabled = true
        switch orientation {
        case .horizontal: break
//            startHorizontalAnimation()
        case .vertical: break
//            startVerticalAnimation()
        }
    }
}

extension RotarySlider {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let scene = scene as? GameScene else {
            conditionFailure(with: "Touches Began: FAiled to cast scene")
            return
        }
        
        let point = touches.first!.location(in: scene)
        collision(at: point)
    }
}

extension RotarySlider: Obstacle {
    func collision(at contactPoint: CGPoint) {
        guard let rotaryNode = rotary else {
            conditionFailure(with: "Failed to resolve rotary in collision")
            return
        }
//        
//        let action = SKAction.moveBy(x: 0, y: 100.0, duration: 0.1)
//        rotaryNode.run(SKAction.repeat(SKAction.sequence([action, action.reversed()]), count: 2))
    }
}
