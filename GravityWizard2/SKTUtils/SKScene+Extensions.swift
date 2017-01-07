//
//  SKScene+Extensions.swift
//  GravityWizard2
//
//  Created by scott mehus on 1/7/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit

extension SKScene {
    func zeroAnchoredCenter() -> CGPoint {
        let width = size.width / 2
        let height = size.height / 2
        return CGPoint(x: position.x + width, y: position.y + height)
    }
}
