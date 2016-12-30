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
    fileprivate var wizardScene: SKScene!
    
    /// Nodes
    fileprivate var wizardNode: WizardNode?
    fileprivate var bloodNode: BloodNode?
    fileprivate var radialMarker: SKSpriteNode?
    fileprivate var breakableRocks: BreakableRocksNode?
    
    var light: SKNode?
    
    // Effects
    fileprivate var radialGravity: SKFieldNode?
    
    
    /// Constants
    fileprivate let bloodExplosionCount = 5
    
    
    /// Trackables
    var lastUpdateTimeInterval: TimeInterval = 0
    var deltaTime: TimeInterval = 0
    fileprivate var trackingArrowVelocity = false
    fileprivate var arrowVelocity: CGFloat = 0
    fileprivate var currentProjectile: SKSpriteNode?
    
    /// Statics
    var particleFactory = ParticleFactory.sharedFactory
    
    /// Touches
    fileprivate var initialTouchPoint: CGPoint?
    
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        setupNodes()
    }
    
    static func generateGameScene(level: Level) -> GameScene? {
        let gameScene = SKScene(fileNamed: "Level\(level.rawValue)") as? GameScene
        gameScene?.currentLevel = level
        return gameScene
        
    }
    
    fileprivate func setupNodes() {
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
    
    fileprivate func updateDirection(with sprite: SKSpriteNode) {
        guard let body = sprite.physicsBody else { return }
        let shortest = shortestAngleBetween(sprite.zRotation, angle2: body.velocity.angle)
        let rotateRadiansPerSec = 4.0 * π
        let amountToRotate = min(rotateRadiansPerSec * CGFloat(deltaTime), abs(shortest))
        sprite.zRotation += shortest.sign() * amountToRotate
    }
}

extension GameScene {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else { return }
        let touchPoint = touch.location(in: self)
        
        if let _ = radialGravity {
            removeRadialGravity()
        } else if trackingArrowVelocity == false {
            trackingArrowVelocity = true
            initialTouchPoint = touchPoint
        }
        
        if let wizard = wizardNode {
            wizard.face(towards: direction(for: touchPoint, with: wizard))
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let touch = touches.first else { return }
        let touchPoint = touch.location(in: self)
        
        if let initial = initialTouchPoint, trackingArrowVelocity {
            let diff = initial - touchPoint
            let vel = diff.length() * 2
            arrowVelocity = vel
        }
        
        if let wizard = wizardNode {
            wizard.face(towards: direction(for: touchPoint, with: wizard))
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        
        if trackingArrowVelocity {
            // Difference between this point and initial point
            
//            shootArrow(at: touchLocation, velocityMultiply: arrowVelocity)
            launchArrow(at: touchLocation, velocityMultiply: arrowVelocity)
            trackingArrowVelocity = false
            arrowVelocity = 0
        }
    }
    
    fileprivate func direction(for point: CGPoint, with node: SKSpriteNode) -> Direction {
        let nodePosition = convert(node.position, from: node.parent!)
        
        if nodePosition.x > point.x {
            return .right
        }
        
        if nodePosition.x < point.x {
            return .left
        }
        
        return .right
    }
    
    /// Used for Arrow launching like angry birds
    fileprivate func launchArrow(at point: CGPoint, velocityMultiply: CGFloat) {
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
    fileprivate func shootArrow(at point: CGPoint, velocityMultiply: CGFloat) {
        guard let wizardNode = wizardNode else { return }
        let startingPosition = convert(wizardNode.position, from: wizardNode.parent!)
    
        let arrow = createArrow(at: startingPosition)
        addChild(arrow)
        
        let newVelocity =  (point - startingPosition).normalized() * velocityMultiply
        arrow.physicsBody!.velocity = CGVector(point: newVelocity)
        
        currentProjectile = arrow
    }
    
    fileprivate func createArrow(at position: CGPoint) -> SKSpriteNode {
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
    
    fileprivate func removeRadialGravity() {
        guard let field = radialGravity, let marker = radialMarker else { return }
        self.removeChildren(in: [field, marker])
        radialGravity = nil
        radialMarker = nil
    }
    
    fileprivate func createRadialGravity(at point: CGPoint) -> SKFieldNode {
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
    
    fileprivate func createBloodExplosion(with sprite: SKSpriteNode) {
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
}

extension GameScene {
    override func update(_ currentTime: TimeInterval) {
        updateNodeGravityState(with: wizardNode)
        
        if lastUpdateTimeInterval > 0 {
            deltaTime = currentTime - lastUpdateTimeInterval
        } else {
            deltaTime = 0
        }
        
        lastUpdateTimeInterval = currentTime
        
        if let arrow = currentProjectile {
            updateDirection(with: arrow)
        }
    }
    
    override func didSimulatePhysics() {
        updateFollowNodePosition(followNode: light, originNode: wizardNode)
    }
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if let wizardNode = wizardNode {
            if collision == PhysicsCategory.Ground | PhysicsCategory.Wizard, !wizardNode.isGrounded {
                wizardNode.isGrounded = true
            }
            
            if collision == PhysicsCategory.Rock | PhysicsCategory.Wizard {
                createBloodExplosion(with: wizardNode)
            }
            
            if collision == PhysicsCategory.Blood | PhysicsCategory.Ground {
                let node = contact.bodyA.categoryBitMask == PhysicsCategory.Blood ? contact.bodyA.node : contact.bodyB.node
                
                if let blood = node as? BloodNode {
                    blood.hitGround()
                }
            }
            
            if collision == PhysicsCategory.Arrow | PhysicsCategory.Edge {
                if let arrow = currentProjectile {
                    radialGravity = createRadialGravity(at: arrow.position)
                    
                    explosion(at: arrow.position)
                    arrow.removeFromParent()
                }
            }
            
            Breakable: if collision == PhysicsCategory.Arrow | PhysicsCategory.BreakableFormation {
                if let arrow = currentProjectile {
                    explosion(at: arrow.position)
                    guard let breakableRocks = breakableRocks else { break Breakable }
                    breakableRocks.breakRocks()
                    arrow.removeFromParent()
                }
            }
            
            if collision == PhysicsCategory.Arrow | PhysicsCategory.Ground {
                if let arrow = currentProjectile {
                    arrow.physicsBody = nil
                }
            }
            
            if collision == PhysicsCategory.Arrow | PhysicsCategory.vikingBodyPart {
                let bodyPart = contact.bodyA.categoryBitMask == PhysicsCategory.vikingBodyPart ? contact.bodyA.node : contact.bodyB.node
                
                if let viking = bodyPart?.parent! as? VikingNode, !viking.isWounded {
                    viking.arrowHit()
                }
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
