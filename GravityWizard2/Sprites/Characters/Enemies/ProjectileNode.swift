//
//  ProjectileNode.swift
//  GravityWizard2
//
//  Created by scott mehus on 7/26/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit

fileprivate enum Texture: String {
    case large = "large-rock"
    
    var texture: SKTexture? {
        return nil
    }
    
}

/// Use the rotation property in the Scene editor node to change the direciton
/// of the projectile shooter thingy
/// Also, use the scene editor custom proprty things that were used in the tile map game
/// to change the texture of projectile to shoot
final class ProjectileNode: SKNode {
    
    fileprivate func setupNode() {
        guard
            let textureData = userData?[.texture] as? String,
            let texture = Texture(rawValue: textureData)?.texture
        else {
            conditionFailure(with: "Failed to create setup node")
            return
        }
    }
}

extension ProjectileNode: LifecycleListener {
    func didMoveToScene() {
        setupNode()
    }
}
