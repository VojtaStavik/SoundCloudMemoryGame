
import Foundation
import RxSwift
import SwiftyJSON

protocol Gateway {
    init(session: URLSessionProtocol)
    func call(url: URL, method: GatewayMethod) -> Observable<Data>
}

extension Gateway {
    
    /// Convenience function witch tries to parse the returning data to JSON
    func callJSON(url: URL, method: GatewayMethod) -> Observable<JSON> {
        return call(url: url, method: method)
            .map { (data) -> JSON in
                var error: NSError?
                let json = JSON(data: data, error: &error)
                
                if error != nil{
                    throw Error.gateway(.invalidJSON)
                } else {
                    return json
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
    func call(url: URL, method: GatewayMethod) -> Observable<Data> {
        
        return Observable.create { (observer) in
        
            var request = URLRequest(url: url)
            request.httpMethod = method.rawValue
            request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
            
            let task = self.session.dataTask(with: request) { (data, _, error) in
                
                guard let data = data else {
                    if let description = error?.localizedDescription {
                        // Next step would be to provide custom, more friendly messages for the most common errors.
                        observer.onError(Error.gateway(.network(description: description)))
                    } else {
                        observer.onError(Error.gateway(.unknown))
                    }
                    return
                }
                
                observer.onNext(data)
                observer.onCompleted()
                
            }
            
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }

    // MARK: --=== Private ==---

    fileprivate let session: URLSessionProtocol
}
