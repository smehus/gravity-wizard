//
//  GravityStateTracker.swift
//  GravityWizard2
//
//  Created by scott mehus on 12/30/16.
//  Copyright © 2016 scott mehus. All rights reserved.
//

import SpriteKit

protocol GravityStateTracker {
    var gravityState: GravityState { get set }
    var physicsBody: SKPhysicsBody? { get set }
}

