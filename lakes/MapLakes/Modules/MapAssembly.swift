//
//  MapAssembly.swift
//  lakes
//
//  Created by Vadim K on 12.09.2018.
//  Copyright © 2018 Vadim K. All rights reserved.
//

import Foundation
import Swinject
import GoogleMaps
import RxSwift

final class MapAssembly: Assembly {
    
    func assemble(container: Container) {
        container.register(Disposable.self) { (resolver) -> Disposable in
            return Disposables.create()
        }
        container.register(JsonParserServiceProtocol.self) { (resolver) -> JsonParserService in
            return JsonParserService()
        }
        container.register(LakesRepositoryProtocol.self) { (resolver) -> JsonLakesRepository in
            let jsonParserService = resolver.resolve(JsonParserServiceProtocol.self)
            let disposable = resolver.resolve(Disposable.self)
            return JsonLakesRepository(disposable: disposable!, jsonParserService: jsonParserService!)
        }
        container.register(MapInteractorProtocol.self) { (resolver) -> MapInteractor in
            let repository = resolver.resolve(LakesRepositoryProtocol.self)
            return MapInteractor(repository: repository!)
        }
        
        container.register(MapWireframeProtocol.self) { (resolver, viewController: MapViewController) -> MapRouter in
            return MapRouter(viewController: viewController)
        }
        container.register(MapLakesViewModel.self) { (resolver, viewController: MapViewController) -> MapLakesViewModel in
            let interactor = resolver.resolve(MapInteractorProtocol.self)
            let router = resolver.resolve(MapWireframeProtocol.self, argument: viewController )
            return MapLakesViewModel(interactor: interactor!, router: router!)
        }
        container.storyboardInitCompleted(MapViewController.self) { (resolver, viewController) in
            GMSServices.provideAPIKey(GOOGLE_MAP_API_KEY)
            let camera = GMSCameraPosition.camera(withLatitude: 53.5, longitude: 108.1, zoom: 3.0)
            let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
            viewController.view = mapView
            viewController.viewModel = resolver.resolve(MapLakesViewModel.self, argument: viewController)
            viewController.bindViewModel()
        }
    }
}
