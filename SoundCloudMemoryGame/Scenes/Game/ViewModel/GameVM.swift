
import UIKit
import ReactiveSwift

class GameVM {
    
    // MARK: --=== Public ==---

    init(imageStore: ImageStore, gameSettings: GameSettings) {
        self.imageStore = imageStore
        self.gameSettings = gameSettings
    }

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
        
        // Find the suitable grid
        guard let grid = self.gameSettings.availableGames[cards.count] else {
            fatalError("Number of cards \(cards.count) is not a supported game configuration.")
        }
        
        return stride(from: 0, to: cards.count, by: grid.collumns)
            .map {
                Array(cards[$0..<($0 + grid.collumns)])
            }
    }()
    
    /// Flips card on the given row and collumn
    func flipCard(row: Int, collumn: Int) {
        let card = gamePlan[row][collumn]
        guard card.isFlipped == false else {
            // Ignore flips on already flipped cards
            return
        }
        
        updateGameState(with: card)
    }
    
    /// Curent state of the game
    lazy var state: Property<GameState> = Property(self._state)

    enum GameState {
        case regular
        case moveInProgress(previous: Card)
        case resolving
        case finished
    }
    
    
    // MARK: --=== Private ==---
    
    private let _state: MutableProperty<GameState> = MutableProperty(.regular)
    
    private func updateGameState(with card: Card) {
        switch _state.value {
        case .regular:
            card.flip()
            _state.value = .moveInProgress(previous: card)
            
        case .moveInProgress(previous: let previousCard):
            card.flip()
            _state.value  = .resolving
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
        _state.value  = .regular
    }
    
    private func checkIfFinished() {
        let unflippedCards = gamePlan.flatMap{ $0 }.filter{ $0.isFlipped == false }
        
        if unflippedCards.isEmpty {
            _state.value  = .finished
        } else {
            _state.value  = .regular
        }
    }
    
    private let imageStore: ImageStore
    private let gameSettings: GameSettings
}


extension GameVM.GameState: Equatable {
    
    static func == (l: GameVM.GameState, r: GameVM.GameState) -> Bool {
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
