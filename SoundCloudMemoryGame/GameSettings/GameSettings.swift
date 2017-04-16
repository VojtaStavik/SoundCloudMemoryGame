
import Foundation

typealias Games = [CardCount: Grid]
typealias Grid = (collumns: Int, rows: Int)
typealias CardCount = Int

protocol GameSettings {
    var supportedGrids: [Grid] { get }
}

extension GameSettings {
    var availableGames: Games {
        return supportedGrids
            .reduce(Games()) { (result, grid) -> Games in
                var mutableResult = result
                mutableResult[grid.collumns * grid.rows] = grid
                return mutableResult
            }
    }
}

/// Concrete implementation of GameSettings
struct SCGameSettings: GameSettings {
    let supportedGrids: [Grid] = [
        (collumns: 2, rows: 2),
        (collumns: 2, rows: 3),
        (collumns: 4, rows: 3),
        (collumns: 4, rows: 4)
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
