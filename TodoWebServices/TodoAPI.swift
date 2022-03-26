//
//  TodoAPI.swift
//  Toddly
//
//  Created by Locomoviles on 3/19/22.
//

import Combine
import Foundation

/// In order for us to represent the`URLSession` with a few of its interfaces
/// we created a session protocol and use to hold an instance of it.
public protocol Session {
    func dataTaskPublisher(for url: URL) -> URLSession.DataTaskPublisher
}

/// Force conformance to the `Session` protocol.
///
/// We can now use `Session` as a type to represent the actual `URLSession` object.
extension URLSession: Session {}

public let baseUrl = "http://127.0.0.1:8080"

public class TodoAPI {
    private var urlSession: URLSession
    private var cancellable: AnyCancellable!
    let todosUrl = "\(baseUrl)/todos"

    public typealias IdentifiableModel = Codable & Identifiable & Comparable
    
    /// Use this initializer to create an instance of the API client
    ///
    /// A default `URLSession` object is set
    /// - Parameter urlSession where you optionally pass your own `URLSession` object.
    public init(urlSession: URLSession = URLSession(configuration: .default)) {
        self.urlSession = urlSession
    }

    /// Use this method to fetch a list of todo items from the server.
    ///
    /// - Returns a publisher with an array of items or an error
    public func fetch<Model: IdentifiableModel>() -> AnyPublisher<[Model], Error> {
        return urlSession
            .dataTaskPublisher(for: URL(string: todosUrl)!)
            .receive(on: DispatchQueue.main)
            .tryMap { element -> Data in
                guard let httpResponse = element.response as? HTTPURLResponse,
                      httpResponse.statusCode == 200
                else {
                    throw URLError(.badServerResponse)
                }
                return element.data
            }
            .decode(type: [Model].self, decoder: JSONDecoder())
            .map { models in
                models.sorted(by: <)
            }
            .eraseToAnyPublisher()
    }

    
    /// Use this method to post data to the server
    ///
    /// - Parameter todo is an instance of the `Todo` model to add
    /// - Returns a publisher with an optional or fully initialized model or an error
    @discardableResult
    public func add<Model: IdentifiableModel>(todo: Model) throws -> AnyPublisher<Model?, Error> {

        let jsonData = try! toData(todo: todo)
        return submit(todosUrl, data: jsonData, method: "POST")
            .tryCompactMap { data in
                guard let data = data else {
                    return nil
                }
                return try JSONDecoder().decode(Model.self, from: data)
            }
            .eraseToAnyPublisher()
    }

    /// Use this method to submit modifications to the todo model
    ///
    /// - Parameter todo is an instance of the the Todo model to edit
    /// - Returns a publisher with an optional model or an error
    public func edit<Model: IdentifiableModel>(todo: Model) throws -> AnyPublisher<Model?, Error> {
        let id = "\(todo.id)"

        guard !id.isEmpty else {
            throw TodoError.missingId
        }

        let idUrl = "\(todosUrl)/\(id)"

        let jsonData = try toData(todo: todo)
        return submit(idUrl, data: jsonData, method: "PATCH")
            .tryCompactMap { data in
                guard let data = data else {
                    return nil
                }
                return try JSONDecoder().decode(Model.self, from: data)
            }
            .eraseToAnyPublisher()
    }

    /// This method is used for deleting a todo item.
    ///
    /// - Parameter todo is an instance of the the Todo model
    /// - Returns a publisher with no ouput and error
    public func delete<Model: IdentifiableModel>(todo: Model) throws -> AnyPublisher<Never, Error> {
        let id = "\(todo.id)"

        guard !id.isEmpty else {
            throw TodoError.missingId
        }

        let idUrl = "\(todosUrl)/\(id)"
        return submit(idUrl, method: "DELETE")
            .ignoreOutput()
            .eraseToAnyPublisher()
    }

    private func toData<Model: IdentifiableModel>(todo: Model) throws -> Data {
        return try! JSONEncoder().encode(todo)
    }

    private func submit(_ url: String, data: Data? = nil, method: String) -> AnyPublisher<Data?, Error> {
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = method

        if let data = data {
            request.httpBody = data
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        return urlSession
            .dataTaskPublisher(for: request)
            .receive(on: DispatchQueue.main)
            .tryCompactMap { element -> Data? in
                guard let httpResponse = element.response as? HTTPURLResponse,
                      httpResponse.statusCode == 200
                else {
                    throw URLError(.badServerResponse)
                }
                
                if element.data.isEmpty {
                    return nil
                }

                return element.data
            }
            .eraseToAnyPublisher()
    }
}
