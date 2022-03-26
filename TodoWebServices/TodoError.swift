//
//  TodoError.swift
//  Toddly
//
//  Created by Locomoviles on 3/19/22.
//

import Foundation

/// A customer `Error` specific for this module
public enum TodoError: Error {
    case invalidRequestData
    case deleteFailed
    case missingId
}

extension TodoError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidRequestData:
            return NSLocalizedString("Payload data is not valid", comment: "Invalid Todo payload")
        case .deleteFailed:
            return NSLocalizedString("Deleting your todo item failed", comment: "Failed to delete")
        case .missingId:
            return NSLocalizedString("An object id is required", comment: "The id could be empty")
        }
    }
}
