//
//  TodoErrorTests.swift
//  TodoWebServicesTests
//
//  Created by Nazario Mariano Jr. on 3/25/22.
//

import XCTest
@testable import TodoWebServices

class TodoErrorTests: XCTestCase {

    func test_invalidRequest_error() {
        let error = TodoError.invalidRequestData
        
        let localizedString = "Payload data is not valid"
        
        XCTAssertEqual(error.errorDescription, localizedString)
    }

    func test_delete_failed_error() {
        let error = TodoError.deleteFailed
        
        let localizedString = "Deleting your todo item failed"
        
        XCTAssertEqual(error.errorDescription, localizedString)
    }
    
    func test_missing_id_failed_error() {
        let error = TodoError.missingId
        
        let localizedString = "An object id is required"
        
        XCTAssertEqual(error.errorDescription, localizedString)
    }
}
