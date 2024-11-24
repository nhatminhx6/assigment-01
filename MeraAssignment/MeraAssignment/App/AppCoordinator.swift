//
//  AppCoordinator.swift
//  MeraAssignment
//
//  Created by NhatMinh on 23/11/24.
//

import UIKit
import RxSwift

class AppCoordinator: BaseCoordinator<Void> {

    private let window: UIWindow

    init(window: UIWindow) {
        self.window = window
    }

    override func start() -> Observable<Void> {
        let repositoryListCoordinator = UserListCoordinator(window: window)
        return coordinate(to: repositoryListCoordinator)
    }
}
