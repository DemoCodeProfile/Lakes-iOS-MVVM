//
//  ImageLoadingService.swift
//  lakes
//
//  Created by Vadim K on 12.09.2018.
//  Copyright © 2018 Vadim K. All rights reserved.
//

import UIKit
import SDWebImage
import RxSwift


protocol ImageLoadingServiceProtocol: class {
    func loadImage(_ url: URL)->Observable<UIImage?>
}

class ImageLoadingService: ImageLoadingServiceProtocol {
    
    func loadImage(_ url: URL)->Observable<UIImage?> {
        return Observable<UIImage?>.create { (observer) -> Disposable in
            SDWebImageManager.shared().loadImage(with: url, options: .cacheMemoryOnly, progress: nil) { (image, data, error, type, finished, url) in
                observer.onNext(image)
                observer.onCompleted()
            }
            return Disposables.create()
            }.subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
    }
}

