//
//  WaterSceneNode.swift
//  GravityWizard2
//
//  Created by scott mehus on 7/5/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit

fileprivate enum Node: String, SpriteConfiguration {
    case fish = "fish"
    case water = "water-scene"
    case base = "base"
    case foliage = "water-foliage"
    
    var name: String {
        return "\(rawValue)"
    }
    
    var categoryBitMask: UInt32 {
        switch self {
        case .fish:
            return PhysicsCategory.None
        case .water:
            return PhysicsCategory.water
        default: return PhysicsCategory.None
        }
    }
    
    var contactTestBitMask: UInt32 {
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
            return PhysicsCategory.Hero | PhysicsCategory.arrow
        default: return PhysicsCategory.None
        }
    }
    
    var isDynamic: Bool {
        switch self {
        case .fish:
            return false
        case .water:
            return false
        case .base:
            return false
        default:
            return false
        }
    }
    
    var affectedByGravity: Bool {
        switch self {
        case .fish:
            return false
        case .water:
            return false
        case .base:
            return false
        default:
            return false
        }
    }
    
    var allowsRotation: Bool {
        switch self {
        case .fish:
            return true
        case .water:
            return false
        case .base:
            return false
        default:
            return false
        }
    }
}
        
final class WaterSceneNode: SKNode {
    
    fileprivate var fish: SKSpriteNode?
    fileprivate var base: SKSpriteNode?
    fileprivate var waterScene: SKSpriteNode?
    fileprivate var foliageScene: SKSpriteNode?
    
    fileprivate func setupNodes() {
        
        guard
            let water = childNode(withName: Node.water.name) as? SKSpriteNode,
            let foliage = childNode(withName: Node.foliage.name) as? SKSpriteNode,
            let baseNode = childNode(withName: Node.base.name) as? SKSpriteNode
        else {
            conditionFailure(with: "Failed to resolve fish")
            return
        }
        
        let foilageShader = SKShader(fileNamed: "wave.fsh")
        foliage.shader = foilageShader
        
        water.configure(with: Node.water)
        
        waterScene = water
        base = baseNode
        fish = buildFish()
        
        waterScene?.zPosition = 10
        fish?.zPosition = 9
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
