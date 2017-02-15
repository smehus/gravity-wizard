//
//  GameScene.swift
//  GravityWizard2
//
//  Created by scott mehus on 12/20/16.
//  Copyright © 2016 scott mehus. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, Game, LifecycleEmitter, GameLevel {

    /// Scense
    var roseScene: SKScene!
    
    /// Nodes
    var rose: RoseNode?
    var bloodNode: BloodNode?
    var radialMarker: SKSpriteNode?
    var breakableRocks: BreakableRocksNode?
    
    var light: SKNode?
    
    // Effects
    var radialGravity: SKFieldNode?
    
    
    /// Constants
    let bloodExplosionCount = 5
    
    let cameraNode = SKCameraNode()
    
    
    /// Trackables
    var lastUpdateTimeInterval: TimeInterval = 0
    var deltaTime: TimeInterval = 0
    var trackingProjectileVelocity = false
    var projectileVelocity: CGFloat = 0
    var currentProjectile: SKNode?
    var currentActionType: ActionType = .gravity
    
    /// Statics
    var particleFactory = ParticleFactory.sharedFactory
    
    /// Touches
    var initialTouchPoint: CGPoint?
    
    var trajectoryNode: SKShapeNode?
    
    var cameraSize: CGSize? {
        guard let camera = camera else { return nil }
        let xValue = size.width * camera.xScale
        let yValue = size.height * camera.yScale
        return CGSize(width: xValue, height: yValue)
    }
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        setupNodes()
        setupCamera()
        setupHeroContactBorder()
        setupHUDElements()
    }
    
    func setupNodes() {
        
        addChild(cameraNode)
        camera = cameraNode
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsBody?.categoryBitMask = PhysicsCategory.Edge
        emitDidMoveToView()
        
        roseScene = SKScene(fileNamed: "Rose")
        rose = childNode(withName: "//rose") as? RoseNode
        setHeroStartingPosition()
        breakableRocks = childNode(withName: "//BreakableRocks") as? BreakableRocksNode
        light = childNode(withName: "FollowLight")
        
        if let node = BloodNode.generateBloodNode() {
            bloodNode = node
        }
    }
    
    fileprivate func setHeroStartingPosition() {
        guard let rose = rose else { return }
        rose.startingPosition = rose.position
    }
    
    fileprivate func setupCamera() {
        
        guard let camera = camera, let rose = rose else { return }
        camera.xScale = 0.5
        camera.yScale = 0.5
        let playerConstraint = SKConstraint.distance(SKRange(constantValue: 0), to: rose)
        
        
        let xInset = frame.size.width/2 * camera.xScale
        let yInset = frame.size.height/2 * camera.yScale
        
        let constraintRect = frame.insetBy(dx: xInset, dy: yInset)
        
        let xRange = SKRange(lowerLimit: constraintRect.minX, upperLimit: constraintRect.maxX)
        let yRange = SKRange(lowerLimit: constraintRect.minY, upperLimit: constraintRect.maxY)
        
        let edgeConstraint = SKConstraint.positionX(xRange, y: yRange)
        edgeConstraint.referenceNode = self
        
        camera.constraints = [playerConstraint, edgeConstraint]
    }
    
    fileprivate func setupHeroContactBorder() {
        guard let rose = rose else { assertionFailure("SETUP HERO CONTACT BORDER - MISSING ROSE"); return }
        let borderNode = SKSpriteNode(color: .clear, size: CGSize(width: rose.size.height / 2, height: rose.size.height / 2))
        let borderBody = SKPhysicsBody(circleOfRadius: borderNode.size.height / 2)
    
        let constraint = SKConstraint.distance(SKRange(constantValue: 0), to: rose)
        borderNode.constraints = [constraint]
        borderBody.categoryBitMask = PhysicsCategory.HeroContactBorder
        borderBody.affectedByGravity = false
        borderBody.contactTestBitMask = PhysicsCategory.GravityProjectile
        borderBody.collisionBitMask = PhysicsCategory.None
        borderBody.fieldBitMask = PhysicsCategory.None
        borderNode.physicsBody = borderBody
        addChild(borderNode)
    }
    
    fileprivate func setupHUDElements() {
        setupWeaponSelector()
        setupRewindButton()
    }
    
    fileprivate func setupWeaponSelector() {
        guard let camera = camera, let selector = WeaponSelector.generateWeaponSelector() else { return }
        let calculatedHeight = size.height / 2
//        calculatedHeight -= selector.halfHeight
        let calculatedWidth = size.width / 2
//        calculatedWidth -= selector.halfWidth
        let startingCorner = CGPoint(x: -calculatedWidth, y: calculatedHeight)
        
        selector.position = convert(startingCorner, from: camera)
        selector.move(toParent: camera)
        
    }
    
    fileprivate func setupRewindButton() {
        guard let camera = camera, let camSize = cameraSize else { return }
        
        let rewind = RewindSelector()
        let xValue = (camSize.width / 2) - rewind.calculatedSize.width/2
        let yValue = (camSize.height / 2) - rewind.calculatedSize.height/2
        let newPoint = CGPoint(x: xValue, y: yValue)
        rewind.position = convert(newPoint, to: camera)
        print("\(rewind.calculatedSize)")
        camera.addChild(rewind)
    }
    
    func createBloodExplosion(with sprite: SKSpriteNode) {
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
    
    func createRadialGravity(at point: CGPoint) -> SKFieldNode {
        let field = SKFieldNode.radialGravityField()
        field.position = point
        field.strength = 30
        field.falloff = 0
        field.categoryBitMask = PhysicsCategory.RadialGravity
        field.minimumRadius = 2
        field.isEnabled = false
        
        
        let marker = SKSpriteNode(imageNamed: Images.spark)
        marker.position = point
        radialMarker = marker
        
        
        addChildren(children: [field, marker])
        return field
    }
    
    func createArrow(at position: CGPoint) -> ArrowNode {
        let arrow = ArrowNode()
        arrow.position = position
        return arrow
    }
    
    func createGravityProjectile(at point: CGPoint) -> GravityProjectile? {
        guard let node = GravityProjectile.generateGravityProjectile() else { return nil }
        node.position = point
        return node
    }
    
    func removeRadialGravity() {
        guard let field = radialGravity, let marker = radialMarker else { return }
        self.removeChildren(in: [field, marker])
        radialGravity = nil
        radialMarker = nil
    }
    
    // Point is the touches ended point
    func launchProjectile(at initialPoint: CGPoint, endPoint: CGPoint, velocity: CGFloat, and type: ActionType) {
        switch type {
        case .arrow:
            launchNormalizedArrowProjectile(with: initialPoint, endPoint: endPoint, velocityMultiply: velocity)
        case .gravity:
            launchNormalizedGravityProjectile(with: initialPoint, endPoint: endPoint, velocityMultiply: velocity)
        default: return
        }
    }
}

