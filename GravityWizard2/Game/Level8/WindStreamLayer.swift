//
//  WindStreamLayer.swift
//  GravityWizard2
//
//  Created by scott mehus on 9/3/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit

class WindStreamLayer: SKNode {
    
    static let ENEMY_NAME = "enemy"
    
    private var parentScene: Level8 {
        return scene as! Level8
    }
    
    private let numberOfStreams: CGFloat = 0
    private let particleFactory = ParticleFactory.sharedFactory
    private var lastStreamWasUp: Bool = true
    
    func setupStreams(size: CGSize) {
        var streamPosition: CGPoint = CGPoint(x: parentScene.frame.size.width / 3, y: 0)
        addStream(at: streamPosition)
        
        var passCount = 0
        while streamPosition.x < (size.width - (parentScene.size.width * 0.75)) {
            var nextPosition: CGPoint
            
            ///
            /// Add Field node & Particle Emitter
            ///
            
            switch lastStreamWasUp {
            case true:
                // Down Stream
                nextPosition = CGPoint(x: streamPosition.x + (parentScene.size.width / 3), y: CGFloat.random(min: parentScene.totalSceneSize.height/2, max: parentScene.totalSceneSize.height))
                addStream(at: nextPosition, upwards: false)
            case false:
                // Up Stream
                nextPosition = CGPoint(x: (streamPosition.x + (parentScene.frame.size.width / 3)), y: CGFloat.random(min: -50, max: parentScene.totalSceneSize.height / 2))
                addStream(at: nextPosition, upwards: true)
            }
            
            ///
            /// Add Enemies between the current stream and the next stream
            ///
            
            addEnemy(between: streamPosition, secondPoint: nextPosition, count: 2)
            
            
            ///
            /// Add platform if required
            ///
//            if ((parentScene.size.width * CGFloat(passCount)) + parentScene.size.halfWidth) < streamPosition.x {
//                addPlatform(between: streamPosition.x, and: nextPosition.x)
//                passCount += 1
//            }
            
            addPlatform(between: streamPosition.x, and: nextPosition.x)
            
            streamPosition = nextPosition
            
            ///
            /// Check for end of the scene. Place the level complete platform
            ///
            
            if streamPosition.x > (size.width - (parentScene.size.width * 0.75)) {
                spawnFinalPlatform()
            }
        }
    }
    
    func update() {
        
    }
    
    private func addStream(at point: CGPoint, upwards: Bool = true) {
        lastStreamWasUp = upwards
        let initialEmitter = upwards ? particleFactory.upwardsWind() : particleFactory.downwardsWind()
        initialEmitter.position = convert(point, to: self)
        initialEmitter.zPosition = 50
        addChild(initialEmitter)
        
        let vector = upwards ? vector_float3(0, 1, 0) : vector_float3(0, -1, 0)
        let field = SKFieldNode.linearGravityField(withVector: vector)
        field.position = convert(point, to: self)
        field.categoryBitMask = PhysicsCategory.heroField
        field.strength = 15
        field.region = SKRegion(size: CGSize(width: 300, height: (scene as! GameScene).totalSceneSize.height))
        addChild(field)
    }
    
    private func addPlatform(between lhs: CGFloat, and rhs: CGFloat) {
        let diff = (rhs - lhs) / 2
        let xPos = lhs + diff
        let yPos = CGFloat.random(min: 0, max: parentScene.totalSceneSize.halfHeight)
        let platformPosition = CGPoint(x: xPos, y: yPos)
        
        let texture = SKTexture(image: #imageLiteral(resourceName: "grass-edge-platform"))
        let sprite = GroundNode(texture: texture, size: texture.size())
        sprite.position = convert(platformPosition, to: self)
        sprite.zPosition = 20
        addChild(sprite)
    }
    
    private func addEnemy(between firstPoint: CGPoint, secondPoint: CGPoint, count: Int) {
        
        let diff = (secondPoint.x - firstPoint.x) / 2
        let enemyX = firstPoint.x + diff
        
        for i in 0..<count {
            let startingMinY = parentScene.totalSceneSize.halfHeight * CGFloat(i)
            
            let textureSizeMultiplier: CGFloat = 3
            let texture: FlyingEnemyTexture = Bool.random() ? .propeller : .winged
            let halfTextureHeight = (texture.texture.size() * textureSizeMultiplier).halfHeight
            
            let enemyY = CGFloat.random(min: max(startingMinY, halfTextureHeight), max: parentScene.totalSceneSize.halfHeight + startingMinY)
            let point = CGPoint(x: enemyX, y: enemyY)
            
            
            let sprite = FlyingEnemy(texture: texture.texture, color: .white, size: texture.texture.size() * textureSizeMultiplier)
            sprite.name = WindStreamLayer.ENEMY_NAME
            sprite.position = convert(point, to: self)
            
            let body = SKPhysicsBody(texture: texture.texture, size: texture.texture.size() * textureSizeMultiplier)
            body.categoryBitMask = PhysicsCategory.enemy
            body.contactTestBitMask = PhysicsCategory.arrow
            body.collisionBitMask = PhysicsCategory.arrow | PhysicsCategory.Hero | PhysicsCategory.enemy | PhysicsCategory.Ground
            body.fieldBitMask = PhysicsCategory.heroField
            body.isDynamic = true
            body.affectedByGravity = false
            body.allowsRotation = true
            sprite.physicsBody = body
            
            let textureAnimation = SKAction.animate(with: texture.animationTextures, timePerFrame: 0.2)
            
            let jumpVector: CGFloat = CGFloat.random(min: -150, max: 150)
            let jumpUpAction = SKAction.moveBy(x: 0, y: jumpVector, duration: Double(CGFloat.random(min: 0.3, max: 1.0)))
            let jumpSequence = SKAction.sequence([jumpUpAction, jumpUpAction.reversed()])
            
            let finalSequence = SKAction.group([textureAnimation, jumpSequence])
            sprite.run(SKAction.repeatForever(finalSequence))
            
            addChild(sprite)
        }
    }
    
    private func spawnFinalPlatform() {

        let texture = SKTexture(image: #imageLiteral(resourceName: "grass-edge-platform"))
        let platform = GroundNode(texture: texture, size: texture.size())
        platform.position = CGPoint(x: parentScene.totalSceneSize.width - (parentScene.size.halfWidth / 2), y: parentScene.size.halfHeight)
        
        let doorTexture = SKTexture(image: #imageLiteral(resourceName: "black-door"))
        let door = SKSpriteNode(texture: doorTexture, color: .white, size: doorTexture.size() * 2)
        door.physicsBody = SKPhysicsBody(rectangleOf: doorTexture.size() * 2)
        door.physicsBody?.categoryBitMask = PhysicsCategory.LevelComplete
        door.physicsBody?.contactTestBitMask = PhysicsCategory.Hero
        door.physicsBody?.isDynamic = false
        door.position = CGPoint(x: 0, y: (platform.size.halfHeight + door.size.halfHeight))
        platform.addChild(door)
        addChild(platform)
    }
}
