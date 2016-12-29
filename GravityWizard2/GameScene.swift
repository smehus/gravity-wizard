//
//  GameScene.swift
//  GravityWizard2
//
//  Created by scott mehus on 12/20/16.
//  Copyright © 2016 scott mehus. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, LifecycleEmitter {

    /// Scense
    fileprivate var wizardScene: SKScene!
    
    /// Nodes
    fileprivate var wizardNode: WizardNode?
    fileprivate var bloodNode: BloodNode?
    fileprivate var radialMarker: SKSpriteNode?
    fileprivate var breakableRocks: BreakableRocksNode?
    
    fileprivate var light: SKNode?
    
    // Effects
    fileprivate var radialGravity: SKFieldNode?
    
    
    /// Constants
    fileprivate let bloodExplosionCount = 5
    
    
    /// Trackables
    fileprivate var lastUpdateTimeInterval: TimeInterval = 0
    fileprivate var deltaTime: TimeInterval = 0
    fileprivate var trackingArrowVelocity = false
    fileprivate var arrowVelocity: CGFloat = 0
    fileprivate var currentProjectile: SKSpriteNode?
    
    /// statics
    fileprivate let particleFactory = ParticleFactory.sharedFactory
    
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        setupNodes()
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
    
    fileprivate func updateLightPosition() {
        guard let wizardNode = wizardNode, let light = light else { return }
        let target = convert(wizardNode.position, from: wizardNode.parent!)
        
        let lerpX = (target.x - light.position.x) * 0.05
        let lerpY = (target.y - light.position.y) * 0.05
        
        light.position.x += lerpX
        light.position.y += lerpY
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
        let _ = touch.location(in: self)
        
        if let _ = radialGravity {
            removeRadialGravity()
        } else if trackingArrowVelocity == false {
            trackingArrowVelocity = true
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        
        if trackingArrowVelocity {
            shootArrow(at: touchLocation, velocityMultiply: arrowVelocity)
            trackingArrowVelocity = false
            arrowVelocity = 0
        }
        
    }
    
    fileprivate func shootArrow(at point: CGPoint, velocityMultiply: CGFloat) {
        guard let wizardNode = wizardNode else { return }
        let startingPosition = convert(wizardNode.position, from: wizardNode.parent!)
        
        let arrow = SKSpriteNode(imageNamed: Images.arrow)
        arrow.physicsBody = SKPhysicsBody(circleOfRadius: arrow.texture!.size().width / 2)
        arrow.physicsBody?.affectedByGravity = true
        arrow.physicsBody?.categoryBitMask = PhysicsCategory.Arrow
        arrow.physicsBody?.contactTestBitMask = PhysicsCategory.Edge | PhysicsCategory.Ground
        arrow.physicsBody?.collisionBitMask = PhysicsCategory.Edge | PhysicsCategory.Ground
        arrow.physicsBody?.fieldBitMask = PhysicsCategory.None
        arrow.position = startingPosition
        addChild(arrow)
        
        let newVelocity =  (point - startingPosition).normalized() * velocityMultiply
        arrow.physicsBody!.velocity = CGVector(point: newVelocity)
        
        currentProjectile = arrow
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
    
    fileprivate func checkWizardVelocity() {
        guard let wizardNode = wizardNode else { return }
        if wizardNode.physicsBody!.velocity.dy > 50 {
            wizardNode.gravityState = .climbing
        } else if wizardNode.physicsBody!.velocity.dy < -20 {
            wizardNode.gravityState = .falling
        } else {
            wizardNode.gravityState = .ground
        }
    }
    
    fileprivate func explosion(at point: CGPoint) {
        let explode = particleFactory.explosion(intensity: 0.25 * CGFloat(4 + 1))
        explode.position = point
        explode.run(SKAction.removeFromParentAfterDelay(2.0))
        addChild(explode)
    }
}

extension GameScene {
    override func update(_ currentTime: TimeInterval) {
        checkWizardVelocity()
        
        if lastUpdateTimeInterval > 0 {
            deltaTime = currentTime - lastUpdateTimeInterval
        } else {
            deltaTime = 0
        }
        
        lastUpdateTimeInterval = currentTime
        
        if trackingArrowVelocity {
            let normalizedDelta: CGFloat = CGFloat(deltaTime) * 1000
            arrowVelocity += normalizedDelta
        }
        
        if let arrow = currentProjectile {
            updateDirection(with: arrow)
        }
    }
    
    override func didSimulatePhysics() {
        updateLightPosition()
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
