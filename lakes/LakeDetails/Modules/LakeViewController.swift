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
    
    private var disposeBag = DisposeBag()
    var viewModel: LakeDetailsViewModel!
    
    func bindViewModel(){
        if let viewModel = viewModel {
            let viewWillAppear = rx.sentMessage(#selector(UIViewController.viewWillAppear(_:))).map { _ in }.asDriver(onErrorJustReturn: ())
            
            let didLoad = viewWillAppear.drive(onNext: {[unowned self] _ in
                self.showWaitingView()
            })
            
            let input = LakeDetailsViewModel.Input(recieveLake: viewWillAppear)
            
            let output = viewModel.perform(input: input)
            
            let recievedLake = output.recievedLake.drive(onNext: { [unowned self] (lake) in
                self.hideWaitingView()
                self.titleLake.text = lake.getTitle()
                self.descriptionLake.text = lake.getDescription()
            })
            
            let recievedImage = output.recievedImage.drive(onNext: {[unowned self] (img) in
                self.imageActivityIndicator.stopAnimating()
                self.photo.image = img?.resizeImage(newWidth: self.view.bounds.width)
            })
            
            let fetchError = output.fetchError.drive(onNext: {[unowned self] (error) in
                self.hideWaitingView()
                self.showError(error.localizedDescription)
            })
            
            [recievedLake, recievedImage, fetchError, didLoad].forEach { $0.disposed(by: disposeBag) }
            
        }
    }
    
    func showError(_ message: String){
        let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString(message, comment: ""), preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Ok", style: .default) { (alertAction) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(alertAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func showWaitingView() {
        let alert = UIAlertController(title: nil, message: NSLocalizedString("Loading data...", comment: ""), preferredStyle: .alert)
        
        alert.view.tintColor = UIColor.black
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50)) as UIActivityIndicatorView
        
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = .gray
        loadingIndicator.startAnimating()
        
        alert.view.addSubview(loadingIndicator)
        self.navigationController?.present(alert, animated: false, completion: nil)
    }
    
    func hideWaitingView() {
        self.dismiss(animated: true, completion: nil)
    }
    
}
