//
//  TodoAPITests.swift
//  ToddlyTests
//
//  Created by Locomoviles on 3/19/22.
//

import Combine
import Mocker
import XCTest

@testable import TodoWebServices

class TodoAPITests: XCTestCase {
    var timeout = TimeInterval(2)
    var cancellables = Set<AnyCancellable>()
    var sessionConfig: URLSessionConfiguration!
    
    var api: TodoAPI {
        return TodoAPI(urlSession: URLSession(configuration: sessionConfig))
    }
    
    override func setUpWithError() throws {
        sessionConfig = URLSessionConfiguration.ephemeral
        sessionConfig.protocolClasses = [MockingURLProtocol.self]
    }

    override func tearDownWithError() throws {}
    
    func test_api_created() {
        let api = TodoAPI()
        
        XCTAssertNotNil(api)
    }

    func test_fetch_success_should_return_todos() {
        let expectation = self.expectation(description: "Fetch todo that succeeds")

        let data: [Mock.HTTPMethod : Data] = [
            .get : try! Data(contentsOf: MockedData.todosValidJson),
              ]
        
        apiMock(data: data)
        
        let publisher: AnyPublisher<[Todo], Error> = api.fetch()
        
        publisher.sink { completion in
            if case .failure(let error) = completion {
                print(error)
                XCTFail()
            }
        } receiveValue: { todos in
            XCTAssertTrue(todos.count == 2)
            expectation.fulfill()
        }
        .store(in: &cancellables)

        waitForExpectations(timeout: timeout)
    }
    
    func test_fetch_failure_should_return_error() {
        let expectation = self.expectation(description: "Fetch todo that fails")

        let data: [Mock.HTTPMethod : Data] = [
            .get : Data(),
              ]
        
        apiMock(data: data, statusCode: 500)
        
        let publisher: AnyPublisher<[Todo], Error> = api.fetch()
        
        publisher.sink { completion in
            if case .failure(let error) = completion {
                XCTAssert(error.localizedDescription.hasPrefix("The operation couldn’t be completed"))
            }
            expectation.fulfill()
        } receiveValue: { _ in
            XCTFail()
        }.store(in: &cancellables)

        waitForExpectations(timeout: timeout)
    }
    
    func test_add_when_succeeds_should_return_model() {
        let expectation = self.expectation(description: "Add todo that succeeds")

        let data: [Mock.HTTPMethod : Data] = [
            .post : try! Data(contentsOf: MockedData.singleTodo),
              ]
        
        apiMock(data: data)
        
        let newTodo = Todo(title: "Dummy-task", completed: false, order: 99)
        
        do {
            try api.add(todo: newTodo).sink { completion in
                if case .failure = completion {
                    XCTFail()
                    expectation.fulfill()
                }
            } receiveValue: { todo in
                XCTAssert(todo!.title == newTodo.title)
                expectation.fulfill()
            }.store(in: &cancellables)
        } catch {
            XCTFail()
        }
        
        waitForExpectations(timeout: timeout)
    }
    
    func test_add_fails_when_sent_data_malformed() {
        let expectation = self.expectation(description: "Add todo that fails")

        let data: [Mock.HTTPMethod : Data] = [
            .post : try! Data(contentsOf: MockedData.malformedTodo),
              ]
        
        apiMock(data: data)
        
        let newTodo = Todo(title: "Dummy-task", completed: false, order: 99)
        
        do {
            try api.add(todo: newTodo).sink { completion in
                if case .failure = completion {
                    XCTAssert(true)
                    expectation.fulfill()
                }
            } receiveValue: { todo in
                XCTFail()
                expectation.fulfill()
            }.store(in: &cancellables)
        } catch {
            XCTAssert(true)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout)
    }
    
    func test_add_fails_when_received_data_malformed() {
        let expectation = self.expectation(description: "Add todo that fails")

        let data: [Mock.HTTPMethod : Data] = [
            .post : try! Data(contentsOf: MockedData.malformedTodo),
              ]
        
        apiMock(data: data)
        
        let newTodo = Todo(title: "Dummy-task", completed: false, order: 99)
        
        do {
            try api.add(todo: newTodo).sink { completion in
                if case .failure = completion {
                    XCTAssert(true)
                    expectation.fulfill()
                }
            } receiveValue: { todo in
                XCTFail()
                expectation.fulfill()
            }.store(in: &cancellables)
        } catch {
            XCTAssert(true)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout)
    }
    
