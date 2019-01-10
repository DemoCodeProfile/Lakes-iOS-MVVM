//
//  MapViewController.swift
//  lakes
//
//  Created by Vadim K on 12.09.2018.
//  Copyright © 2018 Vadim K. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxGoogleMaps
import GoogleMaps

final class MapViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    var viewModel: MapLakesViewModel!
    
    func bindViewModel(){
        if let viewModel = viewModel, let viewMap = view as? GMSMapView {
            
            let viewDidLoad = rx.sentMessage(#selector(UIViewController.viewWillAppear(_:))).map{ _ in }.asDriver(onErrorJustReturn: ())
            let tapMarker = viewMap.rx.didTapInfoWindowOf.asDriver()
            
            let input = MapLakesViewModel.Input(recieveLakes: viewDidLoad, openDataFromMap: tapMarker)
            
            let output = viewModel.perform(input: input)
            
            let recievedLakes = output.recievedLakes.drive(onNext: { (marker) in
                viewMap.clear()
                marker.forEach({ (marker, lake) in
                    marker.map = viewMap
                })
            })
            let fetchError = output.fetchError.drive(rx.featchError)
            
            [recievedLakes, fetchError].forEach{ $0.disposed(by: disposeBag) }
        }
    }
}

private extension Reactive where Base: MapViewController {
    var featchError: Binder<Error> {
        return Binder(base) { vc, error in
            let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString(error.localizedDescription, comment: ""), preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "Ok", style: .default) { (alertAction) in
                alert.dismiss(animated: true, completion: nil)
            }
            alert.addAction(alertAction)
            vc.present(alert, animated: true, completion: nil)
        }
    }
}
