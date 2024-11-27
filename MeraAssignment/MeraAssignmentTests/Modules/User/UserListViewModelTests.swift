//
//  UserListViewModelTests.swift
//  MeraAssignment
//
//  Created by NhatMinh on 27/11/24.
//

import XCTest
import RxSwift
import RxCocoa

@testable import MeraAssignment

class UserListViewModelTests: XCTestCase {
    var viewModel: UserListViewModel!
    var mockGithubService: MockGithubService!
    var disposeBag: DisposeBag!

    override func setUp() {
        super.setUp()
        disposeBag = DisposeBag()

        // Initialize mock service with test data
        mockGithubService = MockGithubService()
        mockGithubService.mockGithubUsers = [
            MeraAssignment.User(login: "octocat", id: 1, location: "SF", followers: 1000, following: 10, nodeID: "node123", avatarURL: "avatar", gravatarID: "", url: "", htmlURL: "", followersURL: "", followingURL: "", gistsURL: "", starredURL: "", subscriptionsURL: "", organizationsURL: "", reposURL: "", eventsURL: "", receivedEventsURL: "", type: "User", userViewType: "user", siteAdmin: false, blog: "https://octocat.blog")
        ]
        viewModel = UserListViewModel()
    }

    override func tearDown() {
        viewModel = nil
        mockGithubService = nil
        disposeBag = nil
        super.tearDown()
    }

    // MARK: - Tests

    func testFetchUsersSuccessfully() {
        // Given
        let expectation = XCTestExpectation(description: "Fetch users successfully")
        
        var resultUsers: [User] = []

        // Subscribe to users observable
        viewModel.users
            .skip(1) // Skip the initial empty value
            .subscribe(onNext: { users in
                resultUsers = users
                expectation.fulfill() // Mark expectation as fulfilled when users are emitted
            })
            .disposed(by: disposeBag)
        
        // When
        viewModel.loadNextPageTrigger.accept(())
        
        // Then
        wait(for: [expectation], timeout: 5.0) // Wait for expectations to fulfill
        XCTAssertEqual(resultUsers.count, 1) // Assert expected user count
        XCTAssertEqual(resultUsers.first?.login, "octocat") // Assert user details
    }

    func testFetchUsersWithError() {
        // Given
        let expectation = XCTestExpectation(description: "Fetch users with error")
        mockGithubService.shouldReturnError = true
        
        var resultError: Error?

        // Subscribe to the error observable
        viewModel.error
            .subscribe(onNext: { error in
                resultError = error
                expectation.fulfill() // Mark expectation as fulfilled when error occurs
            })
            .disposed(by: disposeBag)
        
        // When
        viewModel.loadNextPageTrigger.accept(())
        
        // Then
        wait(for: [expectation], timeout: 5.0) // Wait for expectations to fulfill
        XCTAssertNotNil(resultError) // Assert error was received
        XCTAssertTrue(resultError is ServiceError) // Assert specific error type
    }

    func testRefreshUsers() {
        // Given
        let expectation = XCTestExpectation(description: "Refresh users successfully")

        var resultUsers: [User] = []

        // Subscribe to users observable
        viewModel.users
            .skip(1) // Skip the initial empty value
            .subscribe(onNext: { users in
                resultUsers = users
                expectation.fulfill() // Mark expectation as fulfilled when users are emitted
            })
            .disposed(by: disposeBag)
        
        // When
        viewModel.refreshTrigger.accept(())
        
        // Then
        wait(for: [expectation], timeout: 5.0) // Wait for expectations to fulfill
        XCTAssertEqual(resultUsers.count, 1) // Assert expected user count
        XCTAssertEqual(resultUsers.first?.login, "octocat") // Assert user details
    }

    func testNoMoreUsersToLoad() {
        // Given
        mockGithubService.mockGithubUsers = [] // Simulate no more users
        let expectation = XCTestExpectation(description: "No more users to load")

        viewModel.hasMoreData
            .skip(1) // Skip initial value
            .subscribe(onNext: { hasMoreData in
                XCTAssertFalse(hasMoreData) // Assert hasMoreData becomes false
                expectation.fulfill()
            })
            .disposed(by: disposeBag)

        // When
        viewModel.loadNextPageTrigger.accept(())

        // Then
        wait(for: [expectation], timeout: 5.0)
    }
}
