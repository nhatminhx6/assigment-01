//
//  GithubService.swift
//  MeraAssignment
//
//  Created by NhatMinh on 23/11/24.
//

import Foundation
import RxSwift
import RxCocoa

enum ServiceError: Error {
    case cannotParse
    case invalidURL
}

/// A service that knows how to perform requests for GitHub data.
open class GithubService {
    private let session: URLSession

    public init(session: URLSession = URLSession.shared) {
        self.session = session
    }

    /// Fetches users
    /// - Parameter page: Number of users per fetch
    /// - Returns: Observable of `User` array
    func getGithubUsers(perPage page: Int) -> Observable<[User]> {
        guard let url = URL(string: "https://api.github.com/users?per_page=\(page)&since=100") else {
            return Observable.error(ServiceError.invalidURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json;charset=utf-8", forHTTPHeaderField: "Content-Type")

        return session.rx
            .json(request: request)
            .flatMap { json throws -> Observable<[User]> in
                do {
                    guard let jsonData = try? JSONSerialization.data(withJSONObject: json) else {
                        throw ServiceError.cannotParse
                    }
                    let users = try JSONDecoder().decode([User].self, from: jsonData)
                    return Observable.just(users)
                } catch {
                    throw error
                }
            }
            .observe(on: MainScheduler.instance)
            .catch { error in
                return Observable.error(error)
            }
    }

    /// Fetches user details
    /// - Parameter username: The username to fetch details for
    /// - Returns: Observable of `User`
    func getUserDetail(username: String) -> Observable<User> {
        guard let url = URL(string: "https://api.github.com/users/\(username)") else {
            return Observable.error(ServiceError.invalidURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json;charset=utf-8", forHTTPHeaderField: "Content-Type")

        return session.rx
            .json(request: request)
            .flatMap { json throws -> Observable<User> in
                do {
                    guard let jsonData = try? JSONSerialization.data(withJSONObject: json) else {
                        throw ServiceError.cannotParse
                    }
                    let user = try JSONDecoder().decode(User.self, from: jsonData)
                    return Observable.just(user)
                } catch {
                    throw error
                }
            }
            .observe(on: MainScheduler.instance)
            .catch { error in
                return Observable.error(error)
            }
    }
}