    func test_add_when_http_fails_should_fail() {
        let expectation = self.expectation(description: "Add todo that fails")

        let data: [Mock.HTTPMethod : Data] = [
            .post : try! Data(contentsOf: MockedData.malformedTodo),
              ]
        
        apiMock(data: data, statusCode: 500)
        
        let newTodo = Todo(title: "Dummy-task", completed: false, order: 99)
        
        do {
            try api.add(todo: newTodo).sink { completion in
                if case .failure = completion {
                    XCTAssert(true)
                    expectation.fulfill()
                }
            } receiveValue: { todo in
                XCTFail()
                expectation.fulfill()
            }.store(in: &cancellables)
        } catch {
            XCTAssert(true)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout)
    }
    
    func test_delete_with_empty_id_should_fail() {
        let expectation = self.expectation(description: "Delete todo that fails")

        let data: [Mock.HTTPMethod : Data] = [
            .post : Data(),
              ]
        
        apiMock(data: data)
        
        let todo = Todo(title: "Dummy-task", completed: false, order: 99)
        
        do {
            try api.delete(todo: todo).sink { completion in
                if case .failure = completion {
                    XCTFail()
                    expectation.fulfill()
                }
            } receiveValue: { todo in
                XCTFail()
                expectation.fulfill()
            }.store(in: &cancellables)
        } catch {
            XCTAssert(true)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout)
    }
    
    func test_delete_with_id_should_succeed() {
        let expectation = self.expectation(description: "Delete todo that succeeds")

        let data: [Mock.HTTPMethod : Data] = [
            .delete : try! Data(contentsOf: MockedData.singleTodo),
              ]
        let todoId = "63AC3115-6E7B-4892-BDA9-D11AB19E71D1"
        let url = "\(MockedData.todosURL.absoluteString)/\(todoId)"
        
        apiMock(for: URL(string: url)!, data: data)
        
        var todo = Todo(title: "Dummy-task", completed: false, order: 99)
        todo.id = todoId
        
        do {
            try api.delete(todo: todo).sink { completion in
                switch completion {
                case .finished:
                    XCTAssert(true)
                    expectation.fulfill()
                case .failure(_):
                    XCTFail()
                }
            } receiveValue: { todo in

            }.store(in: &cancellables)
        } catch {
            XCTFail()
        }
        
        waitForExpectations(timeout: timeout)
    }
    
    func test_edit_with_id_should_succeed() {
        let expectation = self.expectation(description: "Delete todo that succeeds")

        let data: [Mock.HTTPMethod : Data] = [
            .patch : try! Data(contentsOf: MockedData.singleTodo),
              ]
        let todoId = "63AC3115-6E7B-4892-BDA9-D11AB19E71D1"
        let url = "\(MockedData.todosURL.absoluteString)/\(todoId)"
        
        apiMock(for: URL(string: url)!, data: data)
        
        var todo = Todo(title: "Dummy-task", completed: false, order: 99)
        todo.id = todoId
        
        do {
            try api.edit(todo: todo).sink { completion in
                switch completion {
                case .finished:
                    XCTAssert(true)
                    expectation.fulfill()
                case .failure(_):
                    XCTFail()
                }
            } receiveValue: { todo in

            }.store(in: &cancellables)
        } catch {
            XCTFail()
        }
        
        waitForExpectations(timeout: timeout)
    }
    
    func test_edit_without_id_should_fail() {
        let expectation = self.expectation(description: "Delete todo that succeeds")

        let data: [Mock.HTTPMethod : Data] = [
            .patch : try! Data(contentsOf: MockedData.singleTodo),
              ]
        let todoId = "63AC3115-6E7B-4892-BDA9-D11AB19E71D1"
        let url = "\(MockedData.todosURL.absoluteString)/\(todoId)"
        
        apiMock(for: URL(string: url)!, data: data)
        
        let todo = Todo(title: "Dummy-task", completed: false, order: 99)
        
        do {
            try api.edit(todo: todo).sink { completion in
                XCTFail()
            } receiveValue: { todo in
                XCTFail()
            }.store(in: &cancellables)
        } catch {
            XCTAssert(true)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout)
    }
}
