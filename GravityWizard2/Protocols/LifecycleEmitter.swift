//
//  LifecycleEmitter.swift
//  GravityWizard2
//
//  Created by scott mehus on 12/20/16.
//  Copyright © 2016 scott mehus. All rights reserved.
//

import SpriteKit

protocol LifecycleEmitter {
    func emitDidMoveToView()
}

extension LifecycleEmitter where Self: SKScene {
    func emitDidMoveToView() {
        enumerateChildNodes(withName: "//*") { (node, _) in
            guard let listenerNode = node as? LifecycleListener else { return }
            listenerNode.didMoveToScene()
        }
    }
}
