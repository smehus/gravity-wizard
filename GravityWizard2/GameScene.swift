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
    var trackingProjectileVelocity = false
    var projectileVelocity: CGFloat = 0
    var currentProjectile: SKNode?
    var currentPojectileType: ProjectileType = .gravity
    
    /// Statics
    var particleFactory = ParticleFactory.sharedFactory
    
    /// Touches
    var initialTouchPoint: CGPoint?
    
    static func generateGameScene(level: Level) -> GameScene? {
        let gameScene = SKScene(fileNamed: "Level\(level.rawValue)") as? GameScene
        gameScene?.currentLevel = level
        return gameScene
        
    }
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        setupNodes()
    }
    
    func setupNodes() {
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsBody?.categoryBitMask = PhysicsCategory.Edge
        emitDidMoveToView()
        
        wizardScene = SKScene(fileNamed: "Wizard")
        wizardNode = childNode(withName: "//Wizard") as? WizardNode
        
        breakableRocks = childNode(withName: "//BreakableRocks") as? BreakableRocksNode
        light = childNode(withName: "FollowLight")
        
        if let node = BloodNode.generateBloodNode() {
            bloodNode = node
        }
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
        field.isEnabled = false
        
        
        let marker = SKSpriteNode(imageNamed: Images.spark)
        marker.position = point
        radialMarker = marker
        
        
        addChildren(children: [field, marker])
        return field
    }
    
    func createArrow(at position: CGPoint) -> ArrowNode {
        let arrow = ArrowNode()
        arrow.position = position
        return arrow
    }
    
    func createGravityProjectile(at point: CGPoint) -> GravityProjectile? {
        guard let node = GravityProjectile.generateGravityProjectile() else { return nil }
        node.position = point
        return node
    }
    
    func removeRadialGravity() {
        guard let field = radialGravity, let marker = radialMarker else { return }
        self.removeChildren(in: [field, marker])
        radialGravity = nil
        radialMarker = nil
    }
    
    func launchProjectile(at point: CGPoint, with velocity: CGFloat, and type: ProjectileType) {
        switch type {
        case .arrow:
            launchArrow(at: point, velocityMultiply: velocity)
        case .gravity:
            launchGravityProjectile(at: point, velocityMultiply: velocity)
        }
    }
    
    /// Used for Arrow launching like angry birds
    func launchGravityProjectile(at point: CGPoint, velocityMultiply: CGFloat) {
        guard let wizardNode = wizardNode else { return }
        let startingPosition = convert(wizardNode.position, from: wizardNode.parent!)
        
        guard let projectile = createGravityProjectile(at: startingPosition) else { return }
        projectile.move(toParent: self)
        
        /// reversed point diff
        let newPoint = startingPosition - point
        let newVelocity = newPoint.normalized() * velocityMultiply
        projectile.launch(at: CGVector(point: newVelocity))
        
        
        
        currentProjectile = projectile
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
        arrow.launch(at: CGVector(point: newVelocity))
        
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

extension GameScene {
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTimeInterval > 0 {
            deltaTime = currentTime - lastUpdateTimeInterval
        } else {
            deltaTime = 0
        }
        
        lastUpdateTimeInterval = currentTime
    }
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if let wizardNode = wizardNode {
            
            // Set if wizard is on ground
            if collision == PhysicsCategory.Ground | PhysicsCategory.Wizard, !wizardNode.isGrounded {
                wizardNode.isGrounded = true
            }
            
            // Create blood from rock hitting wizard
            if collision == PhysicsCategory.Rock | PhysicsCategory.Wizard {
                createBloodExplosion(with: wizardNode)
            }
            
            // Create blood splatter from blood hitting gournd
            if collision == PhysicsCategory.Blood | PhysicsCategory.Ground {
                let node = contact.bodyA.categoryBitMask == PhysicsCategory.Blood ? contact.bodyA.node : contact.bodyB.node
                
                if let blood = node as? BloodNode {
                    blood.hitGround()
                }
            }
            
            // Remove arrow if it hits the edge of the screen?
            if collision == PhysicsCategory.Arrow | PhysicsCategory.Edge {
                if let arrow = currentProjectile {
                    arrow.removeFromParent()
                }
            }
            
            // Break apart rock collection when arrow hits it
            Breakable: if collision == PhysicsCategory.Arrow | PhysicsCategory.BreakableFormation {
                if let arrow = currentProjectile {
                    explosion(at: arrow.position)
                    guard let breakableRocks = breakableRocks else { break Breakable }
                    breakableRocks.breakRocks()
                    arrow.removeFromParent()
                }
            }
            
            // Stick arrow at angle if it hits ground
            if collision == PhysicsCategory.Arrow | PhysicsCategory.Ground {
                if let arrow = currentProjectile {
                    arrow.physicsBody = nil
                }
            }
            
            // Arrow hits a viking node
            if collision == PhysicsCategory.Arrow | PhysicsCategory.VikingBodyPart {
                let bodyPart = contact.bodyA.categoryBitMask == PhysicsCategory.VikingBodyPart ? contact.bodyA.node : contact.bodyB.node
                
                if let viking = bodyPart?.parent! as? VikingNode, !viking.isWounded {
                    viking.arrowHit()
                }
            }
            
            // Gravity projectile hits ground
            if collision == PhysicsCategory.GravityProjectile | PhysicsCategory.Ground {
                
            }
            
            switch collision.collisionCombination() {
            case .none:
                return
            case .gravityProjectileHitsGround:
                gravityProjectileHitGround(with: contact)
            }
            
        }
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        WizardGround: if collision == PhysicsCategory.Wizard | PhysicsCategory.Ground {
            guard let wizardNode = wizardNode else { break WizardGround }
            wizardNode.isGrounded = false
        }
    }
}

// MARK: - Collisions
extension GameScene {
    func gravityProjectileHitGround(with contact: SKPhysicsContact) {
        
    }
}
