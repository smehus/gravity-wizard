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

    var isWounded = false
    
    /// Parts
    var head: SKSpriteNode?
    var body: SKSpriteNode?
    
    /// Joints
    var neckJoint: SKPhysicsJoint?
    
    /// Constants
    let bloodExplosionCount = 10
    
    func arrowHit() {
        guard let scene = scene else { return }
        isWounded = true
        
        if let joint = neckJoint {
            scene.physicsWorld.remove(joint)
        }
        
        var bloodPoint = head!.position
        bloodPoint.y -= head!.halfHeight()
        
        if let blood = BloodNode.generateBloodNode() {
            let bleedAction = SKAction.run { [weak self] _ in
                guard let `self` = self else { return }
                
                let bloodNode = blood.copy() as! BloodNode
                bloodNode.position = self.convert(bloodPoint, to: scene)
                bloodNode.zPosition = 10
                scene.addChild(bloodNode)
                
                let vector = CGVector(dx: Int.random(min: -2, max: 2), dy: 4)
                bloodNode.physicsBody?.applyImpulse(vector)
            }
            
            let wait = SKAction.wait(forDuration: 0.1)
            scene.run(SKAction.repeat(SKAction.sequence([bleedAction, wait]), count: bloodExplosionCount))
        }
    }
}

extension SKSpriteNode {
    
    func halfHeight() -> CGFloat {
        return size.height / 2
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
        
        let anchor = CGPoint(x: head!.position.x, y: head!.position.y + head!.halfHeight())
        
//        let joint = SKPhysicsJointPin.joint(withBodyA: bodyBody, bodyB: headBody, anchor: head!.position)
//        let joint = SKPhysicsJointFixed.joint(withBodyA: bodyBody, bodyB: headBody, anchor: anchor)
//        neckJoint = joint
//        scene.physicsWorld.add(joint)
        
    }
    
}
