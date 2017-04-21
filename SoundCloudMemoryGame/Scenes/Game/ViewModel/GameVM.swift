
import UIKit
import RxSwift
import RxCocoa

class GameVM {
    
    // MARK: --=== Public ==---

    init(game: Game) {
        self.game = game

        // Observe game state
        game.state.asObservable()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (state) in
                if case .finished = state {
                    self?.gameFinishedClosure?()
                }
            }).disposed(by: disposeBag)
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

        card.matchAnimationClosure = { [weak cardView] in cardView?.animateMatch() }
        
        card.state.asObservable()
            .observeOn(MainScheduler.instance)
            .takeUntil(cardView.rx.deallocated)
            .subscribe(onNext: { [weak cardView] (state) in
                switch state {
                case .regular:
                    cardView?.transitionToLogo()
                    
                case .flipped:
                    cardView?.transitionToImage()
                }
            }).disposed(by: disposeBag)
        
        return cardView
    }
    
    /// This closure is called when the current game is finished
    var gameFinishedClosure: (() -> Void)?
    
    
    // MARK: --=== Private ==---

    private let game: Game

    private lazy var disposeBag = DisposeBag()
}
