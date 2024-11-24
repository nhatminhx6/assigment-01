//
//  UserDetailViewController.swift
//  MeraAssignment
//
//  Created by NhatMinh on 25/11/24.
//

import UIKit
import RxSwift

class UserDetailViewController: UIViewController, StoryboardInitializable {
    
    @IBOutlet weak var nameLabel: UILabel!
    var viewModel: UserDetailViewModel!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }
    
    private func setupUI(){
        self.navigationController?.navigationBar.backItem?.title = " "
        self.title =  "User Detail"

    }

    
    private func bindViewModel() {
        bindLabel(nameLabel, to: viewModel.user.map { $0.login })
        //bindLabel(idLabel, to: viewModel.repository.map { "ID: \($0.id)" })
        //bindLabel(urlLabel, to: viewModel.repository.map { "URL: \($0.html_url)" })
    }
    
    private func bindLabel(_ label: UILabel, to observable: Observable<String>) {
        observable
            .bind(to: label.rx.text)
            .disposed(by: disposeBag)
    }
    
}
