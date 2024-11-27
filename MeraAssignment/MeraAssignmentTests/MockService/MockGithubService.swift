//
//  MockGithubService.swift
//  MeraAssignment
//
//  Created by NhatMinh on 27/11/24.
//
import RxSwift
import RealmSwift
import MeraAssignment

class MockGithubService: GithubService {
    var mockGithubUsers: [ MeraAssignment.User] = []
    var mockUserDetail: MeraAssignment.User?
    var shouldReturnError = false
    

    func getGithubUsers(perPage page: Int) -> Observable<[MeraAssignment.User]> {
        if shouldReturnError {
            return Observable.error(ServiceError.invalidURL) // Replace with the desired error
        }
        return Observable.just(mockGithubUsers)
    }

    func getUserDetail(username: String) -> Observable<MeraAssignment.User> {
        if shouldReturnError {
            return Observable.error(ServiceError.cannotParse) // Replace with the desired error
        }
        guard let user = mockUserDetail else {
            return Observable.error(ServiceError.cannotParse) // Simulate missing data
        }
        return Observable.just(user)
    }
}
