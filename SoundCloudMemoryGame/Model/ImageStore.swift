
import UIKit

// Since we don't need any persistence for now, simple Dictionary is enough for ImageStore

typealias ImageStore = Dictionary<ImageID, UIImage>

typealias ImageID = String

/// Convenience helper allowing us to do: reduce( ... , Dictionary.merge)
extension Dictionary where Key == ImageID, Value == UIImage {
    /// All values and keyf from the right Dictionary are copied to the left one.
    static func merge (left: Dictionary<Key, Value>, right: Dictionary<Key, Value>) -> Dictionary<Key, Value> {
        var result = left
        right.forEach{ result[$0] = $1 }
        
        return result
    }
}
