//
//  LakeByIdSpecification.swift
//  lakes
//
//  Created by Vadim K on 12.09.2018.
//  Copyright © 2018 Vadim K. All rights reserved.
//

import Foundation

class LakeByIdSpecification: JsonSpecifiaction {
    private var mId: Int
    
    init(id: Int) {
        self.mId = id
    }
    
    func toJsonQuery() -> Int {
        return self.mId
    }
}
