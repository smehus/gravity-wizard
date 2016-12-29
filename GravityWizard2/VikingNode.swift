//
//  VikingNode.swift
//  GravityWizard2
//
//  Created by scott mehus on 12/28/16.
//  Copyright © 2016 scott mehus. All rights reserved.
//

import SpriteKit

class VikingNode: SKSpriteNode {

    var head: SKSpriteNode?
    var body: SKSpriteNode?
}

extension VikingNode: LifecycleListener {
    func didMoveToScene() {
        
        self.head = childNode(withName: "head") as? SKSpriteNode
        self.body = childNode(withName: "body") as? SKSpriteNode
        
        guard let headBody = head?.physicsBody, let bodyBody = body?.physicsBody, let scene = scene else { return }
        
        headBody.categoryBitMask = PhysicsCategory.vikingBodyPart
        headBody.contactTestBitMask = PhysicsCategory.Arrow | PhysicsCategory.Ground | PhysicsCategory.Rock
        headBody.collisionBitMask = PhysicsCategory.Arrow | PhysicsCategory.Rock
        
        bodyBody.categoryBitMask = PhysicsCategory.vikingBodyPart
        bodyBody.contactTestBitMask = PhysicsCategory.Arrow | PhysicsCategory.Ground | PhysicsCategory.Rock
        bodyBody.collisionBitMask = PhysicsCategory.Arrow | PhysicsCategory.Rock | PhysicsCategory.Ground
        
        
        let joint = SKPhysicsJointPin.joint(withBodyA: bodyBody, bodyB: headBody, anchor: body!.position)
        scene.physicsWorld.add(joint)
    }
    
}