extension GameScene {
    fileprivate func updateTrajectoryIndicator(with initialPoint: CGPoint, endPoint: CGPoint, velocityMultiply: CGFloat) {
        guard let rose = rose else { return }
        let startingPosition = convert(rose.position, from: rose.parent!)
        let newPoint = initialPoint - endPoint
        let newVelocity = newPoint.normalized() * velocityMultiply/3
        let endPathPoint = startingPosition + newVelocity
        
        let arcPath = CGMutablePath()
        arcPath.move(to: startingPosition)
        
        let length = newPoint.length()
        arcPath.addCurve(to: startingPosition + newVelocity, control1: startingPosition + length/4, control2: endPathPoint + length/4)
        
        if let _ = trajectoryNode {
            trajectoryNode?.removeFromParent()
        }
        
        let newTrajectory = SKShapeNode(path: arcPath)
        addChild(newTrajectory)
        trajectoryNode = newTrajectory
        
    }
}

// MARK: - Launches projectiles relative to touch down point and touches end point. Calculate velocity based on those two points and then applied to projectile with new starting position.
extension GameScene {
    fileprivate func launchNormalizedGravityProjectile(with initialPoint: CGPoint, endPoint: CGPoint, velocityMultiply: CGFloat) {
        guard let rose = rose else { return }
        let startingPosition = convert(rose.position, from: rose.parent!)
        
        guard let projectile = createGravityProjectile(at: startingPosition) else { return }
        projectile.move(toParent: self)
        
        var newPoint = initialPoint - endPoint
        let newVelocity = newPoint.offset(dx: 0, dy: newPoint.y * 1.5).normalized() * velocityMultiply
        projectile.launch(at: CGVector(point: newVelocity))
        
        currentProjectile = projectile
    }
    
    fileprivate func launchNormalizedArrowProjectile(with initialPoint: CGPoint, endPoint: CGPoint, velocityMultiply: CGFloat) {
        guard let rose = rose else { return }
        let startingPosition = convert(rose.position, from: rose.parent!)
        
        let arrow = createArrow(at: startingPosition)
        addChild(arrow)
        
        /// reversed point diff
        let newPoint = initialPoint - endPoint
        let newVelocity = newPoint.normalized() * velocityMultiply
        arrow.launch(at: CGVector(point: newVelocity))
        
        currentProjectile = arrow
    }
}


