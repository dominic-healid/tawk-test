//
//  ProfileCoordinator.swift
//  tawk.to
//
//  Created by Dominic Valencia on 12/5/20.
//  Copyright © 2020 Dominic Valencia. All rights reserved.
//

import UIKit

class ProfileCoordinator: Coordinator {

    private let navigationController: UINavigationController?
    private let profileVC = ProfileViewController()
    
    var coreDataStack = CoreDataStack.shared
    var user: User?
    init(navi: UINavigationController?) {
        self.navigationController = navi
    }

    func start() {
        let profileVM = ProfileViewModel(persistentContainer: coreDataStack.persistentContainer)
        profileVM.user = user
        profileVC.viewModel = profileVM
        profileVC.title = user?.login
        navigationController?.pushViewController(profileVC, animated: true)
    }
}
