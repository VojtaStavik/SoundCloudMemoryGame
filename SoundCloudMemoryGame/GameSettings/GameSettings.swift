
import Foundation

typealias Games = [CardCount: Grid]

struct Grid {
    let columns: Int
    let rows: Int
}

extension Grid: ExpressibleByArrayLiteral {
    init(arrayLiteral elements: Int...) {
        guard elements.count == 2 else {
            fatalError("Grid has to have 2 coordinates.")
        }
        self = Grid(columns: elements[0], rows: elements[1])
    }
}

typealias CardCount = Int

/// GameSettings provides supported game configurations
protocol GameSettings {
    var supportedGrids: [Grid] { get }
}

extension GameSettings {
    var availableGames: Games {
        return supportedGrids
            .reduce(Games()) { (result, grid) -> Games in
                var mutableResult = result
                mutableResult[grid.columns * grid.rows] = grid
                return mutableResult
            }
    }
}

/// Concrete implementation of GameSettings
struct SCGameSettings: GameSettings {
    let supportedGrids: [Grid] = [
        [2, 2],
        [2, 3],
        [4, 3],
        [4, 4]
    ]
}
