//
//  VerticalSlidingPlatform.swift
//  GravityWizard2
//
//  Created by scott mehus on 6/7/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit

fileprivate struct Names {
    static let platform = "platform"
    static let door = "//door"
    static let sliderBar = "slider-bar"
}

fileprivate enum Physics {
    case door
    case platform
    
    var categoryBitMask: UInt32 {
        switch self {
        case .door: return PhysicsCategory.LevelComplete
        case .platform: return PhysicsCategory.Ground
        }
    }
    
    var contactTestBitMask: UInt32 {
        switch self {
        case .door: return PhysicsCategory.Hero
        case .platform: return PhysicsCategory.None
        }
    }
    
    var collisionBitMask: UInt32 {
        switch self {
        case .door: return PhysicsCategory.None
        case .platform: return PhysicsCategory.Hero
        }
    }
}

let MOVE_DURATION = 3.0

final class VerticalSlidingPlatform: SKNode {
    
    fileprivate var platform: SKSpriteNode?
    fileprivate var door: SKSpriteNode?
    fileprivate var sliderBar: SKSpriteNode?
    
    fileprivate var sceneHeight: CGFloat {
        guard let scene = parent as? SKScene else {
            return 0
        }
        
        return scene.size.height
    }
    
    fileprivate func setupSprites() {
        guard
            let platformSprite = childNode(withName: Names.platform) as? SKSpriteNode,
            let doorSprite = childNode(withName: Names.door) as? SKSpriteNode,
            let bar = childNode(withName: Names.sliderBar) as? SKSpriteNode
        else {
            conditionFailure(with: "Failed to resolve sprites")
            return
        }
        
        platform = platformSprite
        door = doorSprite
        sliderBar = bar
    }
    
    fileprivate func setupPhysics() {
        guard
            let _ = platform?.physicsBody,
            let _ = door?.physicsBody
        else {
            conditionFailure(with: "Failed to unwrap physics bodies")
            return
        }
        
        platform?.physicsBody?.categoryBitMask = Physics.platform.categoryBitMask
        platform?.physicsBody?.contactTestBitMask = Physics.platform.contactTestBitMask
        platform?.physicsBody?.collisionBitMask = Physics.platform.collisionBitMask
        platform?.physicsBody?.affectedByGravity = false
        platform?.physicsBody?.isDynamic = false
        
        door?.physicsBody?.categoryBitMask = Physics.door.categoryBitMask
        door?.physicsBody?.contactTestBitMask = Physics.door.contactTestBitMask
        door?.physicsBody?.collisionBitMask = Physics.door.collisionBitMask
        door?.physicsBody?.affectedByGravity = false
        door?.physicsBody?.isDynamic = true
    }
    
    fileprivate func setupJoint() {
        guard
            let platformBody = platform?.physicsBody,
            let doorSprite = door,
            let doorBody = door?.physicsBody,
            let gameScene = scene as? GameScene
            else {
                conditionFailure(with: "Failed to unwrap physics bodies")
                return
        }
        
        var convertedPOS = gameScene.convert(doorSprite.position, from: doorSprite.parent!)
        let anchor = convertedPOS.offset(dx: 0, dy: doorSprite.size.height/2)
        let joint = SKPhysicsJointFixed.joint(withBodyA: platformBody, bodyB: doorBody, anchor: anchor)
        gameScene.add(joint: joint)
    }
    
    fileprivate func beginAnimating() {
        guard let barHeight = sliderBar?.size.height else {
            conditionFailure(with: "Missing slider bar sprite")
            return
        }
        
        let move = SKAction.move(by: CGVector(dx: 0, dy: barHeight), duration: MOVE_DURATION)
        let moveSequence = SKAction.sequence([move, move.reversed()])
        platform?.run(SKAction.repeatForever(moveSequence))
        
    }
}

extension VerticalSlidingPlatform: LifecycleListener {
    func didMoveToScene() {
        setupSprites()
        setupPhysics()
        setupJoint()
        beginAnimating()
    }
}
