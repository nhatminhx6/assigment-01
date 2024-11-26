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
class GithubService {
    
    private let session: URLSession
    
    init(session: URLSession = URLSession.shared) {
        
        self.session = session
    }
    
    /// - Returns: a list of languages from GitHub.
    func getLanguageList() -> Observable<[String]> {
        // For simplicity we will use a stubbed list of languages.
        return Observable.just([
            "Swift",
            "Objective-C",
            "Java",
            "C",
            "C++",
            "Python",
            "C#"
        ])
    }
    
    /// Fetches user details by username
    /// - Parameter page:  to how many user per fetch
    /// - Returns: List `User`
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
                        throw ServiceError.cannotParse // Custom error for serialization issues
                    }
                    let users = try JSONDecoder().decode([User].self, from: jsonData)
                    return Observable.just(users)
                } catch {
                    print("Parsing error: \(error)") // Log the error for debugging
                    throw error // Propagate the error to be handled by `catchError`
                }
            }
            .observe(on: MainScheduler.instance) // Ensure results are observed on the main thread
            .catch { error in
                print("Error encountered: \(error)")
                // Return an empty array or any fallback value
                return Observable.just([])
            }
    }
    
    
    /// Fetches user details by username
    /// - Parameter username: The username to fetch details for
    /// - Returns: Single `User`
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
                        throw ServiceError.cannotParse // Custom error for serialization issues
                    }
                    let user = try JSONDecoder().decode(User.self, from: jsonData)
                    return Observable.just(user)
                } catch {
                    print("Parsing error: \(error)") // Log the error for debugging
                    throw error // Propagate the error to be handled by `catchError`
                }
            }
            .observe(on: MainScheduler.instance) // Ensure results are observed on the main thread
            .catch { error in
                print("Error encountered: \(error)")
                // Return an empty fallback value if necessary
                return Observable.error(error)
            }
    }


   
    
    
    
}
