//
//  MapInteractor.swift
//  lakes
//
//  Created by Vadim K on 12.09.2018.
//  Copyright © 2018 Vadim K. All rights reserved.
//

import RxSwift

protocol MapInteractorProtocol: class {
    func fetchAll()->Observable<[Lake]>
}

final class MapInteractor: MapInteractorProtocol {
    
    private var mRepository: LakesRepositoryProtocol
    
    init(repository: LakesRepositoryProtocol) {
        self.mRepository = repository
    }
    
    func fetchAll() -> Observable<[Lake]> {
        return mRepository.fetchAll()
    }
    
}
