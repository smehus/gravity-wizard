//
//  ProjectileNode.swift
//  GravityWizard2
//
//  Created by scott mehus on 7/26/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit

fileprivate enum Texture: String {
    case largeSandRock = "large-sand-rock"
    case smallSandRock = "small-sand-rock"
    
    var largeRockVariation: UIImage {
        let array = [#imageLiteral(resourceName: "sand-rock-1"),
                     #imageLiteral(resourceName: "sand-rock-2"),
                     #imageLiteral(resourceName: "sand-rock-3"),
                     #imageLiteral(resourceName: "sand-rock-4")]
        
        return array.random()
    }

    
    var texture: SKTexture? {
        switch self {
        case .smallSandRock:
            return SKTexture(image: #imageLiteral(resourceName: "small-sand-rock"))
        case .largeSandRock:
            return SKTexture(image: largeRockVariation)
        }
    }
    
}

/// Use the rotation property in the Scene editor node to change the direciton
/// of the projectile shooter thingy
/// Also, use the scene editor custom proprty things that were used in the tile map game
/// to change the texture of projectile to shoot
final class ProjectileNode: SKNode {
    
    fileprivate var baseProjectile: SKSpriteNode?
    
    var rosePosition: CGPoint? {
        didSet {
            
        }
    }
    
    fileprivate func setupNode() {
        guard
            let textureData = userData?[.texture] as? String,
            let texture = Texture(rawValue: textureData)?.texture
        else {
            conditionFailure(with: "Failed to create setup node")
            return
        }
        
        baseProjectile = SKSpriteNode(texture: texture)

    }
    
    fileprivate func startShooting() {
        
    }
    
    fileprivate func stopShooting() {
        
    }
}

extension ProjectileNode: GameLoopListener {
    func update(withDelta deltaTime: Double) {
        guard
            let gameScene = scene as? GameScene,
            let rose = gameScene.rose
        else {
            conditionFailure(with: "Failed to cast scene as game scene")
            return
        }
        
        let position = gameScene.convert(rose.position, from: rose.parent!)
        rosePosition = position
    }
}

extension ProjectileNode: LifecycleListener {
    func didMoveToScene() {
        setupNode()
    }
}
