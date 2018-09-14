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

extension UIImage {
    func resizeImage(newWidth: CGFloat) -> UIImage {
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}
