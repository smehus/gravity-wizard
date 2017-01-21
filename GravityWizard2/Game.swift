//
//  Game.swift
//  GravityWizard2
//
//  Created by scott mehus on 12/30/16.
//  Copyright © 2016 scott mehus. All rights reserved.
//

import SpriteKit

protocol Game {
    var light: SKNode? { get set }
    
    /// Trackables
    var lastUpdateTimeInterval: TimeInterval { get set }
    var deltaTime: TimeInterval { get set }
    
    var particleFactory: ParticleFactory { get set }
    var trackingProjectileVelocity: Bool { get set }
    var projectileVelocity: CGFloat { get set }
    var currentProjectile: SKNode? { get set }
}

extension Game where Self: SKScene {
    
    func updateDirection(with sprite: SKNode) {
        guard let body = sprite.physicsBody else { return }
        let shortest = shortestAngleBetween(sprite.zRotation, angle2: body.velocity.angle)
        let rotateRadiansPerSec = 4.0 * π
        let amountToRotate = min(rotateRadiansPerSec * CGFloat(deltaTime), abs(shortest))
        sprite.zRotation += shortest.sign() * amountToRotate
    }
    
    func explosion(at point: CGPoint) {
        let explode = particleFactory.explosion(intensity: 0.25 * CGFloat(4 + 1))
        explode.position = point
        explode.run(SKAction.removeFromParentAfterDelay(2.0))
        addChild(explode)
    }
    
    func updateFollowNodePosition(followNode: SKNode?, originNode: SKNode?) {
        guard let heroNode = originNode, let light = followNode else { return }
        let target = convert(heroNode.position, from: heroNode.parent!)
        
        let lerpX = (target.x - light.position.x) * 0.05
        let lerpY = (target.y - light.position.y) * 0.05
        
        light.position.x += lerpX
        light.position.y += lerpY
    }
    
    func updateSpriteVelocityAnimation() {
        
    }
    
    func updateNodeGravityState(with node: GravityStateTracker?) {
        guard var node = node else { return }
        if node.physicsBody!.velocity.dy > 50 {
            node.gravityState = .climbing
        } else if node.physicsBody!.velocity.dy < -20 {
            node.gravityState = .falling
        } else {
            node.gravityState = .ground
        }
    }
    
    func direction(forStartingPoint startPoint: CGPoint, currentPoint: CGPoint) -> Direction {
        
        if startPoint.x > currentPoint.x {
            return .right
        }
        
        if startPoint.x < currentPoint.x {
            return .left
        }
        
        return .right
    }
    
    func direction(for point: CGPoint, with node: SKNode) -> Direction {
        let nodePosition = convert(node.position, from: node.parent!)
        
        if nodePosition.x > point.x {
            return .left
        }
        
        if nodePosition.x < point.x {
            return .right
        }
        
        return .right
    }
}
