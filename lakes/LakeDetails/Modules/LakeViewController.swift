//
//  LakeViewController.swift
//  lakes
//
//  Created by Vadim K on 12.09.2018.
//  Copyright © 2018 Vadim K. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class LakeViewController: UIViewController {
    
    @IBOutlet weak var imageActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var titleLake: UILabel!
    @IBOutlet weak var descriptionLake: UILabel!
    
    private let disposeBag = DisposeBag()
    var viewModel: LakeDetailsViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
    }
    
    func bindViewModel(){
        if let viewModel = viewModel {
            let viewWillAppear = rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
                .mapToVoid()
                .asDriver(onErrorJustReturn: ())
            
            let output = viewModel.perform(input: ())
            
            let showIndicator = viewWillAppear.drive(rx.showActivityIndicator)
            let hideIndicator = Driver.merge(
                output.recievedLake.mapToVoid(),
                output.fetchError.mapToVoid()
                )
                .drive(rx.hideActivityIndicator)
            
            let recievedTitleLake = output.recievedLake
                .map { $0.getTitle() }
                .drive(titleLake.rx.text)
            
            let recievedDescriptionLake = output.recievedLake
                .map { $0.getDescription() }
                .drive(descriptionLake.rx.text)
            
            let fetchError = output.fetchError
                .map { $0.localizedDescription }
                .drive(rx.showError)
            
            let imageActivityIndicatorStop = output.recievedImage
                .map { _ in return false }
                .drive(imageActivityIndicator.rx.isAnimating)
            
            let recievedImage = output.recievedImage
                .map { $0?.resizeImage(newWidth: self.view.bounds.width) }
                .drive(photo.rx.image)
            
            [recievedTitleLake,
             recievedDescriptionLake,
             imageActivityIndicatorStop,
             recievedImage,
             fetchError,
             showIndicator,
             hideIndicator
                ].forEach { $0.disposed(by: disposeBag) }
            
        }
    }
    
}

private extension Reactive where Base: LakeViewController {
    var showActivityIndicator: Binder<Void> {
        return Binder(base) { vc, _ in
            let alert = UIAlertController(
                title: nil,
                message: NSLocalizedString("Loading data...", comment: ""),
                preferredStyle: .alert
            )
            
            alert.view.tintColor = UIColor.black
            let loadingIndicator = UIActivityIndicatorView(
                frame: CGRect(x: 10, y: 5, width: 50, height: 50)
                ) as UIActivityIndicatorView
            
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.activityIndicatorViewStyle = .gray
            loadingIndicator.startAnimating()
            
            alert.view.addSubview(loadingIndicator)
            vc.navigationController?.present(alert, animated: false, completion: nil)
        }
    }
    
    var hideActivityIndicator: Binder<Void> {
        return Binder(base) { vc, _ in
            vc.dismiss(animated: true, completion: nil)
        }
    }
    
    var showError: Binder<String> {
        return Binder(base) { vc, error in
            let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString(error, comment: ""), preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "Ok", style: .default) { (alertAction) in
                alert.dismiss(animated: true, completion: nil)
            }
            alert.addAction(alertAction)
            vc.present(alert, animated: true, completion: nil)
        }
    }
}


