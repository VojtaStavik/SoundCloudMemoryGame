
import UIKit

// Since we don't need any persitence, simple Dictionary is enough for ImageStore

typealias ImageStore = Dictionary<ImageID, UIImage>

typealias ImageID = String

/// Convenience helper allowing us to do: imageStore = imageStore1 + imageStore2
extension Dictionary where Key == ImageID, Value == UIImage {
    static func + (left: Dictionary<Key, Value>, right: Dictionary<Key, Value>) -> Dictionary<Key, Value> {
        var result = left
        right.forEach{ result[$0] = $1 }
        return result
    }
}
