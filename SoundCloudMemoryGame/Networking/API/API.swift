
import Foundation
import UIKit
import ReactiveSwift
import SwiftyJSON
import Result

protocol API {
    
    typealias ClientID = String
    
    init(gateway: Gateway, clientID: ClientID)
    func getImagesURLs(count: Int) -> SignalProducer<[URL], Error>
    func downloadImages(urls: [URL]) -> SignalProducer<ImageStore, Error>
}

extension API {
    /// Combined producer which downloads available iamges' URLs and prepare ImageStore with them
    func fetchImageURLsAndPrepareImageStore(count: Int) -> SignalProducer<ImageStore, Error> {
        return getImagesURLs(count: count)
            .flatMap(.concat, transform: downloadImages)
    }
}

/// Concrete implementation for SoundCloud API
struct SCAPI: API {
    
    // MARK: --=== Public ==---

    init(gateway: Gateway, clientID: ClientID) {
        self.gateway = gateway
        self.clientID = clientID
    }
    
    /// Fetches URLs of available images
    func getImagesURLs(count: Int) -> SignalProducer<[URL], Error> {
        return gateway
            .call(url: soundCloudAPIURL, method: .get)
            .attemptMap(parse(count))
    }
    
    /// Downloads images and creates a new ImageStore with them
    func downloadImages(urls: [URL]) -> SignalProducer<ImageStore, Error> {
        
        // No need to be super clever here, and introduce download queues etc. Let's
        // just download everything all together in parallel.
        
        let singleImageDownloadProducers = urls.map(downloadImage)
        let combinedProducer = SignalProducer<SignalProducer<ImageStore, Error>, Error>(singleImageDownloadProducers)
        
        return combinedProducer
            .flatten(.concat)
            .reduce(ImageStore(), Dictionary.merge)
            .mapError { _ in return .api(.cantDownloadImages) }
    }
    
    // MARK: --=== Private ==---
    
    fileprivate let gateway: Gateway
    fileprivate let clientID: ClientID
    
    fileprivate var soundCloudAPIURL: URL {
        return URL(string: "https://api.soundcloud.com/playlists/79670980?client_id=\(self.clientID)")!
    }
    
    
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
    
    /// Downloads a single image and creates a new ImageStore with it.
    fileprivate func downloadImage(url: URL) -> SignalProducer<ImageStore, Error> {
        return gateway
            .call(url: url, method: .get)
            .attemptMap { (data) -> Result<ImageStore, Error> in
                if let image = UIImage(data: data) {
                    return .success([ImageID(url.absoluteString): image])
                } else {
                    return .failure(.api(.cantDownloadImages))
                }
            }
    }
}
