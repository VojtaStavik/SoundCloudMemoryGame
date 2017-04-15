
import Foundation

typealias Games = [CardCount: Grid]
typealias Grid = (collums: Int, rows: Int)
typealias CardCount = Int

protocol GameSettings {
    static var supportedGrids: [Grid] { get }
}

extension GameSettings {
    static var availableGames: Games {
        return supportedGrids
            .reduce(Games()) { (result, grid) -> Games in
                var mutableResult = result
                mutableResult[grid.collums * grid.rows] = grid
                return mutableResult
            }
    }
}

/// Concrete implementation of GameSettings
struct SCGameSettings: GameSettings {
    static let supportedGrids: [Grid] = [
        (collums: 2, rows: 2),
        (collums: 2, rows: 3),
        (collums: 4, rows: 3),
        (collums: 4, rows: 4)
    ]
}

/// Custom compare function for tests
extension Dictionary where Key == CardCount, Value == Grid {
    static func == (l: Dictionary<Key,Value>, r: Dictionary<Key,Value>) -> Bool {
        if l.count != r.count {
            return false
        }
        return l.keys.reduce(true) { result, key -> Bool in
            guard
                let lValue = l[key],
                let rValue = r[key]
            else {
                return false
            }
            
            return result && (lValue == rValue)
        }
    }
}
