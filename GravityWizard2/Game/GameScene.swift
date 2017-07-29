//
//  GameScene.swift
//  GravityWizard2
//
//  Created by scott mehus on 12/20/16.
//  Copyright © 2016 scott mehus. All rights reserved.
//

import SpriteKit
import GameplayKit

fileprivate let GRAVITY_VEL: CGFloat = 0.9

protocol SceneEdgeDecider {

    /// Decides if the scene edges shoudl have a physics body
    var shouldAddScenePhysicsEdge: Bool { get }
    
    /// Decides how far the camera should follow the node past the scene edges
    var xConstraintMultiplier: CGFloat { get }
    var yConstraintMultiplier: CGFloat { get }
}

// TODO: Use protocol extensions and find a way to override in sublcass
// FIXME: ARRRRGGGGGGGGGGGGGG - Next time only use protocols and not inheritance
//extension SceneEdgeDecider where Self: SKScene {
//    var yConstraintMultiplier: CGFloat {
//        return 1
//    }
//    
//    var xConstraintMultiplier: CGFloat {
//        return 1
//    }
//}

class GameScene: SKScene, Game, LifecycleEmitter, GameLevel, SceneEdgeDecider {
    
    // MARK: - SceneEdgeDecider
    
    var shouldAddScenePhysicsEdge: Bool {
        assertionFailure("Should always implement 'SceneEdgeDecider' in subclasses")
        return false
    }
    var yConstraintMultiplier: CGFloat {
        return 1
    }
    
    var xConstraintMultiplier: CGFloat {
        return 1
    }
    

    /// Scense
    var roseScene: SKScene!
    
    /// Nodes
    var rose: RoseNode?
    var bloodNode: BloodNode?
    var radialMarker: SKSpriteNode?
    var breakableRocks: BreakableRocksNode?
    
    // Effects
    var radialGravity: SKFieldNode?
    
    
    /// Constants
    let bloodExplosionCount = 5
    
    
    /// Camera
    let cameraNode = SKCameraNode()
    
    /// Trackables
    var lastUpdateTimeInterval: TimeInterval = 0
    var deltaTime: TimeInterval = 0
    var trackingProjectileVelocity = false
    var projectileVelocity: CGFloat = 0
    var currentProjectile: SKNode?
    var currentActionType: ActionType = .spring
    var isRunningStartingAnimation = false
    
    /// Statics
    var particleFactory = ParticleFactory.sharedFactory
    
    /// Touches
    var initialTouchPoint: CGPoint?
    
