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
    
    /// Call to update current language. Causes reload of the repositories.
    let setCurrentLanguage: AnyObserver<String>
    
    /// Call to show language list screen.
    let chooseLanguage: AnyObserver<Void>
    
    /// Call to open repository page.
    let selectRepository: AnyObserver<UserViewModel>
    
    /// Call to reload repositories.
    let reload: AnyObserver<Void>
    
    // MARK: - Outputs
    
    /// Emits a formatted title for a navigation item.
    let title: Observable<String>
    
    /// Emits an error messages to be shown.
    let alertMessage: Observable<String>
    
    /// Emits an url of repository page to be shown.
    let showUser: Observable<URL>
    
    /// Emits when we should show language list.
    let showLanguageList: Observable<Void>
    
    /// Indicates if more data is available
    let loadNextPageTrigger = PublishRelay<Void>()
    
    /// Emits an array of fetched users
    let users = BehaviorRelay<[User]>(value: [])
    
    let isLoading = BehaviorRelay<Bool>(value: false)
    let error = PublishSubject<Error>()
    
    private let disposeBag = DisposeBag()
    private var pageSize = 20
    let hasMoreData = BehaviorRelay<Bool>(value: true)
    
    
    init(initialLanguage: String, githubService: GithubService = GithubService()) {
        
        let _reload = PublishSubject<Void>()
        self.reload = _reload.asObserver()
        
        let _currentLanguage = BehaviorSubject<String>(value: initialLanguage)
        self.setCurrentLanguage = _currentLanguage.asObserver()
        
        self.title = _currentLanguage.asObservable()
            .map { "\($0)" }
        
        let _alertMessage = PublishSubject<String>()
        self.alertMessage = _alertMessage.asObservable()
        
        
        let _selectRepository = PublishSubject<UserViewModel>()
        self.selectRepository = _selectRepository.asObserver()
        self.showUser = _selectRepository.asObservable()
            .map { URL(string: $0.user.url)! }
        
        let _chooseLanguage = PublishSubject<Void>()
        self.chooseLanguage = _chooseLanguage.asObserver()
        self.showLanguageList = _chooseLanguage.asObservable()
        
        
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
