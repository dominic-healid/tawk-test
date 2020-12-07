//
//  tawk_toTests.swift
//  tawk.toTests
//
//  Created by Dominic Valencia on 12/2/20.
//  Copyright © 2020 Dominic Valencia. All rights reserved.
//

import XCTest
@testable import tawk_to

class tawk_toTests: XCTestCase {

    var usersViewModel: UsersViewModel!
    var profileViewModel: ProfileViewModel!
    var expectation: XCTestExpectation!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        super.setUp()
        
        usersViewModel = UsersViewModel(persistentContainer: CoreDataStack.shared.persistentContainer)
        usersViewModel.changeResult = { type in
            switch type {
            case .loadUsers:
                if let expectation = self.expectation {
                    self.expectation.fulfill()
                }
            }
        }
        
        profileViewModel = ProfileViewModel(persistentContainer: CoreDataStack.shared.persistentContainer)
        profileViewModel.changeResult = { type in
            switch type {
            case .loadUserDetails:
                self.expectation.fulfill()
            case .savedNotes:
                self.expectation.fulfill()
            }
        }
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        usersViewModel = nil
        super.tearDown()
    }

    func testFetchUsers() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        expectation = self.expectation(description: "Get Users")
        
        usersViewModel.fetchUsers()
        sleep(5)
        XCTAssertTrue(usersViewModel.getUser(id: usersViewModel.users.first!.id) != nil)
        
        expectation = self.expectation(description: "Search Users")
        usersViewModel.searchUser(by: "moj")
        XCTAssertTrue(usersViewModel.users.count > 0)
        
        self.waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    func testFetchUserDetails() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        usersViewModel.fetchUsers()
        sleep(5)
        
        expectation = self.expectation(description: "Get user details")
        
        profileViewModel.user = usersViewModel.users.first
        profileViewModel.fetchUserDetails()
        sleep(5)
        XCTAssertTrue(profileViewModel.userDetails != nil)
        
        self.waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    func testSaveNotes() throws {
        usersViewModel.fetchUsers()
        sleep(5)
        profileViewModel.user = usersViewModel.users.first
        
        expectation = self.expectation(description: "Saving notes")
        profileViewModel.saveUser(notes: "This is a test note")
        
        
        let user = profileViewModel.getUser(profileViewModel.user!.id, taskContext: profileViewModel.getTaskContext())
        
        XCTAssertTrue(user?.notes == "This is a test note")
        
        self.waitForExpectations(timeout: 5.0, handler: nil)
        
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
