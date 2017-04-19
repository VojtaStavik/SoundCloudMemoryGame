
import UIKit
import ReactiveSwift

class GameVM {
    
    // MARK: --=== Public ==---

    init(game: Game) {
        self.game = game
        
        // Observe game state
        game.state.producer
            .observe(on: UIScheduler())
            .startWithValues { [unowned self] (state) in
                if case .finished = state {
                    self.gameFinishedClosure?()
                }
        }
    }

    var numberOfRows: Int {
        return game.grid.rows
    }
    
    var numberOfColumns: Int {
        return game.grid.columns
    }
    
    /// Flips card on the given row and column
    func flipCard(row: Int, column: Int) {
        game.flipCard(row: row, column: column)
    }
    
    /// Creates CardView for given index
    func cardView(at row: Int, column: Int) -> CardView {
        let card = game.gamePlan[row][column]
        let cardView = CardView(image: card.image)

        card.matchAnimationClosure = cardView.animateMatch
        
        // Bind card state updates
        card.state.producer
            .observe(on: UIScheduler())
            .startWithValues { [weak cardView] (state) in
                switch state {
                case .regular:
                    cardView?.transitionToLogo()
                    
                case .flipped:
                    cardView?.transitionToImage()
                }
        }
        
        return cardView
    }
    
    /// This closure is called when the current game is finished
    var gameFinishedClosure: (() -> Void)?
    
    
    // MARK: --=== Private ==---

    private let game: Game
}
