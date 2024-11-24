//
//  BaseNavigationViewController.swift
//  MeraAssignment
//
//  Created by NhatMinh on 25/11/24.
//

import UIKit

class BaseNavigationController: UINavigationController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        delegate = self
        let appearance = UINavigationBarAppearance()
        appearance.setBackIndicatorImage(UIImage(named: "circleArrowLeft"), transitionMaskImage: UIImage(named: "circleArrowLeft"))
        appearance.shadowImage = nil
        appearance.shadowColor = nil
        navigationBar.standardAppearance = appearance
        navigationBar.barStyle = .black
        navigationBar.standardAppearance.backgroundEffect = nil
        navigationBar.tintColor = UIColor.darkGray
        
    }
    
}

extension BaseNavigationController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController,
                              willShow viewController: UIViewController,
                              animated: Bool) {
        viewController.navigationItem.backButtonTitle = ""
    }
}
