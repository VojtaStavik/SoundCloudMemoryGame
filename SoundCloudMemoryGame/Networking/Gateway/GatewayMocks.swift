
@testable import SoundCloudMemoryGame

import Foundation
import RxSwift
import SwiftyJSON

// MARK: --=== Gateway mock ==---

class GatewayMock: Gateway {
    
    convenience init() {
        self.init(session: URLSessionMock(configuration: .default))
    }
    
    required init(session: URLSessionProtocol) { }
    
    var calledURLs = Set<URL>()
    var method: GatewayMethod?

    var responseJSON: JSON?
    var responseData: Data?
    var responseError: SoundCloudMemoryGame.Error?
    
    var responseDataForURL = [URL: Data]()
    
    func call(url: URL, method: GatewayMethod) -> Observable<Data> {
        calledURLs.insert(url)
        self.method = method
        
        return Observable.create { observer in
            
            // Is there a specific mock response for this URL?
            if let data = self.responseDataForURL[url] {
                observer.onNext(data)
                observer.onCompleted()
            }
            
            if let json = self.responseJSON {
                observer.onNext(try! json.rawData())
                observer.onCompleted()
                
            } else if let data = self.responseData {
                observer.onNext(data)
                observer.onCompleted()
            
            } else if let error = self.responseError {
                observer.onError(error)
            }
            
            return Disposables.create()
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
    
    override func cancel() {
        // Empty implementation
    }
}
