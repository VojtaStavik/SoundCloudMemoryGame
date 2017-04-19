
@testable import SoundCloudMemoryGame

import Foundation
import Quick
import Nimble
import SwiftyJSON

class APITests: QuickSpec {

    override func spec(){
        
        describe("SCAPI") {
            
            let clientID: API.ClientID = "testID"
            
            var api: API!
            var gateway: GatewayMock!
            
            beforeEach {
                gateway = GatewayMock()
                api = SCAPI(gateway: gateway, clientID: clientID)
            }
            
            // MARK: --=== getImagesURLs ==---
            
            describe("getImagesURLs") {

                beforeEach {
                    api.getImagesURLs(count: 1).start()
                }
                
                it("should call Gateway with correct URL and client ID") {
                    expect(gateway.calledURLs).to(equal([URL(string: "https://api.soundcloud.com/playlists/79670980?client_id=testID")!]))
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
            
            // MARK: --=== downloadImages ==---
            
            describe("downloadImages") {
                
                var imageStore: ImageStore?
                
                beforeEach {
                    // Prepare mock response
                    gateway.responseDataForURL[URL(string: "first://")!] = UIImagePNGRepresentation(self.mockImage1)!
                    gateway.responseDataForURL[URL(string: "second://")!] = UIImagePNGRepresentation(self.mockImage2)!
                    
                    // Make the call
                    api.downloadImages(urls: [URL(string: "first://")!, URL(string: "second://")!])
                        .startWithResult { (result) in
                            if case let .success(store) = result {
                                imageStore = store
                            }
                        }
                }
                
                it("should call Gateway with correct URLs") {
                    let correctURLs: Set<URL> = [URL(string: "first://")!, URL(string: "second://")!]
                    expect(gateway.calledURLs).to(equal(correctURLs))
                }
                
                it("should create new ImageStore with downloaded images") {
                    expect(imageStore?.count).toEventually(equal(2))
                    expect(imageStore?["first://"]?.isTheSame(as: self.mockImage1)).toEventually(beTrue())
                    expect(imageStore?["second://"]?.isTheSame(as: self.mockImage2)).toEventually(beTrue())
                }
                
                
                context("when not all images are succesfully downloaded") {
                
                    var responseError: SoundCloudMemoryGame.Error?
                    
                    beforeEach {
                        // Prepare mock response (response for "second" url is missing)
                        gateway.responseDataForURL = [URL(string: "first://")!: UIImagePNGRepresentation(self.mockImage1)!]
                        gateway.responseError = .gateway(.unknown)
                        gateway.responseData = nil
                        
                        // Make the call
                        api.downloadImages(urls: [URL(string: "first://")!, URL(string: "second://")!])
                            .startWithResult { (result) in
                                if case let .failure(error) = result {
                                    responseError = error
                                }
                        }
                    }
                    
                    it("should return canDonwloadImage error") {
                        expect(responseError).toEventually(equal(.api(.cantDownloadImages)))
                    }
                }
            }
            
            
            // MARK: --=== fetchImageURLsAndPrepareImageStore ==---
            
            describe("fetchImageURLsAndPrepareImageStore") {
                
                // This is just a combined producer for fetchImagesURL and donwloadImages. Let's just check
                // if everything is wired up correctly.
                
                var imageStore: ImageStore?
                
                beforeEach {
                    // Prepare mock responses
                    gateway.responseJSON = self.mockJSONResponse
                    gateway.responseDataForURL[URL(string: "https://i1.sndcdn.com/artworks-000082605199-ww02qv-large.jpg")!] = UIImagePNGRepresentation(self.mockImage1)!
                    
                    // Make the call
                    api.fetchImageURLsAndPrepareImageStore(count: 1)
                        .startWithResult { (result) in
                            if case let .success(store) = result {
                                imageStore = store
                            }
                    }
                }

                it("should create new ImageStore with 1 donwloaded image") {
                    expect(imageStore?.count).toEventually(equal(1))
                    expect(imageStore?["https://i1.sndcdn.com/artworks-000082605199-ww02qv-large.jpg"]?.isTheSame(as: self.mockImage1)).toEventually(beTrue())
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
    
    lazy var mockImage1: UIImage = {
        return UIImage(named: "ringo.jpg", in: Bundle(for: type(of: self)), compatibleWith: nil)!
    }()
    
    lazy var mockImage2: UIImage = {
        return UIImage(named: "paul.jpg", in: Bundle(for: type(of: self)), compatibleWith: nil)!
    }()
}

extension UIImage {
    /// Helper function to compare UIImages on the data level
    func isTheSame(as other: UIImage) -> Bool {
        return UIImagePNGRepresentation(self) == UIImagePNGRepresentation(other)
    }
}
