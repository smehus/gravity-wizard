//
//  LevelCompleteNode.swift
//  GravityWizard2
//
//  Created by scott mehus on 3/11/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import Foundation
import SpriteKit

final class LevelCompleteNode: SKSpriteNode {
    
    static func instantiate() -> LevelCompleteNode {
        let text = SKTexture(image: #imageLiteral(resourceName: "black-door"))
        let sprite = LevelCompleteNode(texture: text)
        sprite.physicsBody = SKPhysicsBody(texture: text, size: text.size())
        sprite.didMoveToScene()
        return sprite
    }
    
    fileprivate func setupPhysicsBody() {
        physicsBody?.isDynamic = false
        physicsBody?.affectedByGravity = false
        physicsBody?.categoryBitMask = PhysicsCategory.LevelComplete
        physicsBody?.collisionBitMask = PhysicsCategory.None
        physicsBody?.contactTestBitMask = PhysicsCategory.Hero
    }
}

extension LevelCompleteNode: LifecycleListener {
    func didMoveToScene() {
        setupPhysicsBody()
    }
}
