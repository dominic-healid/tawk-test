//
//  BaseViewModel.swift
//  tawk.to
//
//  Created by Dominic Valencia on 12/3/20.
//  Copyright © 2020 Dominic Valencia. All rights reserved.
//

import Foundation
import SKActivityIndicatorView
import CoreData

protocol ContentActivityProtocol {
    func showActivity()
    func showActivity(with message: String)
    func stopActivity()
}

extension ContentActivityProtocol {
    func showActivity() {
        showActivity(with: "")
    }
    
    func showActivity(with message: String) {
        SKActivityIndicator.show(message, userInteractionStatus: false)
    }
    
    func stopActivity() {
        SKActivityIndicator.dismiss()
    }
}


class BaseViewModel: NSObject, ContentActivityProtocol {
    
    let persistentContainer: NSPersistentContainer
    
    let baseURL = "https://api.github.com/"
    
    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }
    
    func getTaskContext() -> NSManagedObjectContext {
        let taskContext = self.persistentContainer.newBackgroundContext()
        taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        taskContext.undoManager = nil
        
        return taskContext
    }
    
    func getMainContext() -> NSManagedObjectContext {
        return self.persistentContainer.viewContext
    }
    
    func syncUsers(users: [User]) {
        let taskContext = self.getTaskContext()
        let serialQueue = DispatchQueue(label: "cd.serial.queue")
        // Create new records.
        for u in users {
            serialQueue.async {
                guard let user = NSEntityDescription.insertNewObject(forEntityName: "CDUser", into: taskContext) as? CDUser else {
                    print("Error: Failed to create a new CDUser object!")
                    return
                }
                do {
                    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CDUser")
                    fetchRequest.predicate = NSPredicate(format: "id == %d", u.id)

                    if let fetchResults = try taskContext.fetch(fetchRequest) as? [NSManagedObject] {
                        if fetchResults.count != 0{

                            if let managedObject = fetchResults[0] as? CDUser {
                                try managedObject.update(with: u)
                            }
                        } else {
                            try user.update(with: u)
                        }
                    }
                    
                   
                } catch {
                    print("Error: \(error)\nThe user object will be deleted.")
                    taskContext.delete(user)
                }
            }
            
        }
        
        self.save(taskContext: taskContext)
    }
    
    private func save(taskContext: NSManagedObjectContext) {
        // Save all the changes just made and reset the taskContext to free the cache.
        taskContext.perform {
            if taskContext.hasChanges {
                do {
                    try taskContext.save()
                } catch {
                    print("Error: \(error)\nCould not save Core Data context.")
                }
                taskContext.reset() // Reset the context to clean up the cache and low the memory footprint.
            }
        }
        
    }
    
    func searchUser(keyword: String, taskContext: NSManagedObjectContext, completion: @escaping(_ users: [User]?) -> Void) {
        let request = NSFetchRequest<CDUser>(entityName: "CDUser")
        request.predicate = NSPredicate(format: "login contains[c] %@ OR notes contains[c] %@", keyword, keyword)
        request.returnsObjectsAsFaults = false
        do {
            let result = try taskContext.fetch(request)
            var users: [User] = []
            for user in result {
                users.append(user.toUser())
            }
            completion(users)
        } catch {
            print("Failed")
            completion(nil)
        }
    }
    
    func saveUser(id: Int, notes: String, completion: @escaping(_ success: Bool) -> Void) {
        let taskContext = self.getTaskContext()
        do {
            if let user = self.getUser(id, taskContext: taskContext) {
                try user.updateNotes(with: notes)
            }
        } catch {
            print("Error: \(error).")
        }
        
        self.save(taskContext: taskContext)
        completion(true)
    }
    
    func seenUser(id: Int) {
        let taskContext = self.getTaskContext()
        do {
            if let user = self.getUser(id, taskContext: taskContext) {
                try user.setSeen()
            }
        } catch {
            print("Error: \(error).")
        }
        
        self.save(taskContext: taskContext)
    }
    
    func getUser(_ id: Int, taskContext: NSManagedObjectContext?) -> CDUser? {
        do {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CDUser")
            fetchRequest.predicate = NSPredicate(format: "id == %d", id)

            if let fetchResults = try taskContext?.fetch(fetchRequest) as? [NSManagedObject] {
                if fetchResults.count != 0{

                    if let managedObject = fetchResults[0] as? CDUser {
                        return managedObject
                    }
                }
            }
        } catch {
            debugPrint("User not found")
        }
        return nil
    }
    
}


