//
//  VikingNode.swift
//  GravityWizard2
//
//  Created by scott mehus on 12/28/16.
//  Copyright © 2016 scott mehus. All rights reserved.
//

import SpriteKit

fileprivate struct Collisions {
    static let mainMasks = PhysicsCategory.Arrow | PhysicsCategory.Rock | PhysicsCategory.Ground | PhysicsCategory.Edge | PhysicsCategory.vikingBodyPart
}

class VikingNode: SKSpriteNode {

    /// Parts
    var head: SKSpriteNode?
    var body: SKSpriteNode?
    
    /// Joints
    var neckJoint: SKPhysicsJointFixed?
    
    func arrowHit() {
        guard let joint = neckJoint, let scene = scene else { return }
        scene.physicsWorld.remove(joint)
    }
}

extension VikingNode: LifecycleListener {
    func didMoveToScene() {
        
        self.head = childNode(withName: "head") as? SKSpriteNode
        self.body = childNode(withName: "body") as? SKSpriteNode
        
        guard let headBody = head?.physicsBody, let bodyBody = body?.physicsBody, let scene = scene else { return }
        
        headBody.categoryBitMask = PhysicsCategory.vikingBodyPart
        headBody.contactTestBitMask = PhysicsCategory.Arrow | PhysicsCategory.Ground | PhysicsCategory.Rock
        headBody.collisionBitMask = Collisions.mainMasks
        
        bodyBody.categoryBitMask = PhysicsCategory.vikingBodyPart
        bodyBody.contactTestBitMask = PhysicsCategory.Arrow | PhysicsCategory.Ground | PhysicsCategory.Rock
        bodyBody.collisionBitMask = Collisions.mainMasks
        
        
//        let joint = SKPhysicsJointPin.joint(withBodyA: bodyBody, bodyB: headBody, anchor: head!.position)
        let joint = SKPhysicsJointFixed.joint(withBodyA: bodyBody, bodyB: headBody, anchor: head!.position)
        neckJoint = joint
        scene.physicsWorld.add(joint)
        
    }
    
}
