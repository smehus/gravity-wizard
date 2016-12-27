//
//  GameScene.swift
//  GravityWizard2
//
//  Created by scott mehus on 12/20/16.
//  Copyright © 2016 scott mehus. All rights reserved.
//

import SpriteKit
import GameplayKit

struct Images {
    static let radialGravity = "deathtex1"
    static let arrow = "arrow"
    static let arrowBig = "arrow_big"
}

struct Actions {
    static let lightMoveAction = "lightMoveAction"
}

struct PhysicsCategory {
    static let None:  UInt32 = 0
    static let Wizard: UInt32 = 0x1 << 1
    static let Ground: UInt32 = 0x1 << 2
    static let Rock:   UInt32 = 0x1 << 3
    static let Edge:  UInt32 = 0x1 << 4
    static let Arrow: UInt32 = 0x1 << 5
    static let Blood :UInt32 = 0x1 << 6
    static let RadialGravity:  UInt32 = 0x1 << 7
    static let BreakableFormation:  UInt32 = 0x1 << 8
}

class GameScene: SKScene, LifecycleEmitter {

    /// Scense
    fileprivate var wizardScene: SKScene!
    
    /// Nodes
    fileprivate var wizardNode: WizardNode!
    fileprivate var bloodNode: BloodNode?
    fileprivate var radialMarker: SKSpriteNode?
    fileprivate var breakableRocks: BreakableRocksNode!
    
    fileprivate var light: SKNode!
    
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
    
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        setupNodes()
    }
    
    fileprivate func setupNodes() {
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsBody?.categoryBitMask = PhysicsCategory.Edge
        emitDidMoveToView()

        wizardScene = SKScene(fileNamed: "Wizard")
        wizardNode = childNode(withName: "//Wizard") as! WizardNode
        
        breakableRocks = childNode(withName: "//BreakableRocks") as! BreakableRocksNode
        light = childNode(withName: "//FollowLight")
        
        if let node = BloodNode.generateBloodNode() {
            bloodNode = node
        }
        
    }
    
    fileprivate func updateLightPosition() {
        let lightTarget = convert(wizardNode.position, from: wizardNode.parent!)
        
        let lerpX = (lightTarget.x - light.position.x) * 0.01
        let lerpY = (lightTarget.y - light.position.y) * 0.01
        
        let moveAction = SKAction.moveBy(x: lerpX, y: lerpY, duration: 0.1)
        light.run(moveAction, withKey: Actions.lightMoveAction)
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
        if wizardNode.physicsBody!.velocity.dy > 50 {
            wizardNode.gravityState = .climbing
        } else if wizardNode.physicsBody!.velocity.dy < -20 {
            wizardNode.gravityState = .falling
        } else {
            wizardNode.gravityState = .ground
        }
    }
    
    fileprivate func explosion(intensity: CGFloat) -> SKEmitterNode {
        let emitter = SKEmitterNode()
        let particleTexture = SKTexture(imageNamed: "spark")
        
        emitter.zPosition = 2
        emitter.particleTexture = particleTexture
        emitter.particleBirthRate = 4000 * intensity
        emitter.numParticlesToEmit = Int(400 * intensity)
        emitter.particleLifetime = 2.0
        emitter.emissionAngle = CGFloat(90.0).degreesToRadians()
        emitter.emissionAngleRange = CGFloat(360.0).degreesToRadians()
        emitter.particleSpeed = 600 * intensity
        emitter.particleSpeedRange = 1000 * intensity
        emitter.particleAlpha = 1.0
        emitter.particleAlphaRange = 0.25
        emitter.particleScale = 1.2
        emitter.particleScaleRange = 2.0
        emitter.particleScaleSpeed = -1.5
        
        emitter.particleColorBlendFactor = 1
        emitter.particleBlendMode = SKBlendMode.add
        emitter.run(SKAction.removeFromParentAfterDelay(2.0))
        
        let sequence = SKKeyframeSequence(capacity: 5)
        sequence.addKeyframeValue(SKColor.white, time: 0)
        sequence.addKeyframeValue(SKColor.yellow, time: 0.10)
        sequence.addKeyframeValue(SKColor.orange, time: 0.15)
        sequence.addKeyframeValue(SKColor.red, time: 0.75)
        sequence.addKeyframeValue(SKColor.black, time: 0.95)
        emitter.particleColorSequence = sequence
        
        return emitter
    }
    
    fileprivate func explosion(at point: CGPoint) {
        let explode = explosion(intensity: 0.25 * CGFloat(4 + 1))
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
        
        updateLightPosition()
    }
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
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
        
        if collision == PhysicsCategory.Arrow | PhysicsCategory.BreakableFormation {
            if let arrow = currentProjectile {
                explosion(at: arrow.position)
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
    
    func didEnd(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if collision == PhysicsCategory.Wizard | PhysicsCategory.Ground {
            wizardNode.isGrounded = false
        }
    }
}