    var trajectoryNode: SKShapeNode?
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        setupNodes()
        setupCamera()
        setupHeroContactBorder()
    }
    
    
    // MARK: - Sublcass Methods

    func update(levelWith currentTime: TimeInterval, delta: TimeInterval) { }
    func didSimulatePhysicsForLevel() { }
    
    func setupNodes() {
        
        addChild(cameraNode)
        camera = cameraNode
        
        if shouldAddScenePhysicsEdge {
            physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
            physicsBody?.categoryBitMask = PhysicsCategory.Edge
        }

        emitDidMoveToView()
        
        roseScene = SKScene(fileNamed: "Rose")
        rose = childNode(withName: "//rose") as? RoseNode
        setHeroStartingPosition()
        breakableRocks = childNode(withName: "//BreakableRocks") as? BreakableRocksNode
        
        if let node = BloodNode.generateBloodNode() {
            bloodNode = node
        }
    }
    
    fileprivate func setHeroStartingPosition() {
        guard let rose = rose else { return }
        rose.startingPosition = rose.position
    }
    
    
    /// Creates an edge constraint for the camera - so it does not scroll off screen content (black / gray area)
    func cameraEdgeConstraint(with cx: CGFloat, cy: CGFloat) -> SKConstraint {
        let xInset = frame.size.width/2 * cx
        let yInset = playableHeight/2 * cy
        let constraintRect = frame.insetBy(dx: xInset, dy: yInset)
        
        /// These multlipliers decide if the camera should follow past the top off the scene and past the right of the scene
        let xRange = SKRange(lowerLimit: constraintRect.minX, upperLimit: constraintRect.maxX * xConstraintMultiplier)
        let yRange = SKRange(lowerLimit: constraintRect.minY, upperLimit: constraintRect.maxY * yConstraintMultiplier)
        let edgeConstraint = SKConstraint.positionX(xRange, y: yRange)
        edgeConstraint.referenceNode = self
        return edgeConstraint
    }
    
    /// Zoom camera out to full scale
    func runZoomOutAction() {
        guard
            let rose = rose,
            let camera = camera,
            !isIpad()
            else {
                return
        }
        
        let zoomAction = SKAction.scale(to: 1.0, duration: 2.0)
        let scaleAction = SKAction.customAction(withDuration: 2.0) { _,_  in
            let playerConstraint = SKConstraint.distance(SKRange(constantValue: 0), to: rose)
            camera.constraints = [playerConstraint, self.cameraEdgeConstraint(with: camera.xScale, cy: camera.yScale)]
        }
        
        camera.run(SKAction.group([zoomAction, scaleAction]))
    }
    
    /// Zoom camera in and run a completion block when its donezo
    func runZoomInAction(with completion: @escaping () -> Void) {
        completion()
        // I like it better this way
        
//         guard let camera = camera, let rose = rose else { return }
//        if !isIpad() {
//            let zoomAction = SKAction.scale(to: 0.5, duration: 3.0)
//            let scaleAction = SKAction.customAction(withDuration: 3.0) { _ in
//                camera.constraints = [self.cameraEdgeConstraint(with: camera.xScale, cy: camera.yScale)]
//            }
//
//            let move = SKAction.move(to: convert(rose.position, from: rose.parent!), duration: 3.0)
//            camera.run(SKAction.group([zoomAction, scaleAction, move]), completion: completion)
//        
//        } else {
//            completion()
//        }
    }
    
    fileprivate func setupCamera() {
        guard let camera = camera, let rose = rose else { return }
        camera.xScale = 1.0
        camera.yScale = 1.0
        camera.position = sceneMidPoint
        
        isRunningStartingAnimation = true
        runZoomInAction { [weak self] in
            guard let strongSelf = self else { return }
            
            let playerConstraint = SKConstraint.distance(SKRange(constantValue: 0), to: rose)
            camera.constraints = [playerConstraint, strongSelf.cameraEdgeConstraint(with: camera.xScale, cy: camera.yScale)]
            
            self?.isRunningStartingAnimation = false
            self?.setupHUDElements()
        }
    }
    
    fileprivate func setupHeroContactBorder() {
        guard let rose = rose else {
            conditionFailure(with: "SETUP HERO CONTACT BORDER - MISSING ROSE")
            return
        }
        
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
//        setupRewindButton()
    }
    
    fileprivate func setupWeaponSelector() {
        guard
            let camera = camera,
            let selector = WeaponSelector.generateWeaponSelector(),
            let camSize = cameraSize
        else {
            return
        }

        let x = -camSize.width/2
        let y = camSize.height/2
        let newPoint = CGPoint(x: x, y: y)
        selector.position = camera.convert(newPoint, to: selector.parent!)
        selector.alpha = 0.0
        selector.move(toParent: camera)
        let fadeAction = SKAction.fadeIn(withDuration: 0.5)
        selector.run(fadeAction)
    }
    
    fileprivate func setupRewindButton() {
        guard let camera = camera, let camSize = cameraSize else { return }
        
        let rewind = RewindSelector()
        let xValue = (camSize.width / 2) - rewind.calculatedSize.width/2
        let yValue = (camSize.height / 2) - rewind.calculatedSize.height/2
        let newPoint = CGPoint(x: xValue, y: yValue)
        rewind.position = convert(newPoint, to: camera)
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
        case .spring:
            springHero(with: initialPoint, endPoint: endPoint, velocityMultiply: velocity)
        default: return
        }
    }
    
    
}


// MARK: - Trajectory Extension
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
    
    fileprivate func springHero(with initialPoint: CGPoint, endPoint: CGPoint, velocityMultiply: CGFloat) {
        guard let rose = rose, let _ = rose.parent else { return }
     
        var newPoint = initialPoint - endPoint
        let newVelocity = newPoint.offset(dx: 0, dy: newPoint.y * 1.5).normalized() * velocityMultiply
        let vector = CGVector(point: newVelocity)
        rose.jump(towards: vector)
    }
    
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
        guard let rose = rose, let halfHeight = rose.halfSpriteHeight else { return }
        var startingPosition = convert(rose.position, from: rose.parent!)
        
        let arrow = createArrow(at: startingPosition.offset(dx: 0, dy: halfHeight))
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


// MARK: - Life Cycle
extension GameScene {
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTimeInterval > 0 {
            deltaTime = currentTime - lastUpdateTimeInterval
        } else {
            deltaTime = 0
        }
        
        lastUpdateTimeInterval = currentTime
        
        enumerateChildNodes(withName: "//*") { (node, _) in
            guard let loopListener = node as? GameLoopListener else { return }
            loopListener.update(withDelta: self.deltaTime)
        }
//        if let rose = rose {
//            rose.update(withDelta: deltaTime)
//        }
        
        if let projectile = currentProjectile {
            updateDirection(with: projectile)
        }
        
