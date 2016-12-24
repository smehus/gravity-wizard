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
}

struct PhysicsCategory {
    static let None:  UInt32 = 0
    static let Wizard: UInt32 = 0b1 // 1
    static let Ground: UInt32 = 0b10 // 2
    static let World:   UInt32 = 0b100 // 4
    static let Edge:  UInt32 = 0b1000 // 8
    static let Label: UInt32 = 0b10000 // 16
    static let Blood :UInt32 = 0b100000 // 32
    static let RadialGravity:  UInt32 = 0b1000000 // 64
}

class GameScene: SKScene, LifecycleEmitter {

    /// Scense
    var wizardScene: SKScene!
    
    /// Nodes
    var wizardNode: WizardNode!
    var bloodNode: BloodNode?
    var radialMarker: SKSpriteNode?
    
    // Effects
    var radialGravity: SKFieldNode?
    
    
    /// Constants
    let bloodExplosionCount = 5
    
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        setupNodes()
    }
    
    fileprivate func setupNodes() {
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        emitDidMoveToView()

        wizardScene = SKScene(fileNamed: "Wizard")
        wizardNode = childNode(withName: "//Wizard") as! WizardNode
        if let node = BloodNode.generateBloodNode() {
            bloodNode = node
        }
        
    }
}

extension GameScene {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        if let _ = radialGravity {
            removeRadialGravity()
        } else {
            radialGravity = createRadialGravity(at: touchLocation)
            
        }
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
            
            let vector = CGVector(dx: Int.random(min: -2, max: 2), dy: 8)
            dup.physicsBody?.applyImpulse(vector)
        }
        
        let wait = SKAction.wait(forDuration: 0.0)
        run(SKAction.repeat(SKAction.sequence([bleedAction, wait]), count: bloodExplosionCount))
    }
}

extension GameScene {
    override func update(_ currentTime: TimeInterval) {
        
    }
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if collision == PhysicsCategory.Ground | PhysicsCategory.Wizard, !wizardNode.isGrounded {
            wizardNode.isGrounded = true
            createBloodExplosion(with: wizardNode)
        }
        
        if collision == PhysicsCategory.Blood | PhysicsCategory.Ground {
            let node = contact.bodyA.categoryBitMask == PhysicsCategory.Blood ? contact.bodyA.node : contact.bodyB.node
            
            if let blood = node as? BloodNode {
                blood.hitGround()
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