// MARK: - Launches projectiles like angry birds
extension GameScene {
    /// Used for Arrow launching like angry birds
    func launchGravityProjectile(at point: CGPoint, velocityMultiply: CGFloat) {
        guard let rose = rose else { return }
        let startingPosition = convert(rose.position, from: rose.parent!)
        
        guard let projectile = createGravityProjectile(at: startingPosition) else { return }
        projectile.move(toParent: self)
        
        /// reversed point diff
        let newPoint = startingPosition - point
        let newVelocity = newPoint.normalized() * velocityMultiply
        projectile.launch(at: CGVector(point: newVelocity))
        
        
        
        currentProjectile = projectile
    }
    
    
    /// Used for Arrow launching like angry birds
    func launchArrow(at point: CGPoint, velocityMultiply: CGFloat) {
        guard let rose = rose else { return }
        let startingPosition = convert(rose.position, from: rose.parent!)
        
        let arrow = createArrow(at: startingPosition)
        addChild(arrow)
        
        /// reversed point diff
        let newPoint = startingPosition - point
        let newVelocity = newPoint.normalized() * velocityMultiply
        arrow.launch(at: CGVector(point: newVelocity))
        
        currentProjectile = arrow
    }
}


// MARK: - Sets velocity based on initial touch
extension GameScene {
    /// Used for shooting enemies like a gun
    func shootArrow(at point: CGPoint, velocityMultiply: CGFloat) {
        guard let rose = rose else { return }
        let startingPosition = convert(rose.position, from: rose.parent!)
        
        let arrow = createArrow(at: startingPosition)
        addChild(arrow)
        
        let newVelocity =  (point - startingPosition).normalized() * velocityMultiply
        arrow.physicsBody!.velocity = CGVector(point: newVelocity)
        
        currentProjectile = arrow
    }
    
}

extension GameScene {
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTimeInterval > 0 {
            deltaTime = currentTime - lastUpdateTimeInterval
        } else {
            deltaTime = 0
        }
        
        lastUpdateTimeInterval = currentTime
        
        if let rose = rose {
            rose.update(withDelta: deltaTime)
        }
        
        if let projectile = currentProjectile {
            updateDirection(with: projectile)
        }
    }
}

extension GameScene {
    fileprivate func prepareProjectile(withTouch touchPoint: CGPoint) {
        if let projectile = currentProjectile as? GravityProjectile {
            if projectile.isInFlight {
                projectile.createGravityField()
            } else {
                projectile.removeFromParent()
                currentProjectile = nil
            }
            
        } else if trackingProjectileVelocity == false {
            trackingProjectileVelocity = true
            initialTouchPoint = touchPoint
        }
    }
    
    fileprivate func updateProjectile(withTouch touchPoint: CGPoint) {
        if let initial = initialTouchPoint, trackingProjectileVelocity {
            let diff = initial - touchPoint
            let vel = diff.length() * 2
            projectileVelocity = vel
            updateTrajectoryIndicator(with: initial, endPoint: touchPoint, velocityMultiply: vel)
        }
        
        
        if let wizard = rose, let initial = initialTouchPoint {
            wizard.face(towards: direction(forStartingPoint: initial, currentPoint: touchPoint))
        }
    }
    
    fileprivate func executeProjectile(withTouch touchPoint: CGPoint) {
        trajectoryNode?.removeFromParent()
        if trackingProjectileVelocity {
            guard let initial = initialTouchPoint else { return }
            launchProjectile(at: initial, endPoint: touchPoint, velocity: projectileVelocity, and: currentActionType)
            trackingProjectileVelocity = false
            projectileVelocity = 0
        }
    }
}

extension GameScene {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else { return }
        let touchPoint = touch.location(in: self)
        
