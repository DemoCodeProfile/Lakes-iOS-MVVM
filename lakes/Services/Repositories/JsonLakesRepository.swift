//
//  JsonLakesRepository.swift
//  lakes
//
//  Created by Vadim K on 12.09.2018.
//  Copyright © 2018 Vadim K. All rights reserved.
//

import Foundation
import RxSwift

enum LakeError: Error {
    case notFound(String), dataError(String)
}

//Or maybe DataManager instead Repository
//Very simple structure repositories & interactors without executors
//protocol LakesRepositoryProtocol {
//    func fetchAll(closure: @escaping (Error?, [Lake]?)->Void)
//    func fetchById(specification: BaseSpecification, closure: @escaping (Error?, Lake?)->Void)
//}

protocol LakesRepositoryProtocol: class {
    func fetchAll()->Observable<[Lake]>
    func fetchById(specification: BaseSpecification?)->Observable<Lake>
}

class JsonLakesRepository: LakesRepositoryProtocol {
    
    var disposable: Disposable
    var jsonParserService: JsonParserServiceProtocol
    
    init(disposable: Disposable, jsonParserService: JsonParserServiceProtocol) {
        self.jsonParserService = jsonParserService
        self.disposable = disposable
    }
    
    func fetchAll()->Observable<[Lake]> {
        return Observable<[Lake]>.create { [unowned self] (lakes) -> Disposable in
            let (error, data) = self.jsonParserService.parseAllLakes(JSON_DATA_FROM_SERVER)
            if let error = error {
                lakes.onError(error)
            } else if let data = data {
                lakes.onNext(data)
            }
            return self.disposable
        }.subscribeOn(ConcurrentDispatchQueueScheduler(qos: .userInteractive))
    }
    
    func fetchById(specification: BaseSpecification?) -> Observable<Lake> {
        return Observable<Lake>.create({[unowned self] (lake) -> Disposable in
            if let specification = specification as? JsonSpecifiaction {
                let id = specification.toJsonQuery()
                let (error, lakes) = self.jsonParserService.parseAllLakes(JSON_DATA_FROM_SERVER)
                if let error = error {
                    lake.onError(error)
                }
                if let lakes = lakes, id != 0 {
                    for l in lakes {
                        if l.getId() == id {
                            lake.onNext(l)
                            break
                        }
                    }
                } else {
                    lake.onError(LakeError.notFound(NSLocalizedString("Not found", comment: "")))
                }
            } else {
                lake.onError(LakeError.dataError(NSLocalizedString("Error id data", comment: "")))
            }
            return self.disposable
        }).subscribeOn(ConcurrentDispatchQueueScheduler(qos: .userInteractive))
    }
    
    
//    func fetchAll(closure: @escaping (Error?, [Lake]?) -> Void) {
//        let queue = DispatchQueue(label: "fetchAll", attributes: .concurrent)
//        queue.async {
//            let (error, lakes) = self.jsonParserService.parseAllLakes(JSON_DATA_FROM_SERVER)
//            DispatchQueue.main.async {
//                closure(error, lakes)
//            }
//        }
//    }
//
//    func fetchById(specification: BaseSpecification, closure: @escaping (Error?, Lake?) -> Void) {
//        let queue = DispatchQueue(label: "fetchById", attributes: .concurrent)
//        queue.async {
//            if let specification = specification as? JsonSpecifiaction {
//                let id = specification.toJsonQuery()
//                let (error, lakes) = self.jsonParserService.parseAllLakes(JSON_DATA_FROM_SERVER)
//                if let error = error {
//                    DispatchQueue.main.async {
//                        closure(error, nil)
//                    }
//                    return
//                }
//                if let lakes = lakes, id != 0 {
//                    for lake in lakes {
//                        if lake.getId() == id {
//                            DispatchQueue.main.async {
//                                closure(nil, lake)
//                            }
//                            break
//                        }
//                    }
//                } else {
//                    DispatchQueue.main.async {
//                        let error = LakeError.notFound(NSLocalizedString("Not found", comment: ""))
//                        closure(error, nil)
//                    }
//                    return
//                }
//            } else {
//                DispatchQueue.main.async {
//                    let error = LakeError.dataError(NSLocalizedString("Error id data", comment: ""))
//                    closure(error, nil)
//                }
//                return
//            }
//        }
//    }
    
    
    
    
}
