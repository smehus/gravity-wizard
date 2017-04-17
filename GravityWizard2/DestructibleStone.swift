//
//  DestructibleStone.swift
//  GravityWizard2
//
//  Created by scott mehus on 4/4/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import Foundation
import SpriteKit

fileprivate enum Texture: Int {
    case assembled = 0
    case weakened
    case broken
    
    func next() -> Texture {
        guard let texture = Texture(rawValue: rawValue + 1) else {
            return .assembled
        }
        
        return texture
    }
    
    func textureImage() -> SKTexture {
        return SKTexture(imageNamed: "\(Local.Images.stoneBaseString)\(rawValue)")
    }
}

fileprivate struct Local {
    struct Images {
        static let stoneBaseString = "breakable-stone-block-"
    }
    
    struct Physics {
        static let category = PhysicsCategory.destructible
        static let contact = PhysicsCategory.Arrow
        static let collision = PhysicsCategory.Arrow | PhysicsCategory.Ground | PhysicsCategory.Hero
    }
}

final class DesctructibleStone: SKSpriteNode {
    
    fileprivate var hitCount = 0
    fileprivate var currentTexture: Texture = .assembled
    
    
    func setupPhysicsBody() {
        guard let body = physicsBody else {
            assertionFailure("Destructible stone has no physics body")
            return
        }
        
        body.affectedByGravity = false
        body.isDynamic = false
        body.pinned = false
        body.categoryBitMask = Local.Physics.category
        body.contactTestBitMask = Local.Physics.contact
        body.collisionBitMask  = Local.Physics.collision
    }
    
    func hit() {
        if currentTexture == .broken {
            destroy()
        } else {
            currentTexture = currentTexture.next()
            let animation = SKAction.animate(with: [currentTexture.textureImage()], timePerFrame: 0.3)
            run(animation)
        }
    }
    
    fileprivate func destroy() {
        if let stoneParent = parent as? BreakableStoneStructure {
            let main = SKTexture(image: #imageLiteral(resourceName: "rock-shard"))
            let animText = createSmokeTextures()
            stoneParent.createExplosion(at: position, mainTexture: main, animationTextures: animText)
        }

        let removeAction = SKAction.removeFromParent()
        run(removeAction)
    }
    
    fileprivate func createSmokeTextures() -> [SKTexture] {
        var animationTextures: [SKTexture] = []
        
        for i in 0...24 {
            let name = "whitePuff\(i)"
            let text = SKTexture(imageNamed: name)
            animationTextures.append(text)
        }
        
        return animationTextures
    }
}
