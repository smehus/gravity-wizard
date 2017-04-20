//
//  RoseNode.swift
//  GravityWizard2
//
//  Created by scott mehus on 1/15/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit

fileprivate struct Definitions {
    struct Physics {
        struct ContactTest {
            static let full = PhysicsCategory.Ground | PhysicsCategory.Rock | PhysicsCategory.GravityProjectile | PhysicsCategory.LevelComplete
            static let noGround = PhysicsCategory.Rock | PhysicsCategory.GravityProjectile
        }
        
        static let collision = PhysicsCategory.Ground | PhysicsCategory.Rock | PhysicsCategory.Edge | PhysicsCategory.destructible
    }

    struct ActionKeys {
        static let idleAction = "IdleAction"
        static let walkAction = "WalkAction"
        static let pullAction = "PullAction"
        static let fallAction = "FallAction"
        static let hardLandAction = "HardLandAction"
    }
}

fileprivate enum Texture {
    case hardLand
    case pull
    case idle
    case falling
    case walk
    
    var animationKey: String {
        switch self {
        case .hardLand: return Definitions.ActionKeys.hardLandAction
        case .pull: return Definitions.ActionKeys.pullAction
        case .idle: return Definitions.ActionKeys.idleAction
        case .falling: return Definitions.ActionKeys.fallAction
        case .walk: return Definitions.ActionKeys.walkAction
        }
    }
    
    func texture() -> [SKTexture] {
        switch self {
        case .hardLand:
            return [SKTexture(image: #imageLiteral(resourceName: "alienPink_duck"))]
        case .pull:
            return [SKTexture(image: #imageLiteral(resourceName: "alienPink_swim2"))]
        case .idle:
            return [SKTexture(image: #imageLiteral(resourceName: "alienPink_stand"))]
        case .falling:
            return [SKTexture(image: #imageLiteral(resourceName: "alienPink_jump"))]
        case .walk:
            var textures = [SKTexture]()
//            for i in 1...11 {
//                textures.append(SKTexture(imageNamed: "p3_walk\(i)"))
//            }
//
            textures.append(SKTexture(image: #imageLiteral(resourceName: "alienPink_walk1")))
            textures.append(SKTexture(image: #imageLiteral(resourceName: "alienPink_walk2")))
            return textures
        }
    }
}

final class RoseNode: SKSpriteNode, GravityStateTracker {
    
    struct Constants {
        static let MAX_JUMP_COUNT = 2
    }
    
    var isGrounded = true
    var jumpCount = 0
    var previousVelocity: CGVector?
    var startingPosition: CGPoint?
    
    fileprivate var lastAssignedTexture: Texture?
    
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
    
    func jump(towards vector: CGVector) {
        guard jumpCount <= Constants.MAX_JUMP_COUNT else { return }
        jumpCount += 1
        physicsBody?.velocity = vector
    }
    
    func hardLanding() {
        guard gravityState == .falling else { return }
        isGrounded = true
        jumpCount = 0
        gravityState = .landing
        physicsBody?.velocity = CGVector.zero
        
        let landAction = SKAction.animate(with: animationTextures(for: .hardLand), timePerFrame: 0.2)
        let wait = SKAction.afterDelay(0.5, runBlock: runIdleAnimation)
        run(SKAction.sequence([landAction, wait]))
    }
    
    func walk(towards direction: Direction) {
        face(towards: direction)
        let walkAction = SKAction.repeatForever(SKAction.moveBy(x: direction.walkingXVector, y: 0, duration: 0.1))
        run(SKAction.group([walkAction,  walkingAnimation()]), withKey: Definitions.ActionKeys.walkAction)
    }
    
    func stop() {
        removeAction(forKey: Definitions.ActionKeys.walkAction)
        
    }
    
    fileprivate func animate(with state: GravityState) {
        guard gravityState != .landing else { return }
        switch state {
        case .falling:
            runFallingAnimation()
        case .pull:
            runPullAnimation()
        default: return
        }
    }
    
    fileprivate func animationTextures(for texture: Texture) -> [SKTexture] {
        if let lastTexture = lastAssignedTexture {
            removeAction(forKey: lastTexture.animationKey)
        }
        
        lastAssignedTexture = texture
        return texture.texture()
    }
    
    fileprivate func walkingAnimation() -> SKAction {
        return SKAction.repeatForever(SKAction.animate(with: animationTextures(for: .walk), timePerFrame: 0.3, resize: false, restore: true))
    }
    
    fileprivate func runFallingAnimation() {
        let pullAnimation = SKAction.animate(with: animationTextures(for: .falling), timePerFrame: 0.1)
        let rotateAction = SKAction.rotate(toAngle: 0, duration: 0.2, shortestUnitArc: true)
        run(SKAction.group([pullAnimation, rotateAction]), withKey: Texture.falling.animationKey)
    }
    
    fileprivate func runIdleAnimation() {
        let pullAnimation = SKAction.animate(with: animationTextures(for: .idle), timePerFrame: 0.1)
        run(pullAnimation, withKey: Texture.idle.animationKey)

    }
    
    fileprivate func runPullAnimation() {
        let pullAnimation = SKAction.animate(with: animationTextures(for: .pull), timePerFrame: 0.1)
        run(pullAnimation, withKey: Texture.pull.animationKey)
    }

    fileprivate func calculateState(withDelta deltaTime: Double) {
        guard let body = physicsBody else { return }
        if body.velocity.dy < -20 {
            gravityState = .falling
        } else if body.velocity.dy > 50 || body.velocity.dx > 50 || body.velocity.dx < -50 {
            
            
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
            if let lastTexture = lastAssignedTexture {
                if case .pull = lastTexture {
                    removeAction(forKey: lastTexture.animationKey)
                    runIdleAnimation()
                }
            }
            
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
        setPhysicsBody()
    }
}

extension RoseNode {
    fileprivate func setPhysicsBody() {
        guard let text = texture else {
            assertionFailure()
            return
        }
        
        physicsBody = SKPhysicsBody(texture: text, size: text.size())
        physicsBody?.allowsRotation = false
        physicsBody?.categoryBitMask = PhysicsCategory.Hero
        physicsBody?.contactTestBitMask = Definitions.Physics.ContactTest.full
        physicsBody?.collisionBitMask = Definitions.Physics.collision
        physicsBody?.fieldBitMask = PhysicsCategory.RadialGravity
        physicsBody?.restitution = 0.0
        physicsBody?.friction = 1.0
    }
}
