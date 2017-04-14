
import Foundation
import ReactiveSwift
import SwiftyJSON

// MARK: --=== Gateway mock ==---

class GatewayMock: Gateway {
    
    convenience init() {
        self.init(session: URLSessionMock(configuration: .default))
    }
    
    required init(session: URLSessionProtocol) { }
    
    var url: URL?
    var method: GatewayMethod?

    var responseJSON: JSON?
    var responseError: Error?
    
    func call(url: URL, method: GatewayMethod) -> SignalProducer<JSON, Error> {
        self.url = url
        self.method = method
        
        return SignalProducer { observer, _ in
            if let json = self.responseJSON {
                observer.send(value: json)
                observer.sendCompleted()
            } else if let error = self.responseError {
                observer.send(error: error)
            }
        }
    }
}


// MARK: --=== URLSession and URLDataTask mocks ==---

class URLSessionMock: URLSessionProtocol {
    var dataResponse: Data?
    var errorResponse: Swift.Error?
    
    required init(configuration: URLSessionConfiguration) { }
    
    func dataTask(with request: URLRequest,
                  completionHandler: @escaping (Data?, URLResponse?, Swift.Error?) -> Swift.Void) -> URLSessionDataTask {
        
        let mockDataTask = URLSessionTaskMock()
        mockDataTask.completion = {
            completionHandler(self.dataResponse, nil, self.errorResponse)
        }
        
        return mockDataTask
    }
}

class URLSessionTaskMock: URLSessionDataTask {
    var completion: (() -> Void)?
    
    override func resume() {
        // Wait 100ms and call the completion handler
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: completion ?? {} )
    }
}
