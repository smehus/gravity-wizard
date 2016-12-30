//
//  Level1.swift
//  GravityWizard2
//
//  Created by scott mehus on 12/30/16.
//  Copyright © 2016 scott mehus. All rights reserved.
//

import SpriteKit
import GameplayKit

class Level1: GameScene {
    
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
}

extension Level1 {
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
}

extension Level1 {
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

extension Level1: SKPhysicsContactDelegate {
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
