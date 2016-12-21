//
//  GroundNode.swift
//  GravityWizard2
//
//  Created by scott mehus on 12/20/16.
//  Copyright © 2016 scott mehus. All rights reserved.
//

import SpriteKit

class GroundNode: SKSpriteNode {

}

extension GroundNode: LifecycleListener {
    func didMoveToScene() {
        guard let texture = texture else { return }
        let textureHeight = texture.size().height / 2
        let body = SKPhysicsBody(texture: texture, size: CGSize(width: texture.size().width, height: textureHeight))
        body.isDynamic = false
        body.affectedByGravity = false
        
        physicsBody = body
        
    }
}
