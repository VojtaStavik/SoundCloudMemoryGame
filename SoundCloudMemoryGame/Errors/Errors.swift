
import Foundation

enum Error: Swift.Error {
    
    case gateway(GatewayError)
    enum GatewayError {
        case invalidJSON
        case network(description: String)
        case unknown
    }
    
    case api(APIError)
    enum APIError {
        case notEnoughImages
        case cantDownloadImages
    }
}

extension Error {
    var localizedDescription: String {
        switch self {
            
        // Gateway
        case .gateway(.invalidJSON):
            return NSLocalizedString("JSON in response is not valid.", comment: "Invalid JSON error message")
        case .gateway(.network(description: let description)):
            return description
        
        // API
        case .api(.notEnoughImages):
            return NSLocalizedString("Not enough images. Try to select less cards.", comment: "Not enought images error message")
        case .api(.cantDownloadImages):
            return NSLocalizedString("Can't download all images. Try again later or try to select less cards.", comment: "Can't download all images error message")
        
            
        default:
            return NSLocalizedString("Something went wrong.", comment: "Unknown error message")
        }
    }
}

// Enums with associated values are not yet equatable by default.
// see https://github.com/apple/swift-evolution/blob/master/proposals/0143-conditional-conformances.md

extension Error: Equatable {
    static func == (l: Error, r: Error) -> Bool {
        switch (l, r) {
        case (.gateway(let lError), .gateway(let rError)):
            return lError == rError

        case (.api(let lError), .api(let rError)):
             return lError == rError

        default:
            return false
        }
    }
}

extension Error.GatewayError: Equatable {
    static func == (l: Error.GatewayError, r: Error.GatewayError) -> Bool {
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
