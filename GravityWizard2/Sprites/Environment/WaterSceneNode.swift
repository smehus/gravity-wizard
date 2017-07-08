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
        
        
        let xVector = CGVector(dx: 100, dy: 0)
        let flipForward = SKAction.scaleX(to: 1.0, duration: 0.3)
        let flipBackwards = SKAction.scaleX(to: -1.0, duration: 0.3)
        let xMoveAction = SKAction.move(by: xVector, duration: 3.0)
        let xMoveSequence = SKAction.sequence([flipForward, xMoveAction, flipBackwards, xMoveAction.reversed()])
        
        let finalGroup = SKAction.group([xMoveSequence])
        fishSprite.run(SKAction.repeatForever(finalGroup))
    }
}

extension WaterSceneNode: GameLoopListener {
    func update(withDelta deltaTime: Double) {
        
    }
}

extension WaterSceneNode: LifecycleListener {
    func didMoveToScene() {
        setupNodes()
        startFishAnimation()
    }
}
