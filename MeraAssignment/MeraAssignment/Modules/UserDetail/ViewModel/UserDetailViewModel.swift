//
//  UserDetailViewModel.swift
//  MeraAssignment
//
//  Created by NhatMinh on 25/11/24.
//

import RxRelay
import RxCocoa

class UserDetailViewModel {
    // Input
    let user: BehaviorRelay<User>

    init(user: User) {
        self.user = BehaviorRelay(value: user)
    }
}
