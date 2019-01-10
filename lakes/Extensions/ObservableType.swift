//
//  ObservableType.swift
//  lakes
//
//  Created by Vadim K on 09/01/2019.
//  Copyright © 2019 Vadim K. All rights reserved.
//
import RxSwift

extension ObservableType {
    func mapToVoid() -> Observable<Void> {
        return self.map{ _ -> Void in
            return ()
        }
    }
}
