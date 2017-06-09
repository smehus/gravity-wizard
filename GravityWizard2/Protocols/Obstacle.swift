//
//  Obstacle.swift
//  GravityWizard2
//
//  Created by scott mehus on 5/29/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit

protocol Obstacle {
    func collision(at contactPoint: CGPoint)
}
