//
//  SharedSequence.swift
//  lakes
//
//  Created by Vadim K on 09/01/2019.
//  Copyright © 2019 Vadim K. All rights reserved.
//
import RxCocoa

extension SharedSequence {
    func mapToVoid() -> SharedSequence<SharingStrategy, Void> {
        return self.map{ _ -> Void in
            return ()
        }
    }
}
