//
//  GravityProjectile.swift
//  GravityWizard2
//
//  Created by scott mehus on 12/31/16.
//  Copyright © 2016 scott mehus. All rights reserved.
//

import SpriteKit

class GravityProjectile: SKNode {
    
    var isInFlight = false
    var gravityFieldNode: SKFieldNode?

    static func generateGravityProjectile() -> GravityProjectile? {
        guard
            let file = SKScene(fileNamed: "GravityProjectile"),
            let node = file.childNode(withName: "root") as? GravityProjectile,
            let gravity = file.childNode(withName: "//gravity-field") as? SKFieldNode
            else {
                assertionFailure("Missing sprite or file")
                return nil
        }
        
        node.gravityFieldNode = gravity
        node.gravityFieldNode?.categoryBitMask = PhysicsCategory.RadialGravity
        node.gravityFieldNode?.isEnabled = false
        
        node.physicsBody = SKPhysicsBody(circleOfRadius: 10)
        node.physicsBody?.affectedByGravity = true
        node.physicsBody?.categoryBitMask = PhysicsCategory.GravityProjectile
        node.physicsBody?.contactTestBitMask = PhysicsCategory.None
        node.physicsBody?.collisionBitMask = PhysicsCategory.None
        node.physicsBody?.fieldBitMask = PhysicsCategory.None
        node.zPosition = 10
        return node
    }
}

extension GravityProjectile: InFlightTrackable {
    
    func collide() {
        isInFlight = false
    }
    
    func createGravityField() {
        physicsBody = nil
        gravityFieldNode?.isEnabled = true
    }
}
