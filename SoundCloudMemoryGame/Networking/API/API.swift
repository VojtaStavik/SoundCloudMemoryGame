
import Foundation
import UIKit
import RxSwift
import SwiftyJSON

typealias ClientID = String

protocol API {
    init(gateway: Gateway, clientID: ClientID)
    func getImagesURLs(count: Int) -> Observable<[URL]>
    func downloadImages(urls: [URL]) -> Observable<ImageStore>
}

extension API {
    /// Combined producer which downloads available iamges' URLs and prepare ImageStore with them
    func fetchImageURLsAndPrepareImageStore(count: Int) -> Observable<ImageStore> {
        return getImagesURLs(count: count).flatMap(downloadImages)
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
    func getImagesURLs(count: Int) -> Observable<[URL]> {
        return gateway
            .callJSON(url: soundCloudAPIURL, method: .get)
            .map(parse(count))
    }
    
    /// Downloads images and creates a new ImageStore with them
    func downloadImages(urls: [URL]) -> Observable<ImageStore> {
        
        // No need to be super clever here, and introduce download queues etc. Let's
        // just download everything all together in parallel.
        
        let singleImageDownloadObservables = urls.map { self.downloadImage(url: $0) }
        
        // There's a bug in the compiler and the following syntax  is causing a memory leak.
        // let singleImageDownloadObservables = urls.map(downloadImage)
        
        return Observable
            .from(singleImageDownloadObservables)
            .merge()
            .reduce(ImageStore(), accumulator: ImageStore.merge)
            .catchError({ (_) -> Observable<Dictionary<ImageID, UIImage>> in
                throw Error.api(.cantDownloadImages)
            })
    }
    
    // MARK: --=== Private ==---
    
    fileprivate let gateway: Gateway
    fileprivate let clientID: ClientID
    
    fileprivate var soundCloudAPIURL: URL {
        return URL(string: "https://api.soundcloud.com/playlists/79670980?client_id=\(self.clientID)")!
    }
    
    
    /// Parses response JSON to array of image to <count> URLs
    fileprivate func parse(_ count: Int) -> (JSON) throws -> [URL] {
        return { (json: JSON) throws -> [URL] in
            
            // get array of tracks
            guard
                let tracks = json["tracks"].array,
                tracks.count >= count else
            {
                throw Error.api(.notEnoughImages)
            }
            
            // try to get artwork_url for each track and convert it to <count> URLs
            let urls = tracks
                        .flatMap { $0["artwork_url"].string }
                        .flatMap(URL.init)
                        .prefix(count)

            guard urls.count == count else {
                throw Error.api(.notEnoughImages)
            }
            
            return Array(urls)
        }
    }
    
    /// Downloads a single image and creates a new ImageStore with it.
    fileprivate func downloadImage(url: URL) -> Observable<ImageStore> {
        return gateway
            .call(url: url, method: .get)
            .map { (data) -> ImageStore in
                if let image = UIImage(data: data) {
                    return [ImageID(url.absoluteString): image]
                } else {
                    throw Error.api(.cantDownloadImages)
                }
            }
    }
}
