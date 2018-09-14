//
//  ApplicationAssembly.swift
//  lakes
//
//  Created by Vadim K on 12.09.2018.
//  Copyright © 2018 Vadim K. All rights reserved.
//
import Swinject
import SwinjectStoryboard

class ApplicationAssembly {
    class var assembler: Assembler {
        return Assembler([
            MapAssembly(),
            LakeAssembly()
            ])
    }
}

extension SwinjectStoryboard {
    @objc class func setup() {
        defaultContainer = ApplicationAssembly.assembler.resolver as! Container
    }
}
