//
//  CGSize+Extensions.swift
//  GravityWizard2
//
//  Created by scott mehus on 12/20/16.
//  Copyright © 2016 scott mehus. All rights reserved.
//

import SpriteKit


func *(size: CGSize, multiplier: CGFloat) -> CGSize {
    let width = size.width * multiplier
    let height = size.height * multiplier
    return CGSize(width: width, height: height)
}

extension CGSize {
    public mutating func offset(dx: CGFloat, dy: CGFloat) -> CGSize {
        width += dx
        height += dy
        return self
    }
}