        switch currentActionType {
        case .arrow, .gravity:
            prepareProjectile(withTouch: touchPoint)
        case .walk:
            guard let rose = rose else { return }
            rose.walk(towards: direction(for: touchPoint, with: rose))
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let touch = touches.first else { return }
        let touchPoint = touch.location(in: self)
        
        switch currentActionType {
        case .arrow, .gravity:
            updateProjectile(withTouch: touchPoint)
        case .walk: break
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard let touch = touches.first else { return }
        let touchPoint = touch.location(in: self)
        
        switch currentActionType {
        case .gravity, .arrow:
            executeProjectile(withTouch: touchPoint)
        case .walk:
            guard let rose = rose else { return }
            rose.stop()
        }
    }
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if collision.collisionCombination() == .heroHitsGround {
            roseHitsGround(with: contact)
        }
        
        if collision.collisionCombination() == .rockHitsWizard {
            rockHitsWizard(with: contact)
        }
        
        if collision.collisionCombination() == .heroCollidesWithGravityField {
            wizardCollidesWithGravityField(with: contact)
        }
        
        if collision.collisionCombination() == .bloodCollidesWithGround {
            bloodCollidesWithGround(with: contact)
        }
        
        if collision.collisionCombination() == .arrowCollidesWithEdge {
            arrowCollidesWithEdge(with: contact)
        }
        
        if collision.collisionCombination() == .arrowCollidesWithBreakable {
            arrowCollidesWithBreakable(with: contact)
        }
        
        if collision.collisionCombination() == .arrowCollidesWithGround {
            arrowCollidesWithGround(with: contact)
        }
        
        if collision.collisionCombination() == .arrowCollidesWithVikingBodyPart {
            arrowCollidesWithVikingBodyPart(with: contact)
        }
        
        if collision.collisionCombination() == .gravityProjectileHitsGround {
            gravityProjectileHitGround(with: contact)
        }
        
        if collision.collisionCombination() == .heroCollidesWithLevelComplete {
            wizardCollidesWithChest(with: contact)
        }
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        WizardGround: if collision == PhysicsCategory.Hero | PhysicsCategory.Ground {
            guard let rose = rose else { break WizardGround }
            rose.isGrounded = false
        }
    }
}

// MARK: - Collisions
extension GameScene {
    
    fileprivate func wizardCollidesWithGravityField(with contact: SKPhysicsContact) {
        let gravity = contact.bodyA.categoryBitMask == PhysicsCategory.GravityProjectile ? contact.bodyA.node : contact.bodyB.node
        guard let field = gravity as? GravityProjectile, field.shouldCollideWithLauncher else { return }
        
        field.removeFromParent()
        currentProjectile = nil
    }
    
    fileprivate func roseHitsGround(with contact: SKPhysicsContact) {
        guard let rose = rose, rose.gravityState == .falling else { return }
        rose.hardLanding()
    }
    
    fileprivate func rockHitsWizard(with contact: SKPhysicsContact) {
        guard let rose = rose else { return }
        createBloodExplosion(with: rose)
    }
    
    fileprivate func bloodCollidesWithGround(with contact: SKPhysicsContact) {
        let node = contact.bodyA.categoryBitMask == PhysicsCategory.Blood ? contact.bodyA.node : contact.bodyB.node
        
        if let blood = node as? BloodNode {
            blood.hitGround()
        }
    }
    
    fileprivate func arrowCollidesWithEdge(with contact: SKPhysicsContact) {
        if let arrow = currentProjectile {
            arrow.removeFromParent()
        }
    }
    
    fileprivate func arrowCollidesWithBreakable(with contact: SKPhysicsContact) {
        if let arrow = currentProjectile {
            explosion(at: arrow.position)
            guard let breakableRocks = breakableRocks else { return }
            breakableRocks.breakRocks()
            arrow.removeFromParent()
        }
    }
    
    fileprivate func arrowCollidesWithGround(with contact: SKPhysicsContact) {
        if let arrow = currentProjectile as? ArrowNode {
            arrow.physicsBody = nil
        }
    }
    
    fileprivate func arrowCollidesWithVikingBodyPart(with contact: SKPhysicsContact) {
        let bodyPart = contact.bodyA.categoryBitMask == PhysicsCategory.VikingBodyPart ? contact.bodyA.node : contact.bodyB.node
        
        if let viking = bodyPart?.parent! as? VikingNode, !viking.isWounded {
            viking.arrowHit()
        }
    }
    
    fileprivate func gravityProjectileHitGround(with contact: SKPhysicsContact) {
        if let projectile = currentProjectile as? GravityProjectile, projectile.isInFlight {
            projectile.createGravityField()
        }
    }
    
    fileprivate func wizardCollidesWithChest(with contact: SKPhysicsContact) {
        levelCompleted()
    }
}

extension GameScene: HeroResetProtocol {
    func resetPosition() {
        guard let rose = rose, let pos = rose.startingPosition else { return }
        let resetAction = SKAction.move(to: pos, duration: 0.5)
        rose.run(resetAction)
    }
}

extension GameScene {
    func levelCompleted() {

    }
    
    func gameOver() {
        
    }
}
