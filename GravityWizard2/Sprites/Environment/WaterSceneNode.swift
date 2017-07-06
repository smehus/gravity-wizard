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
            let baseNode = childNode(withName: Node.base.rawValue) as? SKSpriteNode,
            let fishNode = childNode(withName: Node.fish.rawValue) as? SKSpriteNode
        else {
            conditionFailure(with: "Failed to resolve fish")
            return
        }
        
        base = baseNode
        fish = fishNode
        
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
        
        let swimAction = SKAction.scaleX(by: 0.2, y: 0, duration: 0.3)
        let repeatedSwim = SKAction.repeatForever(SKAction.sequence([swimAction, swimAction.reversed()]))
        
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
