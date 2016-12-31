//
//  GravityProjectile.swift
//  GravityWizard2
//
//  Created by scott mehus on 12/31/16.
//  Copyright © 2016 scott mehus. All rights reserved.
//

import SpriteKit

class GravityProjectile: SKNode {

    static func generateGravityProjectile() -> GravityProjectile? {
        guard
            let file = SKScene(fileNamed: "GravityProjectile"),
            let sprite = file.childNode(withName: "root") as? GravityProjectile
            else {
                assertionFailure("Missing sprite or file")
                return nil
        }
        
        return sprite
    }
    
}
