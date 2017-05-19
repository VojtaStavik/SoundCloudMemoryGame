
import UIKit.UIImage
import RxSwift

/// The Game class completely handles the game logic.
class Game {
    
    init(imageStore: ImageStore, grid: Grid, numberOfMatches: Int = 2) {
        if imageStore.count * 2 != grid.columns * grid.rows {
            fatalError("Grid \(grid) doesn't fit provided number of images: \(imageStore.keys.count)")
        }
        
        self.imageStore = imageStore
        self.grid = grid
        self.numberOfMatches = numberOfMatches
    }
    
    let grid: Grid
    
    /// GamePlan of the current game
    lazy var gamePlan: [[Card]] = {
        
        var images: [(ImageID, UIImage)] = []
        
        for (id, image) in self.imageStore {
            images.append((id, image))
        }
        
        var allImages: [(ImageID, UIImage)] = []
        // We need to duplicate the array to get <numberOfMatches> images for each original image
        for _ in 0..<self.numberOfMatches {
            allImages += images
        }
        
        
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
        case moveInProgress(previous: [Card])
        //case resolving
        case finished
    }
    
    
    // MARK: --=== Private ==---
    
    private let imageStore: ImageStore
    
    private let numberOfMatches: Int
    
    private func updateState(with card: Card) {
        switch state.value {
        case .regular:
            card.flip()
            state.value = .moveInProgress(previous: [card])
            
        case let .moveInProgress(previous: previousCards):
            guard let referenceCard = previousCards.first else {
                fatalError("Previous card array is empty!")
            }

            card.flip()
            
            if referenceCard.matches(card) {
                if previousCards.count + 1 == numberOfMatches {
                    DispatchQueue.main.asyncAfter(deadline: .now() + AnimationTime.match) {
                        self.checkIfFinished()
                    }

                } else {
                    state.value = .moveInProgress(previous: previousCards + [card])
                }
                
            } else {
                let duration: TimeInterval = AnimationTime.flip + AnimationTime.notMatch
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                    self.resetMove(cards: previousCards + [card])
                }
            }

        default:
            // Ignore flip in other states
            break
        }
    }
    
    private func resetMove(cards: [Card]) {
        cards.forEach { $0.reset() }
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
             (.finished, .finished):
            return true
            
        case let (.moveInProgress(leftCard), .moveInProgress(rightCard)):
            return leftCard == rightCard
            
        default:
            return false
        }
    }
}
