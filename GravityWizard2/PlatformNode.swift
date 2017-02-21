//
//  PlatformNode.swift
//  GravityWizard2
//
//  Created by scott mehus on 1/20/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit

class PlatformNode: SKNode {
    
}

extension PlatformNode: LifecycleListener {
    func didMoveToScene() {
        enumerateChildNodes(withName: "tile") { (tile, stop) in
            guard let sprite = tile as? SKSpriteNode, let text = sprite.texture else { return }
            let body = SKPhysicsBody(rectangleOf: text.size())
            body.isDynamic = false
            body.restitution = 0.0
            body.affectedByGravity = false
            body.categoryBitMask = PhysicsCategory.Ground
            sprite.physicsBody = body
        }
    }
}
