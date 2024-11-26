//
//  UserDetailViewModel.swift
//  MeraAssignment
//
//  Created by NhatMinh on 25/11/24.
//

import RxRelay
import RxCocoa
import RxSwift


class UserDetailViewModel {
    
    // Dependencies
    private let githubService: GithubService
    private let disposeBag = DisposeBag()
    
    // Input
    let user: BehaviorRelay<User>
    let loadUserDetailTrigger = PublishRelay<Void>()
    
    // Outputs
    let userDetail: BehaviorRelay<User?> = BehaviorRelay(value: nil)
    let isLoading = BehaviorRelay<Bool>(value: false)
    let error = PublishSubject<Error>()
    
    init(user: User) {
        self.user = BehaviorRelay(value: user)
        self.githubService = GithubService()
        
        // Fetch user details when triggered
        loadUserDetailTrigger
            .withLatestFrom(self.user.map { $0.login }) // Get username from user object
            .filter { !$0.isEmpty } // Ignore empty usernames
            .flatMapLatest { [unowned self] username in
                self.isLoading.accept(true) // Start loading
                return self.githubService.getUserDetail(username: username) // Fetch user details
                    .catch { error in
                        self.error.onNext(error) // Emit error
                        return Observable.empty() // Return empty observable in case of error
                    }
                    .do(onDispose: { self.isLoading.accept(false) }) // Stop loading after the observable completes
            }
            .subscribe(onNext: { [weak self] user in
                self?.userDetail.accept(user) // Update userDetail with fetched user
            })
            .disposed(by: disposeBag)
    }
}
