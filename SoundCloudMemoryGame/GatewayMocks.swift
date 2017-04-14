
import Foundation

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
