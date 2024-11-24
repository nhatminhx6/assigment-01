//
//  RepositoryListViewController.swift
//  MeraAssignment
//
//  Created by NhatMinh on 23/11/24.
//

import UIKit
import RxSwift
import RxCocoa
import SafariServices

/// Shows a list of most starred repositories filtered by language.
class UserListViewController: UIViewController, StoryboardInitializable {
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    private let chooseLanguageButton = UIBarButtonItem(barButtonSystemItem: .organize, target: nil, action: nil)
    private let refreshControl = UIRefreshControl()
    
    
    var viewModel: UserListViewModel!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTableView()
        setupBindings()
        refreshControl.sendActions(for: .valueChanged)
        viewModel.loadNextPageTrigger.accept(()) // Initial load
    }
    
    private func setupUI() {
        navigationItem.rightBarButtonItem = chooseLanguageButton
        
    }
    
    private func setupTableView() {
        //tableView.insertSubview(refreshControl, at: 0)
        tableView.register(UINib(nibName: "RepositoryCell", bundle: nil), forCellReuseIdentifier: "RepositoryCell")
        tableView.rx.contentOffset
            .filter { [weak self] offset in
                guard let self = self else { return false }
                let contentHeight = self.tableView.contentSize.height
                let frameHeight = self.tableView.frame.size.height
                let offsetY = offset.y
                return offsetY > contentHeight - frameHeight - 100 // Trigger near bottom
            }
            .map { _ in true }
            .bind(to: viewModel.loadNextPageTrigger)
            .disposed(by: disposeBag)
    }
    
    
    
    private func setupBindings() {
        
        viewModel.title
            .bind(to: navigationItem.rx.title)
            .disposed(by: disposeBag)
        
        viewModel.alertMessage
            .subscribe(onNext: { [weak self] in self?.presentAlert(message: $0) })
            .disposed(by: disposeBag)
        
        // View Controller UI actions to the View Model
        
        refreshControl.rx.controlEvent(.valueChanged)
            .bind(to: viewModel.reload)
            .disposed(by: disposeBag)
        
        chooseLanguageButton.rx.tap
            .bind(to: viewModel.chooseLanguage)
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(UserViewModel.self)
            .bind(to: viewModel.selectRepository)
            .disposed(by: disposeBag)
        
        
        viewModel.users
            .bind(to: tableView.rx.items(cellIdentifier: "RepositoryCell", cellType: RepositoryCell.self)) { [weak self] _, user, cell in
                self?.setupRepositoryCell(cell, userModel: user)
            }
            .disposed(by: disposeBag)
        
        // Bind loading state to activity indicator
        viewModel.isLoading
            .bind(to: loadingIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        // Handle errors
        viewModel.error
            .subscribe(onNext: { [weak self] error in
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    private func setupRepositoryCell(_ cell: RepositoryCell, userModel: User) {
        cell.selectionStyle = .none
        cell.apply(userModel)
    }
    
    private func presentAlert(message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true)
    }
}
