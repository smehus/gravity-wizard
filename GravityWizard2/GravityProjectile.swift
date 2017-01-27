//
//  GravityProjectile.swift
//  GravityWizard2
//
//  Created by scott mehus on 12/31/16.
//  Copyright © 2016 scott mehus. All rights reserved.
//

import SpriteKit

fileprivate struct Physics {
    static let collisionBitMask = PhysicsCategory.Ground | PhysicsCategory.Edge | PhysicsCategory.BreakableFormation | PhysicsCategory.Rock | PhysicsCategory.VikingBodyPart
    static let contactTestBitMask = Physics.collisionBitMask
    static let categoryBitMask = PhysicsCategory.GravityProjectile
    static let fieldBitMask = PhysicsCategory.None
}

class GravityProjectile: SKNode {
    
    var isInFlight = false
    var gravityFieldNode: SKFieldNode?
    
    var shouldCollideWithLauncher: Bool {
        if let gravity = gravityFieldNode {
            return gravity.isEnabled
        }
        
        return false
    }

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
        node.gravityFieldNode?.strength = 20
        
        node.physicsBody = SKPhysicsBody(circleOfRadius: 10)
        node.physicsBody?.affectedByGravity = true
        node.physicsBody?.categoryBitMask = Physics.categoryBitMask
        node.physicsBody?.contactTestBitMask = Physics.contactTestBitMask
        node.physicsBody?.collisionBitMask = Physics.collisionBitMask
        node.physicsBody?.fieldBitMask = Physics.fieldBitMask
        node.zPosition = 10
        return node
    }
}

extension GravityProjectile: InFlightTrackable {
    
    func collide() {
        isInFlight = false
    }
    
    func createGravityField() {
        guard let body = physicsBody else { assertionFailure(); return }
        body.isDynamic = false
        body.mass = body.mass / 2
        gravityFieldNode?.isEnabled = true
        isInFlight = false
        let remove = SKAction.removeFromParent()
        let wait = SKAction.wait(forDuration: Interval.gravityProjectileLife)
        run(SKAction.sequence([wait, remove]))
        
        if let gameScene = scene as? GameScene {
            run(SKAction.afterDelay(Interval.gravityProjectileLife, runBlock: { 
                gameScene.currentProjectile =  nil
            }))
        }
    }
}
