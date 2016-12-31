//
//  Level1.swift
//  GravityWizard2
//
//  Created by scott mehus on 12/30/16.
//  Copyright © 2016 scott mehus. All rights reserved.
//

import SpriteKit
import GameplayKit

class Level1: GameScene {

}

extension Level1 {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else { return }
        let touchPoint = touch.location(in: self)
        
        if let projectile = currentProjectile as? GravityProjectile, projectile.isInFlight {
            projectile.createGravityField()
        } else if trackingProjectileVelocity == false {
            trackingProjectileVelocity = true
            initialTouchPoint = touchPoint
        }
        
        if let wizard = wizardNode {
            wizard.face(towards: direction(for: touchPoint, with: wizard))
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let touch = touches.first else { return }
        let touchPoint = touch.location(in: self)
        
        if let initial = initialTouchPoint, trackingProjectileVelocity {
            let diff = initial - touchPoint
            let vel = diff.length() * 2
            projectileVelocity = vel
        }
        
        if let wizard = wizardNode {
            wizard.face(towards: direction(for: touchPoint, with: wizard))
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        
        if trackingProjectileVelocity {
            launchProjectile(at: touchLocation, with: projectileVelocity, and: currentPojectileType)
            trackingProjectileVelocity = false
            projectileVelocity = 0
        }
    }
}

extension Level1 {
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
        updateNodeGravityState(with: wizardNode)
        
        if let projectile = currentProjectile {
            updateDirection(with: projectile)
        }
    }
    
    override func didSimulatePhysics() {
        updateFollowNodePosition(followNode: light, originNode: wizardNode)
    }
}
