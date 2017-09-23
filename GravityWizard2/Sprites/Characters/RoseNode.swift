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
            static let full = PhysicsCategory.Ground | PhysicsCategory.Rock | PhysicsCategory.GravityProjectile | PhysicsCategory.LevelComplete | PhysicsCategory.enemy | PhysicsCategory.water | PhysicsCategory.Lava | PhysicsCategory.movable | PhysicsCategory.explodingBlock
            
            static let immune = PhysicsCategory.Ground | PhysicsCategory.Rock | PhysicsCategory.GravityProjectile | PhysicsCategory.LevelComplete | PhysicsCategory.water
        }
        
        static let collision = PhysicsCategory.Ground | PhysicsCategory.Rock | PhysicsCategory.Edge | PhysicsCategory.destructible | PhysicsCategory.enemy | PhysicsCategory.indesctructibleObstacle | PhysicsCategory.border | PhysicsCategory.movable
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
            textures.append(SKTexture(image: #imageLiteral(resourceName: "alienPink_walk1")))
            textures.append(SKTexture(image: #imageLiteral(resourceName: "alienPink_walk2")))
            return textures
        }
    }
}

enum Health: Int {
    case full
    case threeQuarters
    case half
    case quarter
    case dead
    
    mutating func lowerHealth() {
        let nextInt = rawValue + 1
        guard let health = Health(rawValue: nextInt) else {
            self = .dead
            return
        }
        
        self = health
    }
    
    func texture() -> SKTexture {
        return SKTexture()
    }
}

fileprivate struct GroundJoint {
    var isActive = false
    var joint: SKPhysicsJoint? {
        didSet {
            if let _ = joint {
                isActive = true
            } else {
                isActive = false
            }
        }
    }
}

enum JumpRestorationType {
    case groundRestore
    case actionRestore
}

@objcMembers final class RoseNode: SKSpriteNode, GravityStateTracker {
    
    struct Constants {
        static let MAX_JUMP_COUNT = 100
    }
    
    var jumpRestorationType: JumpRestorationType = .groundRestore
    var isGrounded = true
    dynamic var jumpCount = Constants.MAX_JUMP_COUNT
    var previousVelocity: CGVector?
    var startingPosition: CGPoint?
    var currentHealth: Health = .full {
        didSet {
            
        }
    }
    
    fileprivate var lastAssignedTexture: Texture?
    fileprivate var groundJoint = GroundJoint()
    
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
        
        if let joint = groundJoint.joint, let gameScene = scene as? GameScene {
            gameScene.physicsWorld.remove(joint)
            groundJoint.joint = nil
        }
        
        guard jumpCount != 0 else { return }
        jumpCount -= 1
        physicsBody?.velocity = vector
        
        if let gameScene = scene as? GameScene {
//            let jumpParticle = ParticleFactory.sharedFactory.jumpSmoke()
//            jumpParticle.targetNode = gameScene
//            jumpParticle.position = gameScene.convert(position, from: parent!)
//            jumpParticle.advanceSimulationTime(1)
//            jumpParticle.run(SKAction.removeFromParentAfterDelay(2.0))
//            gameScene.addChild(jumpParticle)
            
            for _ in 0..<3 {
                
                let smokeTexture = SKTexture(image: #imageLiteral(resourceName: "whitePuff0"))
                let smokeSprite = SKSpriteNode(texture: smokeTexture, color: .white, size: smokeTexture.size() * 0.1)
                let smokePOS = gameScene.convert(position, from: parent!)
                let variance: CGFloat = 30
                smokeSprite.position = CGPoint(x: CGFloat.random(min: smokePOS.x - variance, max: smokePOS.x + variance), y: CGFloat.random(min: smokePOS.y - variance, max: smokePOS.y + variance))
                
                smokeSprite.zPosition = 10
                
                gameScene.addChild(smokeSprite)
                
                let textures = createSmokeTextures()
                let timePerFrame = Double(CGFloat.random(min: 0.01, max: 0.03))
                let textAnim = SKAction.animate(with: textures, timePerFrame: timePerFrame)
                let removeAction = SKAction.removeFromParentAfterDelay(timePerFrame * Double(textures.count))
                let alphaAction = SKAction.fadeAlpha(to: 0.0, duration: timePerFrame * Double(textures.count))
                let sizeAction = SKAction.scale(by: 4, duration: timePerFrame * Double(textures.count))
                smokeSprite.run(SKAction.group([textAnim, removeAction, alphaAction, sizeAction]))
            }
        }
    }
    
    private func createSmokeTextures() -> [SKTexture] {
        var animationTextures: [SKTexture] = []
        
        for i in 0...24 {
            let name = "whitePuff\(i)"
            let text = SKTexture(imageNamed: name)
            animationTextures.append(text)
        }
        
        return animationTextures
    }
    
    func hardLanding(with body: SKPhysicsBody, contactPoint: CGPoint, addJoint: Bool) {
        guard
            gravityState == .falling
        else { return }
        
        isGrounded = true
        if jumpRestorationType == .groundRestore {
            jumpCount = Constants.MAX_JUMP_COUNT
        }
        
        gravityState = .landing
        physicsBody?.velocity = CGVector.zero
        
        if
            addJoint,
            let gameScene = scene as? GameScene,
            let roseBody = physicsBody
        {
            let joint = SKPhysicsJointPin.joint(withBodyA: roseBody, bodyB: body, anchor: contactPoint)
            groundJoint.joint = joint
            gameScene.add(joint: joint)
        }
        
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
    
    func attacked() {
        guard currentHealth != .dead else {
            return
        }
        
        physicsBody?.contactTestBitMask = Definitions.Physics.ContactTest.immune
        
        currentHealth.lowerHealth()
        switch currentHealth {
        case .dead:
            die()
        case .full, .threeQuarters, .half, .quarter:
            runAttackedAnimation()
        }
    }
    
    func runLavaDeathAnimation() {
        guard let body = physicsBody, body.contactTestBitMask != PhysicsCategory.None else { return }
        body.velocity = CGVector(dx: 0, dy: 0)
        physicsBody?.applyImpulse(CGVector(dx: 0, dy: 300))
        physicsBody?.contactTestBitMask = PhysicsCategory.None
        physicsBody?.collisionBitMask = PhysicsCategory.None
    }
    
    func drown() {
        physicsBody?.contactTestBitMask = Definitions.Physics.ContactTest.immune
        physicsBody?.affectedByGravity = false
        physicsBody?.velocity = CGVector(dx: 0, dy: -30.0)
        physicsBody?.friction = 1.0
        physicsBody?.linearDamping = 1.0
    }
    
    fileprivate func runAttackedAnimation() {
        let colorize = SKAction.colorize(with: .white, colorBlendFactor: 1.0, duration: 0.3)
        let flash = SKAction.sequence([colorize, colorize.reversed()])
        let flashAnimation = SKAction.repeat(flash, count: 5)
        run(flashAnimation) { 
            self.physicsBody?.contactTestBitMask = Definitions.Physics.ContactTest.full
        }
    }
    
    fileprivate func die() {
        guard let gameScene = scene as? GameScene else {
            assertionFailure("Failed to retrieve game scene on rose death")
            return
        }
        
        gameScene.gameOver()
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
        physicsBody?.fieldBitMask = PhysicsCategory.heroField
        physicsBody?.restitution = 0.0
        physicsBody?.friction = 1.0
    }
}
