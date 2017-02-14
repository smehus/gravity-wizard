//
//  RewindSelector.swift
//  GravityWizard2
//
//  Created by scott mehus on 2/14/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import Foundation
import SpriteKit

protocol HeroResetProtocol {
    func resetPosition()
}

final class RewindSelector: SKSpriteNode {

    let Texture_Multiplier: CGFloat = 0.5

    var calculatedSize: CGSize {
        guard let texture = texture else { return CGSize.zero }
        return texture.size() * Texture_Multiplier
    }
    
    var parentGameScene: HeroResetProtocol? {
        return scene as? HeroResetProtocol
    }
    
    init() {
        let buttonTexture = SKTexture(image: #imageLiteral(resourceName: "rewind-button"))
        super.init(texture: buttonTexture, color: .white,
                   size: buttonTexture.size() * Texture_Multiplier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setup() {
        isUserInteractionEnabled = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let _ = touches.first, let gameScene = parentGameScene else { return }
        gameScene.resetPosition()
        
    }
}
