//
//  RoseNode.swift
//  GravityWizard2
//
//  Created by scott mehus on 1/15/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit

class RoseNode: SKSpriteNode, GravityStateTracker {

    var isGrounded = true
    var previousVelocity: CGVector?
    
    var gravityState: GravityState = .ground {
        didSet {
            guard gravityState != oldValue else { return }
            animate(with: gravityState)
        }
    }
    
    func face(towards direction: Direction) {
        switch direction {
        case .left:
            xScale = -1.0
        case .right:
            xScale = 1.0
        default: break
        }
    }
    
    func jump(towards point: CGPoint) {
        
        var xValue = 0
        if point.x > position.x {
            xValue = 50
        } else {
            xValue = -50
        }
        let jumpVector = CGVector(dx: xValue, dy: 1200)
        physicsBody!.applyImpulse(jumpVector)
    }
    
    fileprivate func animate(with state: GravityState) {
        switch state {
        case .falling:
            runFallingAnimation()
        case .ground:
            runIdleAnimation()
        case .pull:
            runPullAnimation()
        default: return
        }
    }
    
    fileprivate func runFallingAnimation() {
        removeAction(forKey: gravityState.animationKey)
        let textureImage = SKTexture(imageNamed: Images.roseIdle)
        let textures = [textureImage]
        
        let pullAnimation = SKAction.animate(with: textures, timePerFrame: 0.1)
        run(pullAnimation, withKey: gravityState.animationKey)
    }
    
    fileprivate func runIdleAnimation() {
        removeAction(forKey: gravityState.animationKey)
        let textureImage = SKTexture(imageNamed: Images.roseIdle)
        let textures = [textureImage]
        
        let pullAnimation = SKAction.animate(with: textures, timePerFrame: 0.1)
        run(pullAnimation, withKey: gravityState.animationKey)

    }
    
    fileprivate func runPullAnimation() {
        removeAction(forKey: gravityState.animationKey)
        let textureImage = SKTexture(imageNamed: Images.rosePulled)
        let textures = [textureImage]

        let pullAnimation = SKAction.animate(with: textures, timePerFrame: 0.1)
        run(pullAnimation, withKey: gravityState.animationKey)
    }

    fileprivate func calculateState(withDelta deltaTime: Double) {
        guard let body = physicsBody else { return }
        if body.velocity.dy < -20 {
            gravityState = .falling
        } else if body.velocity.dy > 50 || body.velocity.dx > 20 || body.velocity.dx < -20 {
            
            
            if body.velocity.dx > 0 {
                face(towards: .right)
                let angle = body.velocity.angle
                let action = SKAction.rotate(toAngle: angle, duration: 0.2, shortestUnitArc: true)
                run(action)
            } else if body.velocity.dx < 0 {
                face(towards: .left)
                let df = body.velocity.angle.radiansToDegrees() + 180
                let angle = df.degreesToRadians()
                let action = SKAction.rotate(toAngle: angle, duration: 0.2, shortestUnitArc: true)
                run(action)
            }
            
            gravityState = .pull
        } else {
            gravityState = .ground
            zRotation = 0
        }
    }
}

extension RoseNode: GameLoopListener {
    func update(withDelta deltaTime: Double) {
        guard let body = physicsBody else { return }
        guard previousVelocity != body.velocity else { return }
        previousVelocity = body.velocity
        calculateState(withDelta: deltaTime)
    }
}

extension RoseNode: LifecycleListener {
    func didMoveToScene() {
        xScale = 1.0
        let newSize = texture!.size()
        physicsBody = SKPhysicsBody(rectangleOf: newSize)
        physicsBody?.allowsRotation = false
        physicsBody?.categoryBitMask = PhysicsCategory.Hero
        physicsBody?.contactTestBitMask = PhysicsCategory.Ground | PhysicsCategory.Rock | PhysicsCategory.GravityProjectile
        physicsBody?.collisionBitMask = PhysicsCategory.Ground | PhysicsCategory.Rock | PhysicsCategory.Edge
        physicsBody?.fieldBitMask = PhysicsCategory.RadialGravity
        
    }
}
