//
//  SnakeNode.swift
//  GravityWizard2
//
//  Created by scott mehus on 4/18/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit

fileprivate struct Physics {
    static let category = PhysicsCategory.enemy
    static let contact = PhysicsCategory.arrow | PhysicsCategory.Hero
    static let collision = PhysicsCategory.None
}

fileprivate enum SnakeTexture: Int {
    case live = 0
    case liveAlt
    case dead
    case ghost
    
    func texture() -> SKTexture {
        switch self {
        case .live:
            return SKTexture(image: #imageLiteral(resourceName: "snakeLava"))
        case .liveAlt:
            return SKTexture(image: #imageLiteral(resourceName: "snakeLava_ani"))
        case .dead:
            return SKTexture(image: #imageLiteral(resourceName: "snakeLava_dead"))
        case .ghost:
            return SKTexture(image: #imageLiteral(resourceName: "snakeLava_ghost"))
        }
    }
}

final class SnakeNode: SKSpriteNode {
    
    fileprivate var hitCount = 0
    
    fileprivate func setup() {
        guard let body = physicsBody else {
            assertionFailure("Snake node has no physics body")
            return
        }
        
        body.categoryBitMask = Physics.category
        body.contactTestBitMask = Physics.contact
        body.collisionBitMask = Physics.collision
        body.isDynamic = false
        body.affectedByGravity = false
        lightingBitMask = 1
    }
}

extension SnakeNode: Enemy {
    func hitWithArrow() {
        guard hitCount == 0 else { return }
        hitCount += 1
        
        let deadTextureAction = SKAction.setTexture(SnakeTexture.dead.texture())
        let wait = SKAction.wait(forDuration: 1.0)
        
        let ghostTextureAction = SKAction.setTexture(SnakeTexture.ghost.texture())
        let floatAnimation = SKAction.moveBy(x: 0, y: 50, duration: 0.5)
        let opaqueAnimation = SKAction.fadeAlpha(by: 0.5, duration: 0.5)
        
        let fadeOutAnimation = SKAction.fadeOut(withDuration: 0.5)
        let removeAction = SKAction.removeFromParent()
        
        let animateGhostAction = SKAction.group([ghostTextureAction, floatAnimation, opaqueAnimation])
        let actionSequence = SKAction.sequence([deadTextureAction, wait, animateGhostAction, fadeOutAnimation, removeAction])
        run(actionSequence)
    }
}

extension SnakeNode: LifecycleListener {
    func didMoveToScene() {
        setup()
    }
}
