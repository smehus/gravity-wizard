//
//  RockNode.swift
//  GravityWizard2
//
//  Created by scott mehus on 12/23/16.
//  Copyright © 2016 scott mehus. All rights reserved.
//

import SpriteKit

class RockNode: SKSpriteNode {

}

extension RockNode: LifecycleListener {
    func didMoveToScene() {

        let textureSize = texture!.size()
        let newSize = CGSize(width: textureSize.width / 2, height: textureSize.height / 4)
        let body = SKPhysicsBody(rectangleOf: newSize)
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.Rock
        body.contactTestBitMask = PhysicsCategory.Wizard
        body.collisionBitMask = PhysicsCategory.Wizard
        
        physicsBody = body
    }
}
