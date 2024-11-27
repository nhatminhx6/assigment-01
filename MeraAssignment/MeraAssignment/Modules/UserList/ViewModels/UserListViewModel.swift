//
//  RepositoryListViewModel.swift
//  MeraAssignment
//
//  Created by NhatMinh on 23/11/24.
//

import RxSwift
import RxCocoa
import RealmSwift

class UserListViewModel {
    
    // Dependencies
    private let githubService: GithubService
    private let realm = try! Realm()
    let disposeBag = DisposeBag()
    private var pageSize = 20
    
    // MARK: - Inputs
    let loadNextPageTrigger = PublishRelay<Void>()
    let refreshTrigger = PublishRelay<Void>()
    
    // MARK: - Outputs
    let users = BehaviorRelay<[User]>(value: [])
    let isLoading = BehaviorRelay<Bool>(value: false)
    let error = PublishSubject<Error>()
    let hasMoreData = BehaviorRelay<Bool>(value: true)
    let selectedUser = PublishRelay<User>()
    let refreshCompleted = PublishSubject<Bool>()  // Emits true on successful refresh or false on error
    
    init() {
        self.githubService = GithubService()
        
        // Handle pagination
        loadNextPageTrigger
            .withLatestFrom(hasMoreData)
            .filter { _ in !self.isLoading.value } // Prevent multiple simultaneous loads
            .do(onNext: { [weak self] _ in
                self?.isLoading.accept(true) // Show loading indicator
            })
            .flatMapLatest { [unowned self] _ -> Observable<[User]> in
                githubService.getGithubUsers(perPage: self.pageSize)
                    .catch { error in
                        self.error.onNext(error)
                        return Observable.just([])
                    }
            }
            .subscribe(onNext: { [weak self] newUsers in
                guard let self = self else { return }
                self.isLoading.accept(false) // Hide loading indicator
                if newUsers.isEmpty {
                    self.hasMoreData.accept(false) // No more data to load
                } else {
                    self.users.accept(self.users.value + newUsers)
                    self.pageSize += 20
                }
            })
            .disposed(by: disposeBag)
        
        // Handle refresh logic
        refreshTrigger
            .do(onNext: { [weak self] _ in
                self?.isLoading.accept(true)  // Show loading indicator
            })
            .flatMapLatest { [unowned self] _ -> Observable<[User]> in
                githubService.getGithubUsers(perPage: self.pageSize) // Fetch fresh data
            }
            .subscribe(onNext: { [weak self] newUsers in
                guard let self = self else { return }
                self.isLoading.accept(false)  // Hide loading indicator
                if !newUsers.isEmpty {
                    self.users.accept(newUsers)  // Replace old data with new data
                    self.pageSize = 20  // Reset page size for pagination
                    self.refreshCompleted.onNext(true)  // Notify success
                }
            }, onError: { [weak self] error in
                self?.isLoading.accept(false)  // Hide loading indicator
                self?.refreshCompleted.onNext(false)  // Notify failure
                self?.error.onNext(error)
            })
            .disposed(by: disposeBag)
    }
}
