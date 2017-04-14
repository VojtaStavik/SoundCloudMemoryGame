
@testable import SoundCloudMemoryGame

import Foundation
import Quick
import Nimble
import SwiftyJSON

class GatewayTests: QuickSpec {
    override func spec(){
        
        let session = URLSessionMock(configuration: .default)
        
        describe("SCGateway") {
            var gateway: Gateway!
            
            beforeEach {
                gateway = SCGateway(session: session)
            }
            
            afterEach {
                session.dataResponse = nil
                session.errorResponse = nil
            }
            
            describe("call") {
                
                context("when response is sucessfull and data are a valid JSON") {

                    var responseJSON: JSON?
                    
                    beforeEach {
                        // Simulate successfull response
                        session.dataResponse = "{\"status\": \"ok\"}".data(using: .utf8)
                        
                        // Make the call
                        gateway
                            .call(url: URL(string: "http://mock")!, method: .get)
                            .startWithResult { (result) in
                                if case let .success(json) = result {
                                    responseJSON = json
                                }
                            }
                    }
                    
                    it("should parse data to JSON") {
                        expect(responseJSON?["status"]).toEventually(equal("ok"))
                    }
                }
                
                
                context("when response is sucessfull but data are not a valid JSON") {
                    var responseError: SoundCloudMemoryGame.Error.Gateway?
                    
                    beforeEach {
                        // Simulate successfull response but invalid JSON
                        session.dataResponse = "<invalid json>".data(using: .utf8)
                        
                        // Make the call
                        gateway
                            .call(url: URL(string: "http://mock")!, method: .get)
                            .startWithResult { (result) in
                                if case let .failure(error) = result {
                                    responseError = error
                                }
                        }
                    }
                    
                    it("should return invalidJSON error") {
                        expect(responseError).toEventually(equal(Error.Gateway.invalidJSON))
                    }
                }

                
                context("when response is not successfull") {
                    var responseError: SoundCloudMemoryGame.Error.Gateway?
                    
                    beforeEach {
                        // Simulate error response
                        session.errorResponse = NSError(domain: "TEST",
                                                        code: 999,
                                                        userInfo: [NSLocalizedDescriptionKey : "Error description"])
                        
                        // Make the call
                        gateway
                            .call(url: URL(string: "http://mock")!, method: .get)
                            .startWithResult { (result) in
                                if case let .failure(error) = result {
                                    responseError = error
                                }
                        }
                    }
                    
                    it("should return the error") {
                        expect(responseError?.localizedDescription).toEventually(equal("Error description"))
                    }
                }

                
                context("when response is not successfull and error response is empty") {
                    var responseError: SoundCloudMemoryGame.Error.Gateway?
                    
                    beforeEach {
                        // Simulate error response
                        session.errorResponse = nil
                        session.dataResponse = nil
                        
                        // Make the call
                        gateway
                            .call(url: URL(string: "http://mock")!, method: .get)
                            .startWithResult { (result) in
                                if case let .failure(error) = result {
                                    responseError = error
                                }
                        }
                    }
                    
                    it("should return unknown error") {
                        expect(responseError).toEventually(equal(SoundCloudMemoryGame.Error.Gateway.unknown))
                    }
                }

            }
        }
    }
}
