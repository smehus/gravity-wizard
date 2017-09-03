//
//  PlatformLayer.swift
//  GravityWizard2
//
//  Created by scott mehus on 9/2/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit

class PlatformLayer: SKNode {
    
   @objc private dynamic var isSpawning = true
    private var platformTexture: SKTexture?
    private var lastPlatformPosition: CGPoint?
    private var stateListener: NSKeyValueObservation?
    
    private var randomXPosition: CGFloat {
        return CGFloat.random(min: 0, max: parentScene.totalSceneSize.width)
    }
    
    private var parentScene: Level7 {
        return scene as! Level7
    }
    
    func setupSprites() {
        platformTexture = SKTexture(image: #imageLiteral(resourceName: "grass-edge-platform"))
        
        stateListener = self.observe(\.isSpawning, options: [.new]) { (strongSelf , change) in
            if change.newValue == false {
                strongSelf.spawnFinalPlatform()
            }
        }
    }
    
    func update(levelWith currentTime: TimeInterval, delta: TimeInterval) {
        if isSpawning {
            spawnPlatform()
        }
    }
    
    private func spawnPlatform() {
        switch lastPlatformPosition {
        case .none:
            spawnInitial()
        case .some(let pos):
            spawnNext(position: pos)
        }
    }
    
    private func spawnInitial() {
        guard let sprite = spawnSprite() else { return }
        sprite.position = CGPoint(x: randomXPosition, y: parentScene.playableHeight / 2)
        addChild(sprite)
        
        lastPlatformPosition = sprite.position
    }
    
    private func spawnNext(position: CGPoint) {
        guard let lastPosition = lastPlatformPosition else {
            spawnInitial()
            return
        }
        
        guard lastPosition.y < (parentScene.totalSceneSize.height - (parentScene.playableHeight / 2)) else {
            isSpawning = false
            return
        }
        
        guard let sprite = spawnSprite() else { return }
        
        sprite.position = CGPoint(x: randomXPosition, y: lastPosition.y + (parentScene.playableHeight / 2))
        addChild(sprite)
        
        lastPlatformPosition = sprite.position
    }
    
    private func spawnFinalPlatform() {
        guard let platform = spawnSprite() else { fatalError() }
        let halfPlayableHeight = parentScene.playableHeight / 2
        let yPOS = parentScene.totalSceneSize.height - (halfPlayableHeight / 2)
        platform.position = CGPoint(x: randomXPosition, y: yPOS)
        
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
    
    private func spawnSprite() -> SKSpriteNode? {
        guard let texture = platformTexture else { return nil }
        let sprite = SKSpriteNode(texture: texture)
        let body = SKPhysicsBody(texture: texture, size: texture.size())
        body.categoryBitMask = PhysicsCategory.Ground
        body.collisionBitMask = PhysicsCategory.Hero
        body.contactTestBitMask = PhysicsCategory.Hero
        body.isDynamic = false
        sprite.physicsBody = body
        
        return sprite
    }
}

extension PlatformLayer: LifecycleListener {
    func didMoveToScene() {
        setupSprites()
    }
}
