//
//  Game.swift
//  GravityWizard2
//
//  Created by scott mehus on 12/30/16.
//  Copyright © 2016 scott mehus. All rights reserved.
//

import SpriteKit

protocol Game {
    var currentLevel: Level { get set }
    var light: SKNode? { get set }
    
    /// Trackables
    var lastUpdateTimeInterval: TimeInterval { get set }
    var deltaTime: TimeInterval { get set }
    
    var particleFactory: ParticleFactory { get set }
}

extension Game where Self: SKScene {
    
    func explosion(at point: CGPoint) {
        let explode = particleFactory.explosion(intensity: 0.25 * CGFloat(4 + 1))
        explode.position = point
        explode.run(SKAction.removeFromParentAfterDelay(2.0))
        addChild(explode)
    }
    
    func updateFollowNodePosition(followNode: SKNode?, originNode: SKNode?) {
        guard let wizardNode = originNode, let light = followNode else { return }
        let target = convert(wizardNode.position, from: wizardNode.parent!)
        
        let lerpX = (target.x - light.position.x) * 0.05
        let lerpY = (target.y - light.position.y) * 0.05
        
        light.position.x += lerpX
        light.position.y += lerpY
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
}
