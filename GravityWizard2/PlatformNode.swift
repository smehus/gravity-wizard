//
//  PlatformNode.swift
//  GravityWizard2
//
//  Created by scott mehus on 1/20/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit

class PlatformNode: SKSpriteNode {
    
}

extension PlatformNode: LifecycleListener {
    func didMoveToScene() {
        guard let texture = texture else { return }
        let textureHeight = texture.size().height
        let body = SKPhysicsBody(texture: texture, size: CGSize(width: texture.size().width, height: textureHeight))
        body.isDynamic = false
        body.restitution = 0.0
        body.affectedByGravity = false
        body.categoryBitMask = PhysicsCategory.Ground
        physicsBody = body
        
    }
}

