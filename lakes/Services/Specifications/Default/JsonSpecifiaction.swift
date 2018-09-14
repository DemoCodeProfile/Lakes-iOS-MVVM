//
//  JsonSpecifiaction.swift
//  lakes
//
//  Created by Vadim K on 12.09.2018.
//  Copyright © 2018 Vadim K. All rights reserved.
//

import Foundation

protocol JsonSpecifiaction: BaseSpecification {
    func toJsonQuery() -> Int
}
