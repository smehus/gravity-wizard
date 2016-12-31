//
//  GravityProjectile.swift
//  GravityWizard2
//
//  Created by scott mehus on 12/31/16.
//  Copyright © 2016 scott mehus. All rights reserved.
//

import SpriteKit

class GravityProjectile: SKNode {

    static func generateGravityProjectile() -> GravityProjectile? {
        guard
            let file = SKScene(fileNamed: "GravityProjectile"),
            let node = file.childNode(withName: "root") as? GravityProjectile
            else {
                assertionFailure("Missing sprite or file")
                return nil
        }
        
        
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
    
    var isInFlight: Bool {
        return false
    }
    
    func collide() {
        
    }
}
