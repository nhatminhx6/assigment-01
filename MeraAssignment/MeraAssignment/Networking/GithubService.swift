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
    
    /// - Parameter language: Language to filter by
    /// - Returns: A list of most popular repositories filtered by langugage
    
    func getMostPopularRepositories(perPage page: Int) -> Observable<[User]> {
        
        let url = URL(string: "https://api.github.com/users?per_page=\(page)&since=100")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
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
    
    
    
}
