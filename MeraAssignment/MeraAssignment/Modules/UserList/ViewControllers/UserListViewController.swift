//
//  RepositoryListViewController.swift
//  MeraAssignment
//
//  Created by NhatMinh on 23/11/24.
//

import UIKit
import RxSwift
import RxCocoa

class UserListViewController: UIViewController, StoryboardInitializable {
    
    // MARK: - UI Components
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var loadingIndicator: UIActivityIndicatorView!
    private let refreshControl = UIRefreshControl()
    
    // MARK: - Properties
    var viewModel: UserListViewModel!
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupBindings()
        
        // Trigger initial load
        refreshControl.sendActions(for: .valueChanged)
        viewModel.loadNextPageTrigger.accept(()) // Initial load
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        title = "GitHub Users"
    }
    
    private func setupTableView() {
        tableView.register(UINib(nibName: "RepositoryCell", bundle: nil), forCellReuseIdentifier: "RepositoryCell")
        tableView.addSubview(refreshControl) // Add pull-to-refresh
        
        // Pagination trigger when near bottom
        tableView.rx.contentOffset
            .filter { [weak self] offset in
                guard let self = self else { return false }
                let contentHeight = self.tableView.contentSize.height
                let frameHeight = self.tableView.frame.size.height
                let offsetY = offset.y
                return offsetY > contentHeight - frameHeight - 100 // Trigger near bottom
            }
            .map { _ in }
            .bind(to: viewModel.loadNextPageTrigger)
            .disposed(by: disposeBag)
        
        // Refresh control trigger
        refreshControl.rx.controlEvent(.valueChanged)
            .bind { [weak self] in
                self?.viewModel.refreshTrigger.accept(()) // Trigger refresh
            }
            .disposed(by: disposeBag)
    }
    
    private func setupBindings() {
        // Bind users to tableView
        viewModel.users
            .bind(to: tableView.rx.items(cellIdentifier: "RepositoryCell", cellType: RepositoryCell.self)) { [weak self] _, user, cell in
                self?.setupRepositoryCell(cell, userModel: user)
            }
            .disposed(by: disposeBag)
        
        // Bind loading state to activity indicator
        viewModel.isLoading
            .observe(on: MainScheduler.instance)
            .bind(to: loadingIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        // Stop refresh control on data load or error
        Observable.merge(viewModel.users.map { _ in }, viewModel.error.map { _ in })
            .subscribe(onNext: { [weak self] _ in
                self?.refreshControl.endRefreshing() // Stop refresh control
            })
            .disposed(by: disposeBag)
        
        // Handle errors
        viewModel.error
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] error in
                self?.presentAlert(message: error.localizedDescription)
            })
            .disposed(by: disposeBag)
        
        // Handle item selection
        tableView.rx.modelSelected(User.self)
            .bind(to: viewModel.selectedUser)
            .disposed(by: disposeBag)
        
        // Handle refresh completion
        viewModel.refreshCompleted
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] success in
                self?.refreshControl.endRefreshing() // Stop the refresh control
                if !success {
                    self?.presentAlert(message: "Failed to refresh data. Please try again.")
                }
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Helper Methods
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
