
@testable import SoundCloudMemoryGame

import Foundation
import ReactiveSwift

class APIMock: API {
    convenience init() { self.init(gateway: GatewayMock(), clientID: "") }
    required init(gateway: Gateway, clientID: ClientID) { }
    
    /// Exposed observer from the getImagesURLs function
    var getImagesURLObserver: Observer<[URL], SoundCloudMemoryGame.Error>?
    var getImagesURLsCount: Int?
    
    func getImagesURLs(count: Int) -> SignalProducer<[URL], SoundCloudMemoryGame.Error> {
        return SignalProducer { observer, _ in
            self.getImagesURLsCount = count
            self.getImagesURLObserver = observer
        }
    }
    
    /// Exposed observer from the downloadImages function
    var downloadImagesObserver: Observer<ImageStore, SoundCloudMemoryGame.Error>?
    
    func downloadImages(urls: [URL]) -> SignalProducer<ImageStore, SoundCloudMemoryGame.Error> {
        return SignalProducer { observer, _ in
            self.downloadImagesObserver = observer
        }
    }
}
