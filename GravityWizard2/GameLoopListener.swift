//
//  GameLoopListener.swift
//  GravityWizard2
//
//  Created by scott mehus on 1/18/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit

protocol GameLoopListener {
    func update(withDelta deltaTime: Double)
    func updateDirection(withDelta deltaTime: Double)
}

extension GameLoopListener where Self: SKSpriteNode {
    
    func updateDirection(withDelta deltaTime: Double) {
        guard let body = physicsBody else { return }
        guard body.velocity.dx > 0 else { return }
        let direction: Direction = xScale > 0 ? .right : .left
        let angle = body.velocity.angle
        let shortest = shortestAngleBetween(zRotation, angle2: angle)
        let rotateRadiansPerSec = 4.0 * π
        let amountToRotate = min(rotateRadiansPerSec * CGFloat(deltaTime), abs(shortest))
        zRotation += shortest.sign() * amountToRotate
        
    }
}
