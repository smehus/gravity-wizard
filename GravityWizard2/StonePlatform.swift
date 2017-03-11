//
//  StonePlatform.swift
//  GravityWizard2
//
//  Created by scott mehus on 3/10/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import Foundation
import SpriteKit

fileprivate struct Names {
    static let tile = "tile"
    static let container = "container"
}

final class StonePlatform: SKNode {
    
    fileprivate func setupTileBodies() {
        enumerateChildNodes(withName: "//\(Names.tile)") { node, _ in
            guard let sprite = node as? SKSpriteNode else { return }
            
        }
    }

    fileprivate func setupBody(with sprite: SKSpriteNode) {
        
    }
    
    fileprivate func setupContainerBody(with node: SKNode) {
        
    }
}

extension StonePlatform: LifecycleListener {
    func didMoveToScene() {
        setupTileBodies()
    }
}
