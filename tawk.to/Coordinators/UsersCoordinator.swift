//
//  UsersCoordinator.swift
//  tawk.to
//
//  Created by Dominic Valencia on 12/3/20.
//  Copyright © 2020 Dominic Valencia. All rights reserved.
//

//
//  DeliveriesCoordinator.swift
//  DeliveryApp
//
//  Created by Dominic Valencia on 11/29/20.
//  Copyright © 2020 Dominic Valencia. All rights reserved.
//

import UIKit

class UsersCoordinator: Coordinator {

    private let navigationController = UINavigationController()
    private let usersVC = UsersViewController()
    
    var window: UIWindow?
    var coreDataStack = CoreDataStack.shared
    init(window: UIWindow?) {
        self.window = window
    }

    func start() {
        window?.rootViewController = navigationController
        let usersVM = UsersViewModel(persistentContainer: coreDataStack.persistentContainer)
        usersVM.coordinatorDelegate = self
        usersVC.viewModel = usersVM
        usersVC.title = "Users"
        navigationController.pushViewController(usersVC, animated: false)
    }
}

extension UsersCoordinator: UsersViewModelCoordinatorDelegate {
    func toProfileView(user: User) {
        let coordinator = ProfileCoordinator(navi: navigationController)
        coordinator.user = user
        coordinator.start()
    }
}
