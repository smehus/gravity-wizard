//
//  StonePlatform.swift
//  GravityWizard2
//
//  Created by scott mehus on 3/10/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import Foundation
import SpriteKit

fileprivate struct Names {
    static let movingPlatform = "MovingPlatform"
    static let platformBase = "PlatformBase"
}

final class StonePlatform: SKNode {

    /// Nodes
    fileprivate var movingPlatform: SKNode?
    fileprivate var platformBase: SKNode?

    /// Factors
    fileprivate var initialPoint: CGPoint?
    fileprivate var moveAmount = 100
    
    
    
    func animate(with offset: CGFloat) {
        guard let platform = movingPlatform, let body = platform.physicsBody, let point = initialPoint else {
            assertionFailure("Moving Platform is nil in animation method")
            return
        }

        // Moving Right
        if body.velocity.dx > 0 {
            if platform.position.x >= (point.x + offset) {
                // Platform has moved past right limit - turn around
                body.velocity = CGVector(dx: -moveAmount, dy: 0)
                return
            } else {
                // Platfor is within the limits - keep going
                body.velocity = CGVector(dx: moveAmount, dy: 0)
                return
            }
        }
        
        // Moving Left
        else if body.velocity.dx < 0 {
            if platform.position.x <= (point.x - offset) {
                // Platform is less than left limit - turn around
                body.velocity = CGVector(dx: moveAmount, dy: 0)
                return
            } else {
                // Platform is within the limits - keep going
                body.velocity = CGVector(dx: -moveAmount, dy: 0)
                return
            }
        }
        
    }
    
    fileprivate func setupPlatform() {
        guard
            let platform = childNode(withName: "//\(Names.movingPlatform)"),
            let _ = platform.physicsBody
        else {
            assertionFailure("Failed to find moving platform")
            return
        }
    
        platform.physicsBody?.categoryBitMask = PhysicsCategory.Ground
        platform.physicsBody?.affectedByGravity = false
        platform.physicsBody?.allowsRotation = false
        movingPlatform = platform
        initialPoint = platform.position
        
        movingPlatform?.physicsBody?.velocity = CGVector(dx: moveAmount, dy: 0)
    }
    
    fileprivate func setupBaseBody() {
        guard let base = childNode(withName: Names.platformBase) as? SKSpriteNode else {
            assertionFailure("Failed to find platform base")
            return
        }
        
        base.physicsBody?.categoryBitMask = PhysicsCategory.travelatorBase
        base.physicsBody?.collisionBitMask = PhysicsCategory.Ground
        base.physicsBody?.affectedByGravity = false
        base.physicsBody?.isDynamic = false
        base.physicsBody?.friction = 1.0
    }
}

extension StonePlatform: LifecycleListener {
    func didMoveToScene() {
        setupBaseBody()
        setupPlatform()
    }
}
