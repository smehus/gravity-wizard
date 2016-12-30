//
//  GameScene.swift
//  GravityWizard2
//
//  Created by scott mehus on 12/20/16.
//  Copyright © 2016 scott mehus. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, Game, LifecycleEmitter {
    
    var currentLevel: Level = .one

    /// Scense
    var wizardScene: SKScene!
    
    /// Nodes
    var wizardNode: WizardNode?
    var bloodNode: BloodNode?
    var radialMarker: SKSpriteNode?
    var breakableRocks: BreakableRocksNode?
    
    var light: SKNode?
    
    // Effects
    var radialGravity: SKFieldNode?
    
    
    /// Constants
    let bloodExplosionCount = 5
    
    
    /// Trackables
    var lastUpdateTimeInterval: TimeInterval = 0
    var deltaTime: TimeInterval = 0
    var trackingArrowVelocity = false
    var arrowVelocity: CGFloat = 0
    var currentProjectile: SKSpriteNode?
    
    /// Statics
    var particleFactory = ParticleFactory.sharedFactory
    
    /// Touches
    var initialTouchPoint: CGPoint?
    
    static func generateGameScene(level: Level) -> GameScene? {
        let gameScene = SKScene(fileNamed: "Level\(level.rawValue)") as? GameScene
        gameScene?.currentLevel = level
        return gameScene
        
    }
    
    func createBloodExplosion(with sprite: SKSpriteNode) {
        guard let node = bloodNode else { return }
        let point = convert(sprite.position, from: sprite.parent!)
        
        let bleedAction = SKAction.run {
            let dup = node.copy() as! BloodNode
            dup.position = point
            self.addChild(dup)
            
            let vector = CGVector(dx: Int.random(min: -1, max: 1), dy: 4)
            dup.physicsBody?.applyImpulse(vector)
        }
        
        let wait = SKAction.wait(forDuration: 0.0)
        run(SKAction.repeat(SKAction.sequence([bleedAction, wait]), count: bloodExplosionCount))
    }
    
    func createRadialGravity(at point: CGPoint) -> SKFieldNode {
        let field = SKFieldNode.radialGravityField()
        field.position = point
        field.strength = 30
        field.falloff = 0
        field.categoryBitMask = PhysicsCategory.RadialGravity
        field.minimumRadius = 2
        
        
        let marker = SKSpriteNode(imageNamed: Images.radialGravity)
        marker.position = point
        radialMarker = marker
        
        
        addChildren(children: [field, marker])
        return field
    }
    
    func createArrow(at position: CGPoint) -> SKSpriteNode {
        let arrow = SKSpriteNode(imageNamed: Images.arrow)
        arrow.physicsBody = SKPhysicsBody(circleOfRadius: arrow.texture!.size().width / 2)
        arrow.physicsBody?.affectedByGravity = true
        arrow.physicsBody?.categoryBitMask = PhysicsCategory.Arrow
        arrow.physicsBody?.contactTestBitMask = PhysicsCategory.Edge | PhysicsCategory.Ground
        arrow.physicsBody?.collisionBitMask = PhysicsCategory.Edge | PhysicsCategory.Ground
        arrow.physicsBody?.fieldBitMask = PhysicsCategory.None
        arrow.position = position
        return arrow
    }
    
    func removeRadialGravity() {
        guard let field = radialGravity, let marker = radialMarker else { return }
        self.removeChildren(in: [field, marker])
        radialGravity = nil
        radialMarker = nil
    }
    
    /// Used for Arrow launching like angry birds
    func launchArrow(at point: CGPoint, velocityMultiply: CGFloat) {
        guard let wizardNode = wizardNode else { return }
        let startingPosition = convert(wizardNode.position, from: wizardNode.parent!)
        
        let arrow = createArrow(at: startingPosition)
        addChild(arrow)
        
        /// reversed point diff
        let newPoint = startingPosition - point
        let newVelocity = newPoint.normalized() * velocityMultiply
        arrow.physicsBody!.velocity = CGVector(point: newVelocity)
        
        currentProjectile = arrow
    }
    
    /// Used for shooting enemies like a gun
    func shootArrow(at point: CGPoint, velocityMultiply: CGFloat) {
        guard let wizardNode = wizardNode else { return }
        let startingPosition = convert(wizardNode.position, from: wizardNode.parent!)
        
        let arrow = createArrow(at: startingPosition)
        addChild(arrow)
        
        let newVelocity =  (point - startingPosition).normalized() * velocityMultiply
        arrow.physicsBody!.velocity = CGVector(point: newVelocity)
        
        currentProjectile = arrow
    }
}
