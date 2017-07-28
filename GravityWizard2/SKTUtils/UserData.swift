//
//  UserData.swift
//  GravityWizard2
//
//  Created by scott mehus on 7/28/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import Foundation

enum UserDataError: Error {
    case initFailed
}

protocol StringInitable {
    init?(string: String)
}

struct UserData {
    
    private let rawData: NSMutableDictionary
    
    init(data: NSMutableDictionary?) throws{
        guard let userData = data else {
            throw UserDataError.initFailed
        }
        
        self.rawData = userData
    }
    
    func value<T: StringInitable>(for accessor: UserDataAccessor) -> T? {
        guard let object = rawData[accessor] as? String else {
            return nil
        }
        
        return T.init(string: object)
    }
}
