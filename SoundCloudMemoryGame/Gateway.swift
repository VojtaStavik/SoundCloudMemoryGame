
import Foundation
import ReactiveSwift
import SwiftyJSON

protocol Gateway {
    init(session: URLSessionProtocol)
    func call(url: URL, method: GatewayMethod) -> SignalProducer<JSON, Error.Gateway>
}

enum GatewayMethod: String {
    case get = "GET"
}

/// Protocol generalizing URLSession allowing proper DI in tests
protocol URLSessionProtocol {
    init(configuration: URLSessionConfiguration)
    
    func dataTask(with request: URLRequest,
                  completionHandler: @escaping (Data?, URLResponse?, Swift.Error?) -> Swift.Void) -> URLSessionDataTask
}

extension URLSession: URLSessionProtocol { }



/// Concrete implementation of the Gateway protocol
struct SCGateway: Gateway {
    
    // MARK: --=== Public ==---
    
    init(session: URLSessionProtocol) {
        self.session = session
    }
    
    /// Executes call with provided URL and HTTP method.
    func call(url: URL, method: GatewayMethod) -> SignalProducer<JSON, Error.Gateway> {
        
        return SignalProducer { (observer, _) in
        
            var request = URLRequest(url: url)
            request.httpMethod = method.rawValue
            
            self.session.dataTask(with: request) { (data, _, error) in
                guard let data = data else {
                    if let description = error?.localizedDescription {
                        // Next step would be to provide custom, more friendly messages for the most common errors.
                        observer.send(error: Error.Gateway.network(description: description))
                    } else {
                        observer.send(error: .unknown)
                    }
                    return
                }

                var error: NSError?
                let json = JSON(data: data, error: &error)
                
                if error != nil{
                    observer.send(error: .invalidJSON)
                } else {
                    observer.send(value: json)
                }
                
            }.resume()
        }
    }

    // MARK: --=== Private ==---

    fileprivate let session: URLSessionProtocol
}
