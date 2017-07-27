//
//  NSDictionary+Extensions.swift
//  GravityWizard2
//
//  Created by scott mehus on 7/26/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import Foundation

extension NSMutableDictionary {
    
    subscript(accessor: UserDataAccessor) -> Any? {
        get {
            return self[accessor.key]
        }
        
        set {
            self[accessor.key] = newValue
        }
    }
}
