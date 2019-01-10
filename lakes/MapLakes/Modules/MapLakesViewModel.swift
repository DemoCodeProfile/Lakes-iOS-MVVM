//
//  MapLakesViewModel.swift
//  lakes
//
//  Created by Vadim K on 12.09.2018.
//  Copyright © 2018 Vadim K. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import GoogleMaps


protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    func perform(input: Input) -> Output
}

final class MapLakesViewModel: ViewModelType {
    struct Input{
        let recieveLakes: Driver<Void>
        let openDataFromMap: Driver<GMSMarker>
    }

    struct Output {
        let recievedLakes: Driver<[GMSMarker : Lake]>
        let fetchError: Driver<Error>
    }
    
    var mInteractor: MapInteractorProtocol
    var mRouter: MapWireframeProtocol
    private var disposeBag = DisposeBag()
    
    init(interactor: MapInteractorProtocol, router: MapWireframeProtocol) {
        self.mInteractor = interactor
        self.mRouter = router
    }
    
    func perform(input: MapLakesViewModel.Input) -> MapLakesViewModel.Output {
        let error = PublishRelay<Error>()
        let lakes = input.recieveLakes.flatMapLatest { [weak self] _ -> Driver<[GMSMarker : Lake]> in
            guard let `self` = self else { return .empty() }
            return self.mInteractor
                .fetchAll()
                .asDriver(onErrorJustReturn: [])
                .map({ lakes -> [GMSMarker : Lake] in
                    var markers:[GMSMarker : Lake] = [:]
                    for lake in lakes {
                        let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: lake.getLat(), longitude: lake.getLon()))
                        marker.title = lake.getTitle()
                        markers.updateValue(lake, forKey: marker)
                    }
                    return markers
                })
        }
        
        input.openDataFromMap
            .withLatestFrom(lakes) { (marker, markers) -> Lake in
                return markers[marker]!
            }
            .drive(onNext: mRouter.toLakeDetails)
            .disposed(by: disposeBag)
        
        let errors = error.asDriver(onErrorJustReturn: DriverError.undefenedError)
        return Output(recievedLakes: lakes, fetchError: errors)
    }
}

enum DriverError: Error {
    case undefenedError
}
