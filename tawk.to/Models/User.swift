//
//  User.swift
//  tawk.to
//
//  Created by Dominic Valencia on 12/3/20.
//  Copyright © 2020 Dominic Valencia. All rights reserved.
//

import Foundation
import CoreData

protocol UserProtocol {
    func getUser(id: Int) -> CDUser?
}

struct User: Codable {
    let login: String
    let id: Int
    let avatar_url: String
    let url: String
}

struct UserDetails: Codable {
    let login: String
    let id: Int
    let avatar_url: String
    let url: String
    let followers: Int
    let following: Int
    let company: String?
    let blog: String?
}

@objc(CDUser)
class CDUser: NSManagedObject {
    @NSManaged var login: String
    @NSManaged var id: Int
    @NSManaged var avatar_url: String
    @NSManaged var url: String
    @NSManaged var notes: String
    @NSManaged var followers: Int
    @NSManaged var following: Int
    @NSManaged var company: String
    @NSManaged var blog: String
    @NSManaged var seen: Bool
    
    func update(with user: User) throws {
        self.login = user.login
        self.id = user.id
        self.avatar_url = user.avatar_url
        self.url = user.url
    }
    
    func updateNotes(with notes: String) throws {
        self.notes = notes

    }
    
    func setSeen() throws {
        self.seen = true
    }
    
    func toUser() -> User {
        return User(login: self.login, id: self.id, avatar_url: self.avatar_url, url: self.url)
    }
    
    func toUserWithDetails() -> UserDetails {
        return UserDetails(login: self.login, id: self.id, avatar_url: self.avatar_url, url: self.url, followers: self.followers, following: self.following, company: self.company, blog: self.blog)
    }
    
}