        update(levelWith: currentTime, delta: deltaTime)
    }
    
    override func didSimulatePhysics() {
        didSimulatePhysicsForLevel()
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
            let vel = diff.length() * GRAVITY_VEL
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
        case .arrow, .gravity, .spring:
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
        case .arrow, .gravity, .spring:
            updateProjectile(withTouch: touchPoint)
        case .walk: break
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard let touch = touches.first else { return }
        let touchPoint = touch.location(in: self)
        
        switch currentActionType {
        case .gravity, .arrow, .spring:
            executeProjectile(withTouch: touchPoint)
        case .walk:
            guard let rose = rose else { return }
            rose.stop()
        }
    }
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        contactDidBegin(with: contact)
    }
    
    func contactDidBegin(with contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if collision.collisionCombination() == .bloodCollidesWithGround {
            bloodCollidesWithGround(with: contact)
        }
        
        
        ///
        /// Arrow
        ///
        
        if collision.collisionCombination() == .arrowCollidesWithEdge {
            arrowCollidesWithEdge(with: contact)
        }
        
        if collision.collisionCombination() == .arrowCollidesWithBreakable {
            arrowCollidesWithBreakable(with: contact)
        }
        
        if collision.collisionCombination() == .arrowCollidesWithGround {
            arrowCollidesWithGround(with: contact)
        }
        
        if collision.collisionCombination() == .arrowCollidesWithDesctructible {
            arrowCollidesWithDesctructable(with: contact)
        }
        
        if collision.collisionCombination() == .arrowCollidesWithEnemy {
            arrowCollidesWithEnemy(with: contact)
        }
        
        
        ///
        /// Enemy
        ///
        
        if collision.collisionCombination() == .enemyCollidesWithBorder {
            enemyCollidesWithBorder(with: contact)
        }
        
        if collision.collisionCombination() == .enemyCollidesWithGround {
            enemyCollidesWithGround(with: contact)
        }
        
        // Gravity Projectile
        if collision.collisionCombination() == .gravityProjectileHitsGround {
            gravityProjectileHitGround(with: contact)
        }
        
        ///
        /// Hero
        ///
        
        if collision.collisionCombination() == .heroCollidesWithLevelComplete {
            heroCollidesWithLevelComplete(with: contact)
        }
        
        if collision.collisionCombination() == .heroCollidesWithLava {
            heroCollidesWithLava(with: contact)
        }
        
        if collision.collisionCombination() == .HeroCollidesWithGround {
            roseHitsGround(with: contact)
        }
        
        if collision.collisionCombination() == .heroCollidesWithStone {
            rockHitsHero(with: contact)
        }
        
        if collision.collisionCombination() == .heroCollidesWithGravityField {
            heroCollidesWithGravityField(with: contact)
        }
        
        if collision.collisionCombination() == .heroCollidesWithEnemy {
            heroCollidesWithEnemy(with: contact)
        }
        
        if collision.collisionCombination() == .heroCollidesWithObstacle {
            heroCollidesWithObstacle(with: contact)
        }
        
        if collision.collisionCombination() == .heroCollidesWithWater {
            heroCollidesWithWater(with: contact)
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
    
    private func heroCollidesWithWater(with contact: SKPhysicsContact) {
        guard let rose = rose else { return }
        rose.drown()
        let contactPoint = contact.contactPoint
        particleFactory.waterSplash(scene: self, position: contactPoint)
        gameOver()
    }
    
    private func heroCollidesWithGravityField(with contact: SKPhysicsContact) {
        let gravity = contact.bodyA.categoryBitMask == PhysicsCategory.GravityProjectile ? contact.bodyA.node : contact.bodyB.node
        guard let field = gravity as? GravityProjectile, field.shouldCollideWithLauncher else { return }
        
        field.removeFromParent()
        currentProjectile = nil
    }
    
    private func roseHitsGround(with contact: SKPhysicsContact) {
        let node = contact.bodyA.categoryBitMask == PhysicsCategory.Ground ? contact.bodyA.node : contact.bodyB.node
        guard
            let rose = rose, rose.gravityState == .falling,
            let contactNode = node,
            let contactBody = contactNode.physicsBody
        else { return }
        
        let addJoint = (contactNode is MovingPlatform) ? true : false
        rose.hardLanding(with: contactBody, contactPoint: contact.contactPoint, addJoint: addJoint)
    }
    
    private func heroCollidesWithLava(with contact: SKPhysicsContact) {
        rose?.runLavaDeathAnimation()
        gameOver()
    }
    
    private func heroCollidesWithEnemy(with contact: SKPhysicsContact) {
        let heroNode = contact.bodyA.categoryBitMask == PhysicsCategory.Hero ? contact.bodyA.node : contact.bodyB.node
        guard let rose = heroNode as? RoseNode else {
            assertionFailure("Hero collides with enemy: failed to cast to rose")
            return
        }
        
        rose.attacked()
    }
    
    private func heroCollidesWithObstacle(with contact: SKPhysicsContact) {
        let heroNode = contact.bodyA.categoryBitMask == PhysicsCategory.Hero ? contact.bodyA.node : contact.bodyB.node
        let obstacle = contact.bodyA.categoryBitMask == PhysicsCategory.indesctructibleObstacle ? contact.bodyA.node : contact.bodyB.node
        guard
            let rose = heroNode as? RoseNode,
            let obstacleParent = obstacle?.parent as? Obstacle
        else {
            conditionFailure(with: "Hero collides with enemy: failed to cast to rose")
            return
        }
        
        rose.attacked()
        obstacleParent.collision(at: contact.contactPoint)
    }
    
    private func rockHitsHero(with contact: SKPhysicsContact) {
        guard let rose = rose else { return }
        createBloodExplosion(with: rose)
    }
    
    private func bloodCollidesWithGround(with contact: SKPhysicsContact) {
        let node = contact.bodyA.categoryBitMask == PhysicsCategory.Blood ? contact.bodyA.node : contact.bodyB.node
        
        if let blood = node as? BloodNode {
            blood.hitGround()
        }
    }
    // TODO: If second arrow is launched while first arrow is still in air - the first arrow will be removed
    private func arrowCollidesWithEdge(with contact: SKPhysicsContact) {
        let node = contact.bodyA.categoryBitMask == PhysicsCategory.arrow ? contact.bodyA.node : contact.bodyB.node
        if let arrow = node {
            arrow.removeFromParent()
        }
    }
    
    private func arrowCollidesWithBreakable(with contact: SKPhysicsContact) {
        if let arrow = currentProjectile {
            explosion(at: arrow.position)
            guard let breakableRocks = breakableRocks else { return }
            breakableRocks.breakRocks()
            arrow.removeFromParent()
        }
    }
    
    private func arrowCollidesWithGround(with contact: SKPhysicsContact) {
        let node = contact.bodyA.categoryBitMask == PhysicsCategory.arrow ? contact.bodyA.node : contact.bodyB.node
        if let arrow = node as? ArrowNode {
            arrow.physicsBody = nil
        }
    }
    
    private func arrowCollidesWithEnemy(with contact: SKPhysicsContact) {
        let enemyNode = contact.bodyA.categoryBitMask == PhysicsCategory.enemy ? contact.bodyA.node : contact.bodyB.node
        let arrowNode = contact.bodyA.categoryBitMask == PhysicsCategory.arrow ? contact.bodyA.node : contact.bodyB.node
        guard let enemy = enemyNode as? Enemy else {
            assertionFailure("Failed to cast collision node to Enemy type")
            return
        }
        
        createFixedJoint(with: arrowNode, nodeB: enemyNode, position: contact.contactPoint)
        enemy.hitWithArrow()
    }
    
    private func arrowCollidesWithDesctructable(with contact: SKPhysicsContact) {
        guard
            let node = contact.bodyA.categoryBitMask == PhysicsCategory.destructible ? contact.bodyA.node : contact.bodyB.node,
            let arrowNode = contact.bodyA.categoryBitMask == PhysicsCategory.arrow ? contact.bodyA.node : contact.bodyB.node,
            let arrow = arrowNode as? ArrowNode,
            let destructible = node as? DesctructibleStone
            else {
                return
        }
        
        if destructible.currentTexture != .broken {
            createFixedJoint(with: arrow, nodeB: destructible, position: contact.contactPoint)
        }
        
        destructible.hit()
    }
    
    private func gravityProjectileHitGround(with contact: SKPhysicsContact) {
        if let projectile = currentProjectile as? GravityProjectile, projectile.isInFlight {
            projectile.createGravityField()
        }
    }
    
    private func heroCollidesWithLevelComplete(with contact: SKPhysicsContact) {
        levelCompleted()
    }
    
    private func enemyCollidesWithBorder(with contact: SKPhysicsContact) {
        print("Enemy Collides With Border Body")
    }
    
    private func enemyCollidesWithGround(with contact: SKPhysicsContact) {
        let enemyNode = contact.bodyA.categoryBitMask == PhysicsCategory.enemy ? contact.bodyA.node : contact.bodyB.node
        let wait = SKAction.wait(forDuration: 2.0)
        let remove = SKAction.removeFromParent()
        
        enemyNode?.run(SKAction.sequence([ wait, remove ]))
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
    func levelCompleted() {}
    func gameOver() {}
}

extension GameScene {
    func add(joint: SKPhysicsJoint) {
        physicsWorld.add(joint)
    }
}
