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
    
    typealias Input = Void
    
    struct Output {
        let recievedLake: Driver<Lake>
        let recievedImage: Driver<UIImage?>
        let fetchError: Driver<Error>
    }
    
    private var mInteractor: LakeInteractorProtocol
    private let disposeBag = DisposeBag()
    let currentLake = BehaviorRelay<Lake?>(value: nil)
    
    init(interactor: LakeInteractorProtocol) {
        self.mInteractor = interactor
    }
    
    func perform(input: Input) -> Output {
        let error = PublishRelay<Error>()
        
        let lake = currentLake.asDriver(onErrorJustReturn: nil)
            .flatMapLatest { [weak self] lake -> Driver<Lake> in
                guard let `self` = self else { return .empty() }
                let specification = LakeByIdSpecification(id: lake?.getId() ?? 0)
                self.mInteractor.setSpecification(specification: specification)
                return self.mInteractor
                    .fetchById()
                    .asDriver(onErrorRecover: { (err) -> Driver<Lake> in
                        error.accept(err)
                        return .just(Lake())
                    })
            }
        
        let uploadImage = lake.asDriver()
            .map { $0.getImg() }
            .flatMapLatest { [weak self] urlImage -> Driver<UIImage?> in
                guard let `self` = self else { return .empty() }
                return self.mInteractor.loadImage(urlImage ?? "").asDriver(onErrorJustReturn: nil)
            }
        
        return Output(
            recievedLake: lake,
            recievedImage: uploadImage,
            fetchError: error.asDriver(onErrorJustReturn: DriverError.undefenedError)
        )
    }
    
    
}
