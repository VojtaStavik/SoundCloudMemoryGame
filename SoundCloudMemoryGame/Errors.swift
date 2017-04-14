
import Foundation

enum Error {
    enum Gateway: Swift.Error {
        case invalidJSON
        case network(description: String)
        case unknown
    }
}

extension Error.Gateway {
    var localizedDescription: String {
        switch self {
        case .invalidJSON:
            return NSLocalizedString("JSON in response is not valid.", comment: "Invalid JSON error message")
        case .network(description: let description):
            return description
        case .unknown:
            return NSLocalizedString("Something went wrong.", comment: "Unknown error message")
        }
    }
}

// Enums with associated types are not equatable by default
extension Error.Gateway: Equatable {
    static func == (l: Error.Gateway, r: Error.Gateway) -> Bool {
        switch (l, r) {
        case (.invalidJSON, .invalidJSON),
             (.unknown, unknown):
            return true
            
        case let (.network(lDescription), .network(rDescription)):
            return lDescription == rDescription

        default:
            return false
        }
    }
}
