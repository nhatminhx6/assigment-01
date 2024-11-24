//
//  RepositoryListViewModel.swift
//  MeraAssignment
//
//  Created by NhatMinh on 23/11/24.
//

import Foundation
import RxSwift
import RxRelay

class UserListViewModel {
    
    // MARK: - Inputs
    let loadNextPageTrigger = PublishRelay<Void>()
    private var pageSize = 20
    
    // MARK: - Outputs
    let users = BehaviorRelay<[User]>(value: [])
    let isLoading = BehaviorRelay<Bool>(value: false)
    let error = PublishSubject<Error>()
    let hasMoreData = BehaviorRelay<Bool>(value: true)
    let selectedUser = PublishRelay<User>()
    
    let disposeBag = DisposeBag()
    
    
    init( githubService: GithubService = GithubService()) {
        
        // Handle pagination
        loadNextPageTrigger
            .withLatestFrom(hasMoreData)
            .filter { _ in !self.isLoading.value } // Prevent multiple simultaneous loads
            .do(onNext: { [weak self] _ in
                self?.isLoading.accept(true) // Show loading indicator
            })
            .flatMapLatest { [unowned self] _ -> Observable<[User]> in
                githubService.getMostPopularRepositories(perPage: self.pageSize)
                    .catch { error in
                        self.error.onNext(error)
                        return Observable.just([])
                    }
            }
            .subscribe(onNext: { [weak self] newUsers in
                guard let self = self else { return }
                self.isLoading.accept(false) // Hide loading indicator
                if newUsers.isEmpty {
                    print("MERALOG ===========    NO MORE DATA TO LOAD ========================  \(pageSize)")
                    self.hasMoreData.accept(false) // No more data to load
                } else {
                    self.users.accept(self.users.value + newUsers)
                    self.pageSize += 20
                    self.isLoading.accept(false)
                }
                
            })
            .disposed(by: disposeBag)
        
       
    }
}
