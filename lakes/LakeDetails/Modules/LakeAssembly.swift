//
//  LakeAssembly.swift
//  lakes
//
//  Created by Vadim K on 12.09.2018.
//  Copyright © 2018 Vadim K. All rights reserved.
//

import Foundation
import Swinject
import SwinjectStoryboard
import RxSwift

class LakeAssembly: Assembly {
    func assemble(container: Container) {
        container.register(ImageLoadingServiceProtocol.self) { _ in ImageLoadingService() }
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
        container.register(LakeInteractorProtocol.self) { (resolver) -> LakeInteractor in
            let imageLoadingService = resolver.resolve(ImageLoadingServiceProtocol.self)
            let repository = resolver.resolve(LakesRepositoryProtocol.self)
            return LakeInteractor(repository: repository!, imageLoadingService: imageLoadingService!)
        }
        container.register(LakeDetailsViewModel.self) { (resolver) -> LakeDetailsViewModel in
            let interactor = resolver.resolve(LakeInteractorProtocol.self)
            return LakeDetailsViewModel(interactor: interactor!)
        }
        container.storyboardInitCompleted(LakeViewController.self) { (resolver, viewController) in
            viewController.viewModel = resolver.resolve(LakeDetailsViewModel.self)
            viewController.bindViewModel()
        }
    }
}
