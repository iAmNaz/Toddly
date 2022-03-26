//
//  Todo.swift
//  Toddly
//
//  Created by Locomoviles on 3/19/22.
//

import Foundation
import Combine

/// A model to create a todo item.
///
/// The same model is used in the view and web services operations.
public struct Todo: Codable, CustomStringConvertible, Identifiable {
    /// A unique id generated by the ser
    public var id: String
    /// The task description
    public var title: String
    /// A boolean that indictes if a task is done. Defaults to false.
    public var completed: Bool
    /// An integer used for sorting a list of Todo objects.
    public var order: Int
    
    /// A custom initializer that initializes all properties
    ///
    /// - Parameter title is a`String` title of the todo tasks
    /// - Parameter completed indicates if a given task is done
    /// - Parameter order stores the index of the item used for sorting
    public init(title: String, completed: Bool, order: Int) {
        self.title = title
        self.completed = completed
        self.id = ""
        self.order = order
    }

    /// A custom description that returns the values of this struct's instance
    public var description: String {
        return "Todo(id: \(id), title: \(title), order: \(order), completed: \(completed))"
    }
}

/// Used for sorting operations
extension Todo: Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        return lhs.order < rhs.order
    }
}