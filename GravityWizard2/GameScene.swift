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
    static let Spring:UInt32 = 0b100000 // 32
    static let RadialGravity:  UInt32 = 0b1000000 // 64
}

class GameScene: SKScene, LifecycleEmitter {

    /// Nodes
    var worldNode: SKNode!
    var wizardNode: WizardNode!
    var radialGravity: SKFieldNode?
    var radialMarker: SKSpriteNode?
     
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        setupNodes()
    }
    
    fileprivate func setupNodes() {
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        emitDidMoveToView()
        wizardNode = childNode(withName: "//Wizard") as! WizardNode
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
    
    func removeRadialGravity() {
        guard let field = radialGravity, let marker = radialMarker else { return }
        self.removeChildren(in: [field, marker])
        radialGravity = nil
        radialMarker = nil
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
}

extension GameScene {
    override func update(_ currentTime: TimeInterval) {
        
    }
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        
    }
}
