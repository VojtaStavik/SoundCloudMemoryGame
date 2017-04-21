
@testable import SoundCloudMemoryGame

import Foundation
import RxSwift

class APIMock: API {
    convenience init() { self.init(gateway: GatewayMock(), clientID: "") }
    required init(gateway: Gateway, clientID: ClientID) { }
    
    /// Exposed observer from the getImagesURLs function
    var getImagesURLObserver: AnyObserver<[URL]>?
    var getImagesURLsCount: Int?
    
    func getImagesURLs(count: Int) -> Observable<[URL]> {
        return Observable.create { observer in
            self.getImagesURLsCount = count
            self.getImagesURLObserver = observer
            return Disposables.create()
        }
    }
    
    /// Exposed observer from the downloadImages function
    var downloadImagesObserver: AnyObserver<ImageStore>?
    
    func downloadImages(urls: [URL]) -> Observable<ImageStore> {
        return Observable.create { observer in
            self.downloadImagesObserver = observer
            return Disposables.create()
        }
    }
}
