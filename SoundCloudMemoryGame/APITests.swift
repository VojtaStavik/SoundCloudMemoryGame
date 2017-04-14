

@testable import SoundCloudMemoryGame

import Foundation
import Quick
import Nimble
import SwiftyJSON

class APITests: QuickSpec {

    override func spec(){
        
        describe("SCAPI") {
            
            var api: API!
            var gateway: GatewayMock!
            
            beforeEach {
                gateway = GatewayMock()
                api = SCAPI(gateway: gateway)
            }
            
            describe("getImagesURLs") {

                beforeEach {
                    api.getImagesURLs(count: 1).start()
                }
                
                it("should call Gateway with correct URL") {
                    expect(gateway.url).to(equal(URL(string: "https://api.soundcloud.com/playlists/79670980?client_id=aa45989bb0c262788e2d11f1ea041b65")))
                }
                
                
                context("when called with count 4 and images are available") {

                    var imageURLs: [URL]?
                    
                    beforeEach {
                        gateway.responseJSON = self.mockJSONResponse
                        api.getImagesURLs(count: 4).startWithResult { (result) in
                            if case let .success(urls) = result {
                                imageURLs = urls
                            }
                        }
                    }
                    
                    it("should return only 4 URLs") {
                        expect(imageURLs?.count).toEventually(equal(4))
                        
                        let correctURLs = [
                            URL(string: "https://i1.sndcdn.com/artworks-000082605199-ww02qv-large.jpg")!,
                            URL(string: "https://i1.sndcdn.com/artworks-000050346484-c75ab5-large.jpg")!,
                            URL(string: "https://i1.sndcdn.com/artworks-000067900006-cedza2-large.jpg")!,
                            URL(string: "https://i1.sndcdn.com/artworks-000088814272-vfbodd-large.jpg")!,
                                            ]
                        
                        expect(imageURLs).toEventually(equal(correctURLs))
                    }
                }

                
                context("when called with the count bigger than the number of URLs in the response") {
                    
                    var responseError: SoundCloudMemoryGame.Error?
                    
                    beforeEach {
                        gateway.responseJSON = self.mockJSONResponse
                        api.getImagesURLs(count: 100).startWithResult { (result) in
                            if case let .failure(error) = result {
                                responseError = error
                            }
                        }
                    }
                    
                    it("should return notEnoughImages error") {
                        expect(responseError).toEventually(equal(.api(.notEnoughImages)))
                    }
                }

                
                context("when the gateway returns an error") {
                    
                    var responseError: SoundCloudMemoryGame.Error?
                    
                    beforeEach {
                        gateway.responseError = .gateway(.invalidJSON)
                        api.getImagesURLs(count: 4).startWithResult { (result) in
                            if case let .failure(error) = result {
                                responseError = error
                            }
                        }
                    }
                    
                    it("should propagate the error") {
                        expect(responseError).toEventually(equal(.gateway(.invalidJSON)))
                    }
                }
                
            }
                
        }
    }
    
    /// API mock JSON response
    lazy var mockJSONResponse: JSON = {
        let url = Bundle(for: type(of: self)).url(forResource: "apiMockResponse", withExtension: "json")!
        let jsonData = try! Data(contentsOf: url)
        return JSON(data: jsonData)
    }()
    
}
