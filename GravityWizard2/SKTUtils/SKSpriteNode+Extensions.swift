//
//  SKSpriteNode+Extensions.swift
//  GravityWizard2
//
//  Created by scott mehus on 2/23/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit

extension SKSpriteNode {
    var spriteSize: CGSize? {
        guard let text = texture else {
            return nil
        }
        
        return text.size()
    }
    
    var halfSpriteHeight: CGFloat? {
        guard let text = texture else {
            return nil
        }
        
        let size = text.size()
        return size.height/2
    }
}
