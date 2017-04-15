
import UIKit

typealias ImageStore = Dictionary<ImageID, UIImage>

typealias ImageID = String

extension Dictionary where Key == ImageID, Value == UIImage {
    static func + (left: Dictionary<Key, Value>, right: Dictionary<Key, Value>) -> Dictionary<Key, Value> {
        var result = left
        right.forEach{ result[$0] = $1 }
        return result
    }
}
