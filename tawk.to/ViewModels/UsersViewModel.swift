//
//  UsersViewModel.swift
//  tawk.to
//
//  Created by Dominic Valencia on 12/3/20.
//  Copyright © 2020 Dominic Valencia. All rights reserved.
//

import Foundation
import CoreData

protocol  UsersViewModelCoordinatorDelegate: class {
    func toProfileView(user: User)
}

enum UsersViewModelResult {
    case loadUsers
}

class UsersViewModel: BaseViewModel {
    
    var changeResult: ((UsersViewModelResult) -> ())?
    var coordinatorDelegate: UsersViewModelCoordinatorDelegate?
    var users: [User] = []
    var user: User?
    var since = 0
    var isFetching = false
    var failedFetch = false
    
    override init(persistentContainer: NSPersistentContainer) {
        super.init(persistentContainer: persistentContainer)
    }
    
    func fetchUsers(_ showLoader: Bool = true) {
        
        if isFetching {
            return
        }
        
        isFetching = true
        
        guard let rest = REST.make(urlString: "\(baseURL)users?since=\(since)") else {
            print("Bad URL")
            return
        }
        
        if showLoader {
            self.showActivity()
        }
    
        rest.get([User].self) { result, httpResponse in
            self.isFetching = false
            if showLoader {
                self.stopActivity()
            }
            
            do {
                let users = try result.value()
                if let last = self.users.last {
                    self.since = last.id
                }
                self.users.append(contentsOf: users)
                self.syncUsers(users: users)
                
                self.failedFetch = false
                self.changeResult?(.loadUsers)
                
            } catch {
                print("Error performing GET: \(error)")
                self.failedFetch = true
            }
        }
    }
    
    func searchUser(by keyword: String) {
        self.searchUser(keyword: keyword, taskContext: self.persistentContainer.viewContext) { (users) in
            self.users = users ?? []
            self.changeResult?(.loadUsers)
        }
    }

}

extension UsersViewModel: UserProtocol {
    func getUser(id: Int) -> CDUser? {
        return self.getUser(id, taskContext: self.getTaskContext())
    }
}
