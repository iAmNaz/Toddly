//
//  TodoTests.swift
//  TodoWebServicesTests
//
//  Created by Nazario Mariano Jr. on 3/25/22.
//

import XCTest
@testable import TodoWebServices

class TodoTests: XCTestCase {

    func test_todo_not_nil() {
        let todo = Todo(title: "tasks", completed: false, order: 0)
        XCTAssertNotNil(todo)
    }

    func test_todo_has_description() {
        let todo = Todo(title: "tasks", completed: false, order: 0)
        
        XCTAssertTrue(!todo.description.isEmpty)
    }
}
