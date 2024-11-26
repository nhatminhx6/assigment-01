//
//  UserDetailViewController.swift
//  MeraAssignment
//
//  Created by NhatMinh on 25/11/24.
//

import UIKit
import RxSwift

class UserDetailViewController: UIViewController, StoryboardInitializable {
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    var viewModel: UserDetailViewModel! // viewModel be init in Coordinator
    private let disposeBag = DisposeBag()
    
    
    /// User Info Outlets
    
    @IBOutlet weak var userInfoView: UIView!
    @IBOutlet weak var avaterContainerView: UIView!
    @IBOutlet weak var avaterWrapperView: UIView!
    @IBOutlet weak var avatarImge: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    /// Followers Outlets
    @IBOutlet weak var followerWrapperIcon: UIView!
    @IBOutlet weak var followerCountingLabel: UILabel!
   
    /// Following Outlets
    @IBOutlet weak var followingWrapperIcon: UIView!
    @IBOutlet weak var followingCountingLabel: UILabel!
    
    
    /// Other Outlets
    @IBOutlet weak var blogValueLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // Call method to bind the outputs
        bindViewModel()
        // Trigger fetching the user detail when the view loads
        viewModel.loadUserDetailTrigger.accept(())
        
    }
    
    private func setupUI(){
        self.title =  "User Detail"
        userInfoView.addBottomShadow()
        userInfoView.layer.cornerRadius =  8
        avaterContainerView.layer.cornerRadius =  8
        avaterWrapperView.layer.cornerRadius =  56
        avatarImge.layer.cornerRadius =  56
        followerWrapperIcon.layer.cornerRadius = 30
        followingWrapperIcon.layer.cornerRadius = 30
        
    }
    
    private func bindViewModel() {
        // Binding user details to labels
        viewModel.userDetail
            .subscribe(onNext: { [weak self] user in
                self?.nameLabel.text = user?.login ?? ""
            })
            .disposed(by: disposeBag)
        
        // Binding isLoading to show/hide the loading indicator
        viewModel.isLoading
            .observe(on: MainScheduler.instance) // Ensure UI updates on main thread
            .subscribe(onNext: { [weak self] isLoading in
                if isLoading {
                    self?.loadingIndicator.startAnimating()
                } else {
                    self?.loadingIndicator.stopAnimating()
                }
            })
            .disposed(by: disposeBag)
        
        // Binding error (you can display it in an alert or label)
        viewModel.error
            .observe(on: MainScheduler.instance) // Ensure UI updates on main thread
            .subscribe(onNext: { [weak self] error in
                self?.showError(error) // Handle error (e.g., show an alert)
            })
            .disposed(by: disposeBag)
    }
    
    private func showError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    private func bindViewModel2() {
        bindLabel(nameLabel, to: viewModel.user.map { $0.login })
        bindUserDetail()
        //bindLabel(idLabel, to: viewModel.repository.map { "ID: \($0.id)" })
        //bindLabel(urlLabel, to: viewModel.repository.map { "URL: \($0.html_url)" })
    }
    
    private func bindLabel(_ label: UILabel, to observable: Observable<String>) {
        observable
            .bind(to: label.rx.text)
            .disposed(by: disposeBag)
    }
    
    
    
    // MARK: - Binding Methods
    
    
    // Binding User Details
 
    private func bindUserDetail() {
        viewModel.userDetail
            .subscribe(onNext: { [weak self] user in
                // Update the UI elements with user details
                self?.nameLabel.text = user?.login
                // Update other UI elements
            })
            .disposed(by: disposeBag)
    }
    
   
}
