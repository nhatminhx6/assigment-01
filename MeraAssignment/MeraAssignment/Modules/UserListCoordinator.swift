//
//  RepositoryListCoordinator.swift
//  MeraAssignment
//
//  Created by NhatMinh on 23/11/24.
//

import UIKit
import RxSwift

class UserListCoordinator: BaseCoordinator<Void> {
    
    private let window: UIWindow
    private var root: UINavigationController!
    
    init(window: UIWindow) {
        self.window = window
        self.root = nil
    }
    
    override func start() -> Observable<Void> {
        let viewModel = UserListViewModel()
        let viewController = UserListViewController.initFromStoryboard(name: "User")
        //let navigationController = UINavigationController(rootViewController: viewController)
        let navigationController = BaseNavigationController(rootViewController: viewController)
        self.root = navigationController
        viewController.viewModel = viewModel
        
        // Handle navigation to the detail screen
        viewModel.selectedUser
            .subscribe(onNext: { [weak self] user in
                self?.navigateToDetailScreen(with: user)
            })
            .disposed(by: viewModel.disposeBag)
        
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        return Observable.never()
    }
    
    func navigateToDetailScreen(with user: User) {
        let viewModel = UserDetailViewModel(user: user)
        let detailViewController = UserDetailViewController.initFromStoryboard(name: "User")
        detailViewController.viewModel = viewModel
        root?.pushViewController(detailViewController, animated: true)
    }
    
}
