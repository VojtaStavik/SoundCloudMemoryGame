
import Foundation

typealias Games = [CardCount: Grid]
typealias Grid = (columns: Int, rows: Int)
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
        (columns: 2, rows: 2),
        (columns: 2, rows: 3),
        (columns: 4, rows: 3),
        (columns: 4, rows: 4)
    ]
}
