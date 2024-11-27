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
                // Check if there is already data in Realm
                if let persistedUsers = self.loadPersistedUsers(), !persistedUsers.isEmpty {
                    // If data exists, emit from Realm
                    self.users.accept(persistedUsers)
                    self.refreshCompleted.onNext(true)  // Emit successful refresh
                    return Observable.empty()  // No need to fetch from API
                } else {
                    // If no data in Realm, fetch from API
                    return self.githubService.getGithubUsers(perPage: self.pageSize)
                }
            }
            .subscribe(onNext: { [weak self] newUsers in
                guard let self = self else { return }
                self.isLoading.accept(false)  // Hide loading indicator
                if !newUsers.isEmpty {
                    self.users.accept(newUsers)  // Replace old data with new data
                    self.pageSize = 20  // Reset page size for pagination
                    self.saveUsersToRealm(newUsers)  // Save new users to Realm
                    self.refreshCompleted.onNext(true)  // Emit successful refresh
                }
            }, onError: { [weak self] error in
                self?.isLoading.accept(false)  // Hide loading indicator
                self?.refreshCompleted.onNext(false)  // Notify failure
                self?.error.onNext(error)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Realm Integration
    /// Load persisted users from Realm
    private func loadPersistedUsers() -> [User]? {
        let realmUsers = realm.objects(RealmUser.self)
        let persistedUsers = realmUsers.map { $0.toUser() } // Convert RealmUser to User
        return Array(persistedUsers) // Return an array of User
    }
    
    /// Save users to Realm
    private func saveUsersToRealm(_ newUsers: [User]) {
        let realmUsers = newUsers.map { RealmUser(from: $0) }
        do {
            try realm.write {
                realm.add(realmUsers, update: .modified)
            }
        } catch {
            print("Error saving users to Realm: \(error)")
        }
    }
}
