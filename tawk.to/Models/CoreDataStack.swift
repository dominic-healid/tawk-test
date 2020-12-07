//
//  CoreDataStack.swift
//  tawk.to
//
//  Created by Dominic Valencia on 12/4/20.
//  Copyright © 2020 Dominic Valencia. All rights reserved.
//

import CoreData

class CoreDataStack {
    
    private init() {}
    static let shared = CoreDataStack()
    
    lazy var persistentContainer: NSPersistentContainer = {
       let container = NSPersistentContainer(name: "tawk_to")
        
        container.loadPersistentStores(completionHandler: { (_, error) in
            guard let error = error as NSError? else { return }
            fatalError("Unresolved error: \(error), \(error.userInfo)")
        })
        
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.undoManager = nil
        container.viewContext.shouldDeleteInaccessibleFaults = true
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        return container
    }()
    
}
