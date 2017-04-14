
import Foundation
import UIKit
import ReactiveSwift
import SwiftyJSON
import Result

protocol API {
    init(gateway: Gateway)
    func getImagesURLs(count: Int) -> SignalProducer<[URL], Error>
}

/// Concrete implementation for SoundCloud API
struct SCAPI: API {
    
    // MARK: --=== Public ==---
    
    init(gateway: Gateway) {
        self.gateway = gateway
    }
    
    func getImagesURLs(count: Int) -> SignalProducer<[URL], Error> {
        return gateway
            .call(url: soundCloudAPIURL, method: .get)
            .attemptMap(parse(count))
    }
    
    // MARK: --=== Private ==---
    
    fileprivate let gateway: Gateway
    
    fileprivate let soundCloudAPIURL = URL(string: "https://api.soundcloud.com/playlists/79670980?client_id=aa45989bb0c262788e2d11f1ea041b65")!
    
    /// Parses response JSON to array of image to <count> URLs
    fileprivate func parse(_ count: Int) -> (JSON) -> Result<[URL], Error> {
        return { (json: JSON) -> Result<[URL], Error> in
            
            // get array of tracks
            guard
                let tracks = json["tracks"].array,
                tracks.count >= count else
            {
                return .failure(.api(.notEnoughImages))
            }
            
            // try to get artwork_url for each track and convert it to <count> URLs
            let urls = tracks
                        .flatMap { $0["artwork_url"].string }
                        .flatMap(URL.init)
                        .prefix(count)

            guard urls.count == count else {
                return .failure(.api(.notEnoughImages))
            }
            
            return .success(Array(urls))
        }
    }
}
