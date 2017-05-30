//
//  RotarySlider.swift
//  GravityWizard2
//
//  Created by scott mehus on 5/24/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit

fileprivate struct Names {
    static let rotaryAnchor = "rotary-anchor"
    static let rotarySprite = "rotary-sprite"
    static let belt = "belt"
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
    
    var deactivated: UInt32 {
        return PhysicsCategory.None
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
    
    fileprivate var rotaryAnchor: SKSpriteNode?
    fileprivate var rotarySprite: SKSpriteNode?
    fileprivate var belt: SKSpriteNode?
    fileprivate var orientation: RotaryOrientation = .horizontal
    
    fileprivate var focusedRotary: SKSpriteNode? {
        return rotarySprite
    }
    
    fileprivate func resolveNodes() {
        guard
            let rotaryNode = childNode(withName: Names.rotaryAnchor) as? SKSpriteNode,
            let anchorNode = childNode(withName: Names.belt) as? SKSpriteNode,
            let rotaryTexture = childNode(withName: Names.rotarySprite) as? SKSpriteNode
        else {
                assertionFailure("Rotary Slider failed to resolve sprites")
                return
        }
        
        rotaryAnchor = rotaryNode
        rotarySprite = rotaryTexture
        belt = anchorNode
        
        orientation = (anchorNode.size.width > anchorNode.size.height) ? .horizontal : .vertical
    }

    fileprivate func attachPhysics() {
        guard
            let spriteBody = rotarySprite?.physicsBody
        else {
            conditionFailure(with: "Rotary nodes missing physics bodies")
            return
        }
        
        // Rotary Physics
        
        spriteBody.categoryBitMask = Physics.rotary.categoryBitMask
        spriteBody.contactTestBitMask = Physics.rotary.contactTestBitMask
        spriteBody.collisionBitMask = Physics.rotary.collisionBitMask
        spriteBody.isDynamic = false
        spriteBody.affectedByGravity = false
    }
    
    fileprivate func setupSpringJoint() {
        guard
            let rotaryBody = rotarySprite?.physicsBody,
            let anchorBody = rotaryAnchor?.physicsBody,
            let rotary = rotarySprite,
            let anchor = rotaryAnchor,
            let gameScene = scene as? GameScene
        else {
            conditionFailure(with: "Failed to unwrap physics bodies for joint")
            return
        }
        
        
        let rotaryPosition = gameScene.convert(rotary.position, from: rotary.parent!)
        let anchorPosition = gameScene.convert(anchor.position, from: anchor.parent!)
        
        rotaryBody.mass = 0.5
        let joint = SKPhysicsJointSpring.joint(withBodyA: rotaryBody, bodyB: anchorBody, anchorA: rotaryPosition, anchorB: anchorPosition)
        joint.frequency = 9.0
        gameScene.add(joint: joint)
    }
    
    fileprivate func startHorizontalAnimation() {
        guard
            let rotaryNode = focusedRotary,
            let bar = belt
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
            let rotaryNode = focusedRotary,
            let _ = rotaryNode.physicsBody,
            let bar = belt,
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
        
        switch orientation {
        case .horizontal:
            startHorizontalAnimation()
        case .vertical:
            startVerticalAnimation()
        }
    }
}



extension RotarySlider: Obstacle {
    func collision(at contactPoint: CGPoint) {
        guard
            let rotary = focusedRotary,
            let body = rotary.physicsBody,
            body.collisionBitMask != Physics.rotary.deactivated,
            let gameScene = scene as? GameScene
        else {
            return
        }
        
        deactiveCollisions()
        let rotaryPosition = gameScene.convert(rotary.position, from: rotary.parent!)
        let point = rotaryPosition - contactPoint
        let vect = CGVector(point: point)
        let responseAction = SKAction.move(by: vect, duration: 0.1)
        responseAction.timingMode = .easeOut
        let sequence = SKAction.sequence([responseAction, responseAction.reversed()])
        let repeated = SKAction.repeat(sequence, count: 1)
        
        rotary.run(repeated, completion: activateCollisions)
    }
    
    fileprivate func deactiveCollisions() {
        guard let body = focusedRotary?.physicsBody else {
            conditionFailure(with: "Activate collisions - missing sprite")
            return
        }
        
        body.collisionBitMask = Physics.rotary.deactivated
    }
    
    fileprivate func activateCollisions() {
        guard let body = focusedRotary?.physicsBody else {
            conditionFailure(with: "Activate collisions - missing sprite")
            return
        }
        
        body.collisionBitMask = Physics.rotary.collisionBitMask
    }
}
