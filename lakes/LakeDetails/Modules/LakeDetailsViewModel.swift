//
//  LakeDetailsViewModel.swift
//  lakes
//
//  Created by Vadim K on 12.09.2018.
//  Copyright © 2018 Vadim K. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
import RxSwift
import RxCocoa

final class LakeDetailsViewModel:ViewModelType {
    
    struct Input {
        let recieveLake: Driver<Void>
    }
    
    struct Output {
        let recievedLake: Driver<Lake>
        let recievedImage: Driver<UIImage?>
        let fetchError: Driver<Error>
    }
    
    var mCurrentLake: Lake? {
        didSet {
            if let id = self.mCurrentLake?.getId() {
                self.mInteractor.setSpecification(specification: LakeByIdSpecification(id: id))
            }
        }
    }
    var mInteractor: LakeInteractorProtocol
    
    init(interactor: LakeInteractorProtocol) {
        self.mInteractor = interactor
    }
    
    func perform(input: LakeDetailsViewModel.Input) -> LakeDetailsViewModel.Output {
        let error = PublishSubject<Error>()
        let loadImage = PublishRelay<String?>()
        
        let lake = input.recieveLake.flatMapLatest {[unowned self] _ in
            return self.mInteractor.fetchById().asDriver(onErrorRecover: { (err) -> SharedSequence<DriverSharingStrategy, Lake> in
                error.onNext(err)
                return PublishSubject<Lake>().asDriver(onErrorJustReturn: Lake())
            })
            }.do(onNext: { (lake) in
                loadImage.accept(lake.getImg())
            })
        let uploadImage = loadImage.flatMapLatest { _ in
           self.mInteractor.loadImage(self.mCurrentLake?.getImg() ?? "" ).asDriver(onErrorJustReturn: nil)
        }.asDriver(onErrorJustReturn: nil)
        
        return Output(recievedLake: lake, recievedImage: uploadImage, fetchError: error.asDriver(onErrorJustReturn: DriverError.undefenedError))
    }
    
    func setCurrentLake(_ lake: Lake) {
        self.mCurrentLake = lake
    }
    
}
