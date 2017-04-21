
import UIKit.UIImage
import RxSwift

/// The Game class completely handles the game logic.
class Game {
    
    init(imageStore: ImageStore, grid: Grid) {
        if imageStore.count * 2 != grid.columns * grid.rows {
            fatalError("Grid \(grid) doesn't fit provided number of images: \(imageStore.keys.count)")
        }
        
        self.imageStore = imageStore
        self.grid = grid
    }
    
    let grid: Grid
    
    /// GamePlan of the current game
    lazy var gamePlan: [[Card]] = {
        
        var allImages: [(ImageID, UIImage)] = []
        
        for (id, image) in self.imageStore {
            allImages.append((id, image))
        }
        
        // We need to duplicate the array to get 2 images for each original image
        allImages += allImages
        
        // Shuffle images in the array
        allImages.shuffle()
        
        // Prepare Cards
        let cards = allImages.map(Card.init)
        
        return stride(from: 0, to: cards.count, by: self.grid.columns)
            .map { Array(cards[$0..<($0 + self.grid.columns)]) }
    }()
    
    /// Flips card on the given row and column
    func flipCard(row: Int, column: Int) {
        let card = gamePlan[row][column]
        guard card.isFlipped == false else {
            // Ignore flips on already flipped cards
            return
        }
        
        updateState(with: card)
    }
    
    /// Curent state of the game
    private(set) lazy var state: Variable<State> = Variable(.regular)
    
    enum State {
        case regular
        case moveInProgress(previous: Card)
        case resolving
        case finished
    }
    
    
    // MARK: --=== Private ==---
    
    private let imageStore: ImageStore
    
    private func updateState(with card: Card) {
        switch state.value {
        case .regular:
            card.flip()
            state.value = .moveInProgress(previous: card)
            
        case .moveInProgress(previous: let previousCard):
            card.flip()
            state.value  = .resolving
            resolveMatch(card1: previousCard, card2: card)
            
        default:
            // Ignore flip in other states
            break
        }
    }
    
    private func resolveMatch(card1: Card, card2: Card) {
        
        if card1.matches(card2) {
            card1.match()
            card2.match()
            DispatchQueue.main.asyncAfter(deadline: .now() + AnimationTime.match) {
                self.checkIfFinished()
            }
            
        } else {
            let duration: TimeInterval = AnimationTime.flip + AnimationTime.notMatch
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                self.resetCards(card1: card1, card2: card2)
            }
        }
    }
    
    private func resetCards(card1: Card, card2: Card) {
        card1.reset()
        card2.reset()
        state.value  = .regular
    }
    
    private func checkIfFinished() {
        let unflippedCards = self.gamePlan.flatMap{ $0 }.filter{ $0.isFlipped == false }
        
        if unflippedCards.isEmpty {
            state.value  = .finished
        } else {
            state.value  = .regular
        }
    }
}


extension Game.State: Equatable {
    
    static func == (l: Game.State, r: Game.State) -> Bool {
        switch (l, r) {
        case (.regular, .regular),
             (.finished, .finished),
             (.resolving, .resolving):
            return true
            
        case let (.moveInProgress(leftCard), .moveInProgress(rightCard)):
            return leftCard === rightCard
            
        default:
            return false
        }
    }
}
