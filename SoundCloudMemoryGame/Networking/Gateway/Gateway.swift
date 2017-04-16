
import Foundation
import ReactiveSwift
import SwiftyJSON
import Result

protocol Gateway {
    init(session: URLSessionProtocol)
    func call(url: URL, method: GatewayMethod) -> SignalProducer<Data, Error>
}

extension Gateway {
    
    /// Convenience function witch tries to parse the returning data to JSON
    func call(url: URL, method: GatewayMethod) -> SignalProducer<JSON, Error> {
        return call(url: url, method: method)
            .attemptMap { (data) -> Result<JSON, Error> in
                var error: NSError?
                let json = JSON(data: data, error: &error)
                
                if error != nil{
                    return .failure(.gateway(.invalidJSON))
                } else {
                    return .success(json)
                }
            }
    }
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
    func call(url: URL, method: GatewayMethod) -> SignalProducer<Data, Error> {
        
        return SignalProducer { (observer, _) in
        
            var request = URLRequest(url: url)
            request.httpMethod = method.rawValue
            
            self.session.dataTask(with: request) { (data, _, error) in
                guard let data = data else {
                    if let description = error?.localizedDescription {
                        // Next step would be to provide custom, more friendly messages for the most common errors.
                        observer.send(error: .gateway(.network(description: description)))
                    } else {
                        observer.send(error: .gateway(.unknown))
                    }
                    return
                }
                
                observer.send(value: data)
                observer.sendCompleted()
                
            }.resume()
        }
    }

    // MARK: --=== Private ==---

    fileprivate let session: URLSessionProtocol
}
