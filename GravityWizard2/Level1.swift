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
        
        if trackingArrowVelocity == false {
            trackingArrowVelocity = true
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
        
        if let initial = initialTouchPoint, trackingArrowVelocity {
            let diff = initial - touchPoint
            let vel = diff.length() * 2
            arrowVelocity = vel
        }
        
        if let wizard = wizardNode {
            wizard.face(towards: direction(for: touchPoint, with: wizard))
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        
        if trackingArrowVelocity {
            launchProjectile(at: touchLocation, with: arrowVelocity, and: currentPojectileType)
            trackingArrowVelocity = false
            arrowVelocity = 0
        }
    }
}

extension Level1 {
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
        updateNodeGravityState(with: wizardNode)
        
        if let arrow = currentProjectile {
            updateDirection(with: arrow)
        }
    }
    
    override func didSimulatePhysics() {
        updateFollowNodePosition(followNode: light, originNode: wizardNode)
    }
}
