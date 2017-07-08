//
//  WaterSceneNode.swift
//  GravityWizard2
//
//  Created by scott mehus on 7/5/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit

fileprivate enum Node: String {
    case fish = "//fish"
    case water = "//water"
    case base = "//base"
    
    var categoryBitMask: UInt32 {
        switch self {
        case .fish:
            return PhysicsCategory.None
        case .water:
            return PhysicsCategory.water
        default: return PhysicsCategory.None
        }
    }
    
    var contactBitMask: UInt32 {
        switch self {
        case .fish:
            return PhysicsCategory.None
        case .water:
            return PhysicsCategory.Hero | PhysicsCategory.arrow
        default: return PhysicsCategory.None
        }
    }
    
    var collisionBitMask: UInt32 {
        switch self {
        case .fish:
            return PhysicsCategory.None
        case .water:
            return PhysicsCategory.None
        default: return PhysicsCategory.None
        }
    }
}

final class WaterSceneNode: SKNode {
    
    fileprivate var fish: SKSpriteNode?
    fileprivate var base: SKSpriteNode?
    
    fileprivate func setupNodes() {
        
        guard
            let baseNode = childNode(withName: Node.base.rawValue) as? SKSpriteNode
        else {
            conditionFailure(with: "Failed to resolve fish")
            return
        }
        
        base = baseNode
        fish = buildFish()
        
        enumerateChildNodes(withName: Node.water.rawValue) { (node, stop) in
            guard
                let sprite = node as? SKSpriteNode,
                let _ = sprite.physicsBody
            else { return }
            
            sprite.physicsBody?.categoryBitMask = Node.water.categoryBitMask
            sprite.physicsBody?.contactTestBitMask = Node.water.contactBitMask
            sprite.physicsBody?.collisionBitMask = Node.water.collisionBitMask
        }
        
        
    }
    
    private func buildFish() -> SKSpriteNode? {
        guard let baseSprite = base else {
            conditionFailure(with: "Missing base when setting up fish")
            return nil
        }
        
        let fishSprite = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName: "red-fish-1")))
        let randomY = Int.random(min: 20, max: 100)
        let randomX = Int.random(min: 0, max: Int(baseSprite.size.width))
        fishSprite.position = CGPoint(x: randomX, y: randomY)
        fishSprite.zPosition = 9.0
        addChild(fishSprite)
        
        return fishSprite
    }
    
    fileprivate func startFishAnimation() {
        guard
            let fishSprite = fish,
            let baseSprite = base
        else {
            conditionFailure(with: "Faield to unwrap sprites")
            return
        }
        
        let offset = fishSprite.size.width / 2
        let randomBool = Int.random(min: 0, max: 1) != 0
        let firstPoint = randomBool
            ? CGPoint(x: (baseSprite.position.x + offset), y: fishSprite.position.y)
            : CGPoint(x: baseSprite.position.x + (baseSprite.size.width - fishSprite.size.width), y: fishSprite.position.y)
        
        let firstflip = randomBool ? SKAction.scaleX(to: -1, duration: 0.3) : SKAction.scaleX(to: 1, duration: 0.3)
        
        let secondPoint = !randomBool
            ? CGPoint(x: (baseSprite.position.x + offset), y: fishSprite.position.y)
            : CGPoint(x: baseSprite.position.x + (baseSprite.size.width - fishSprite.size.width), y: fishSprite.position.y)
        
        let secondFlip = !randomBool ? SKAction.scaleX(to: -1, duration: 0.3) : SKAction.scaleX(to: 1, duration: 0.3)
        
        
        let randomDuration = Int.random(min: 5, max: 15)
        let firstMoveAction = SKAction.move(to: firstPoint, duration: Double(randomDuration))
        let secondMoveAction = SKAction.move(to: secondPoint, duration: Double(randomDuration))
        
        let moveSequence = SKAction.sequence([firstflip, firstMoveAction, secondFlip, secondMoveAction])
        
        fishSprite.run(SKAction.repeatForever(moveSequence))

    }
}

extension WaterSceneNode: LifecycleListener {
    func didMoveToScene() {
        setupNodes()
        startFishAnimation()
    }
}
