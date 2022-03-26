//
//  Utilities.swift
//  ToddlyTests
//
//  Created by Locomoviles on 3/19/22.
//

import Foundation
import Mocker
@testable import TodoWebServices

class MockedData {
    static let todosURL = URL(string: "\(baseUrl)/todos")!
    static let todosValidJson: URL = Bundle(for: MockedData.self).url(forResource: "todos", withExtension: "json")!
    static let singleTodo: URL = Bundle(for: MockedData.self).url(forResource: "single-todo", withExtension: "json")!
    static let malformedTodo: URL = Bundle(for: MockedData.self).url(forResource: "malformed-todo", withExtension: "json")!
}

func apiMock(for endpointUrl: URL = MockedData.todosURL, data: [Mock.HTTPMethod : Data], statusCode: Int = 200) {
    
    if statusCode == 200 {
        let mock = Mock(url: endpointUrl,
                                      dataType: .json,
                                      statusCode: statusCode,
                                      data: data)
        mock.register()
        return
    }
    
    Mock(url: endpointUrl, dataType: .json, statusCode: statusCode, data: data,
                    requestError: URLError(.badServerResponse)).register()
}

extension Data {
    var prettyPrintedJSONString: String? {
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = String(data: data, encoding: String.Encoding.utf8) else { return nil }

        return prettyPrintedString
    }
}

