//
//  MapRouter.swift
//  lakes
//
//  Created by Vadim K on 12.09.2018.
//  Copyright © 2018 Vadim K. All rights reserved.
//

import UIKit

protocol MapWireframeProtocol {
    func toLakeDetails(_ lake: Lake)
}

final class MapRouter: MapWireframeProtocol {
    
    var viewController: MapViewController
    
    init(viewController: MapViewController) {
        self.viewController = viewController
    }
    
    func toLakeDetails(_ lake: Lake) {
        if let vc = UIStoryboard.init(name: STORYBOARD_NAME, bundle: nil).instantiateViewController(withIdentifier: LAKE_VIEW_CONTROLLER_ID) as? LakeViewController {
            vc.viewModel.setCurrentLake(lake)
            vc.title = lake.getTitle()
            viewController.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}
