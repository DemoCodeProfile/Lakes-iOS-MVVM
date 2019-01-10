//
//  LakeInteractor.swift
//  lakes
//
//  Created by Vadim K on 12.09.2018.
//  Copyright © 2018 Vadim K. All rights reserved.
//

import RxSwift
import Foundation
import UIKit

protocol LakeInteractorProtocol {
    func fetchById()->Observable<Lake>
    func loadImage(_ url: String)->Observable<UIImage?>
    func setSpecification(specification: BaseSpecification)
}

final class LakeInteractor: LakeInteractorProtocol {
    
    private var mSpecification: BaseSpecification?
    private var mRepository: LakesRepositoryProtocol
    private var mImageLoadingService: ImageLoadingServiceProtocol
    
    init(repository: LakesRepositoryProtocol, imageLoadingService: ImageLoadingServiceProtocol) {
        self.mRepository = repository
        self.mImageLoadingService = imageLoadingService
    }
    
    func setSpecification(specification: BaseSpecification){
        self.mSpecification = specification
    }
    
    func fetchById() -> Observable<Lake> {
        return self.mRepository.fetchById(specification: mSpecification)
    }
    
    func loadImage(_ url: String) -> Observable<UIImage?> {
        let url = URL(string: url)!
        return self.mImageLoadingService.loadImage(url)
    }
    
}
