//
//  ProfileViewModel.swift
//  tawk.to
//
//  Created by Dominic Valencia on 12/5/20.
//  Copyright © 2020 Dominic Valencia. All rights reserved.
//

import Foundation
import CoreData

enum ProfileViewModelResult {
    case loadUserDetails
    case savedNotes
}

class ProfileViewModel: BaseViewModel {
    
    var changeResult: ((ProfileViewModelResult) -> ())?

    var user: User?
    var userDetails: UserDetails?
    
    override init(persistentContainer: NSPersistentContainer) {
        super.init(persistentContainer: persistentContainer)
    }
    
    func fetchUserDetails() {
        guard let rest = REST.make(urlString: "\(baseURL)users/\(String(describing: user!.login))") else {
            print("Bad URL: \(baseURL)users/\(String(describing: user!.login))")
            return
        }
        self.showActivity()
        rest.get(UserDetails.self) { result, httpResponse in
            self.stopActivity()
            do {
                self.userDetails = try result.value()
                self.seenUser(id: self.user!.id)
                self.changeResult?(.loadUserDetails)
                
            } catch {
                print("Error performing GET: \(error)")
            }
        }
    }
    
    func userFollowers() -> NSAttributedString {
        return NSAttributedString(string: "\(String(describing: self.userDetails!.followers))\nfollowers")
    }
    
    func userFollowing() -> NSAttributedString {
        return NSAttributedString(string: "\(String(describing: self.userDetails!.following))\nfollowing")
    }
    
    func saveUser(notes: String) {
        self.saveUser(id: user!.id, notes: notes) { (success) in
            self.changeResult?(.savedNotes)
        }
    }
    
    func getNotes() -> String {
        return self.getUser(user!.id, taskContext: self.getTaskContext())?.notes ?? ""
    }

}
