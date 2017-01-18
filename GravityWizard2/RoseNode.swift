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
            xScale = -abs(xScale)
        case .right:
            xScale = abs(xScale)
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
        } else if body.velocity.dy > 30 || body.velocity.dx > 20 || body.velocity.dx < -20 {
            updateDirection(withDelta: deltaTime)
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
//        texture?.filteringMode = .nearest
        let newSize = texture!.size()
        physicsBody = SKPhysicsBody(rectangleOf: newSize)
        physicsBody?.allowsRotation = false
        physicsBody?.categoryBitMask = PhysicsCategory.Hero
        physicsBody?.contactTestBitMask = PhysicsCategory.Ground | PhysicsCategory.Rock | PhysicsCategory.GravityProjectile
        physicsBody?.collisionBitMask = PhysicsCategory.Ground | PhysicsCategory.Rock | PhysicsCategory.Edge
        physicsBody?.fieldBitMask = PhysicsCategory.RadialGravity
        
    }
}
