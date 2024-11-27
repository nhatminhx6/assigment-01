//
//  UserDetailViewModelTests.swift
//  MeraAssignment
//
//  Created by NhatMinh on 27/11/24.
//

import XCTest
import RxSwift
import RxCocoa

@testable import MeraAssignment

class UserDetailViewModelTests: XCTestCase {
    var viewModel: UserDetailViewModel!
    var mockGithubService: MockGithubService!
    var disposeBag: DisposeBag!

    override func setUp() {
        super.setUp()
        disposeBag = DisposeBag()

        // Initialize a mock user
        let mockUser = MeraAssignment.User(
            login: "octocat",
            id: 1,
            location: nil,
            followers: nil,
            following: nil,
            nodeID: "node123",
            avatarURL: "avatar",
            gravatarID: "",
            url: "",
            htmlURL: "",
            followersURL: "",
            followingURL: "",
            gistsURL: "",
            starredURL: "",
            subscriptionsURL: "",
            organizationsURL: "",
            reposURL: "",
            eventsURL: "",
            receivedEventsURL: "",
            type: "User",
            userViewType: "user",
            siteAdmin: false,
            blog: nil
        )

        // Initialize mock service with test data
        mockGithubService = MockGithubService()
        mockGithubService.mockUserDetail = MeraAssignment.User(
            login: "octocat",
            id: 1,
            location: "San Francisco",
            followers: 1000,
            following: 50,
            nodeID: "node123",
            avatarURL: "avatar",
            gravatarID: "",
            url: "",
            htmlURL: "",
            followersURL: "",
            followingURL: "",
            gistsURL: "",
            starredURL: "",
            subscriptionsURL: "",
            organizationsURL: "",
            reposURL: "",
            eventsURL: "",
            receivedEventsURL: "",
            type: "User",
            userViewType: "user",
            siteAdmin: false,
            blog: "https://blog.octocat.com"
        )

        viewModel = UserDetailViewModel(user: mockUser)
        //viewModel.githubService = mockGithubService // Replace real service with mock
    }

    override func tearDown() {
        viewModel = nil
        mockGithubService = nil
        disposeBag = nil
        super.tearDown()
    }

    // MARK: - Tests

    func testFetchUserDetailSuccessfully() {
        // Given
        let expectation = XCTestExpectation(description: "Fetch user details successfully")

        var resultUser: MeraAssignment.User?

        // Subscribe to the userDetail observable
        viewModel.userDetail
            .skip(1) // Skip the initial nil value
            .subscribe(onNext: { user in
                resultUser = user
                expectation.fulfill()
            })
            .disposed(by: disposeBag)

        // When
        viewModel.loadUserDetailTrigger.accept(())

        // Then
        wait(for: [expectation], timeout: 5.0)
        XCTAssertNotNil(resultUser) // Assert user is not nil
        XCTAssertEqual(resultUser?.login, "octocat") // Assert user details
        XCTAssertEqual(resultUser?.location, "San Francisco")
        XCTAssertEqual(resultUser?.followers, 1000)
        XCTAssertEqual(resultUser?.blog, "https://blog.octocat.com")
    }

    func testFetchUserDetailWithError() {
        // Given
        let expectation = XCTestExpectation(description: "Fetch user details with error")
        mockGithubService.shouldReturnError = true // Force mock service to return an error

        var resultError: Error?

        // Subscribe to the error observable
        viewModel.error
            .subscribe(onNext: { error in
                resultError = error
                expectation.fulfill()
            })
            .disposed(by: disposeBag)

        // When
        viewModel.loadUserDetailTrigger.accept(())

        // Then
        wait(for: [expectation], timeout: 5.0)
        XCTAssertNotNil(resultError) // Assert error was emitted
        XCTAssertTrue(resultError is ServiceError) // Assert specific error type
    }

    func testIsLoadingState() {
        // Given
        let expectation = XCTestExpectation(description: "Loading state is updated")

        var loadingStates: [Bool] = []

        // Subscribe to the isLoading observable
        viewModel.isLoading
            .distinctUntilChanged() // Only observe changes in the loading state
            .subscribe(onNext: { isLoading in
                loadingStates.append(isLoading)
                if loadingStates.count == 2 { // Expect two states: true -> false
                    expectation.fulfill()
                }
            })
            .disposed(by: disposeBag)

        // When
        viewModel.loadUserDetailTrigger.accept(())

        // Then
        wait(for: [expectation], timeout: 5.0)
        XCTAssertEqual(loadingStates, [true, false]) // Assert correct loading state transitions
    }
}
