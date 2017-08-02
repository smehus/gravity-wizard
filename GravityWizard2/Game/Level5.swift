//
//  Level5.swift
//  GravityWizard2
//
//  Created by scott mehus on 7/30/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit

final class Level5: GameScene {
    
    // MARK: Super Properties
    
    var currentLevel: Level {
        return .five
    }
    
    override var shouldAddScenePhysicsEdge: Bool {
        return false
    }
    
    override var yConstraintMultiplier: CGFloat {
        return 1
    }
    
    override var xConstraintMultiplier: CGFloat {
        return 20
    }
    
    override var totalSceneSize: CGSize {
        guard let scene = scene else { return CGSize.zero }
        let halfScene = scene.size.width / 2
        // xConstraintMultiplier is the multipier for half scene segments - specifically for constraints.
        // Kinda weird but whatever
        let totalWidth = (halfScene * xConstraintMultiplier) + halfScene
        return CGSize(width: totalWidth, height: scene.size.height)
    }
    
    // MARK: - Private Properties
    
    private var maxXPosition: CGFloat {
        let cameraPosition = convert(camera!.position, from: camera!.parent!)
        let returnValue = cameraPosition.x + (scene!.size.width / 2)
        return returnValue
    }
    
    private var lastPlatformPosition: CGFloat?
    private var isRendering = true
    private var finalPlatformPlaced = false

    private var platformDistribution: CGFloat {
        let random = Int.random(min: 300, max: Int(scene!.size.width))
        return CGFloat(random)
    }
 
    private var lastFieldWave: TimeInterval = 0
    private var waveFrequency: TimeInterval {
        return Double(Int.random(min: 6, max: 10))
    }
    
    // MARK: - Super Functions
    
    override func setupNodes() {
        super.setupNodes()
        lastPlatformPosition = 1000
        populatePlatforms()
        generateField()
    }
    
    override func update(levelWith currentTime: TimeInterval, delta: TimeInterval) {
        guard isRendering else { return }
        roseCheck()
        populatePlatforms()
        
        lastFieldWave += delta
        
        ///
        /// Create gravity waves
        ///
        
        if lastFieldWave >= waveFrequency {
            lastFieldWave = 0
            generateField()
        }
    }
    
    // MARK: - Private Functions
    
    private func roseCheck() {
        guard let rose = rose else { return }
        let rosePosition = convert(rose.position, from: rose.parent!)
        
        if rosePosition.y < 0 {
            gameOver()
            isRendering = false
        }
    }
    
    private func populatePlatforms() {
        guard var lastPosition = lastPlatformPosition, lastPosition < maxXPosition else {
            return
        }
        
        if maxXPosition >= (totalSceneSize.width - (scene!.size.width / 2))  {
            createFinalPlatform()
            return
        }
        
        while lastPosition < maxXPosition && maxXPosition < (totalSceneSize.width - scene!.size.width) {
            print("LAST POS: \(lastPosition) MAXXPOS \(maxXPosition) TOTALSCENW DITH \(totalSceneSize.width) SCEN WIDTH \(scene!.size.width)")
            lastPosition += platformDistribution
            generatePlatform(at: lastPosition)
            lastPlatformPosition = lastPosition
        }
    }
    
    private func generatePlatform(at x: CGFloat) {
        guard let platformNode = CollapsablePlatform.generate() else {
            conditionFailure(with: "Failed to init collapsable platform")
            return
        }

        let nextPosition = CGPoint(x: x, y: 0)
        platformNode.position = nextPosition
        platformNode.zPosition = 10
        platformNode.move(toParent: self)
    }
    
    private func generateField() {
        let fieldHeight: CGFloat = scene!.size.height / 2
        let fieldWidth: CGFloat = 500
        
        let field = Field.linear.generate()
        //TODO: Y position of camera is off at first - similar to how the x pos was off before
        
        print("🎒 cam pos: \(camera!.position.y)")
        field.position = CGPoint(x: maxXPosition, y: camera!.position.y)
        field.region = SKRegion(size: CGSize(width: fieldWidth, height: fieldHeight))
        addChild(field)
        
        let stormParticle = particleFactory.sandStorm(width: fieldWidth, height: fieldHeight)
        
        let constraint = SKConstraint.distance(SKRange(constantValue: 0), to: CGPoint(x: -(fieldWidth / 2), y: 0), in: field)
        stormParticle.constraints = [constraint]
        stormParticle.targetNode = self
        addChild(stormParticle)
        
        let removal = SKAction.run {
            field.removeFromParent()
            stormParticle.removeFromParent()
        }
        
        let move = SKAction.moveBy(x: -(scene!.size.width * 2), y: 0, duration: 10.0)
        field.run(SKAction.sequence([move, removal]))

    }
    
    private func createFinalPlatform() {
        guard !finalPlatformPlaced else { return }
        finalPlatformPlaced = true
        
        print("🐟 Creating Final Platform")
        let platformTexture = SKTexture(image: #imageLiteral(resourceName: "sand-platform"))
        let platform = SKSpriteNode(texture: platformTexture, size: platformTexture.size())
        platform.physicsBody = SKPhysicsBody(texture: platformTexture, size: platformTexture.size())
        platform.physicsBody?.isDynamic = false
        platform.physicsBody?.categoryBitMask = PhysicsCategory.Ground
        platform.physicsBody?.collisionBitMask = PhysicsCategory.Hero
        platform.physicsBody?.contactTestBitMask = PhysicsCategory.Hero
        platform.position = CGPoint(x: (totalSceneSize.width - (platformTexture.size().width * 2)), y: platformTexture.size().height / 2)
        platform.zPosition = 10
        
        let door = LevelCompleteNode.instantiate()
        door.position = CGPoint(x: 0, y: (platformTexture.size().height / 2) + (door.texture!.size().height / 2))
        door.zPosition = 20
        platform.addChild(door)
        
        addChild(platform)
    }
}

// MARK: - End Level

extension Level5 {
    @objc override func levelCompleted() {
        guard let successLevel = LevelCompleteLabel.createLabel(), let camera = camera else { return }
        successLevel.move(toParent: camera)
        successLevel.position = CGPoint.zero
        
        
        let presentScene = SKAction.afterDelay(2.0) {
            guard let nextLevel = self.currentLevel.nextLevel()?.levelScene() else { return }
            nextLevel.scaleMode = self.scaleMode
            let transition = SKTransition.doorsOpenHorizontal(withDuration: 1.0)
            self.view?.presentScene(nextLevel, transition: transition)
            
        }
        
        run(presentScene)
    }
    
    @objc override func gameOver() {
        
        guard let gameOverLabel = LevelCompleteLabel.createLabel(with: "Game Over"), let camera = camera else { return }
        gameOverLabel.move(toParent: camera)
        gameOverLabel.position = CGPoint.zero
        
        runZoomOutAction()
        let presentScene = SKAction.afterDelay(2.0) {
            guard let reloadLevel = self.currentLevel.levelScene() else {
                self.conditionFailure(with: "Failed to load level scene on game over")
                return
            }
            
            reloadLevel.scaleMode = self.scaleMode
            let transition = SKTransition.doorsOpenHorizontal(withDuration: 1.0)
            self.view?.presentScene(reloadLevel, transition: transition)
            
        }
        
        run(presentScene)
    }
}
