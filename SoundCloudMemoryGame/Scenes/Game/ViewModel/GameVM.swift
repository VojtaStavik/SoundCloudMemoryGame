
import UIKit
import ReactiveSwift

class GameVM {
    
    // The delay before resetting the cards after wrong move
    let wrongMoveResetDelay: TimeInterval = 0.5
    
    // The delay after match
    let matchDelay: TimeInterval = 0.5
    
    
    // MARK: --=== Public ==---

    init(imageStore: ImageStore, gameSettings: GameSettings) {
        self.imageStore = imageStore
        self.gameSettings = gameSettings
    }

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
        
        return stride(from: 0, to: cards.count, by: grid.collums)
            .map {
                Array(cards[$0..<($0 + grid.collums)])
            }
    }()
    
    
    func flipCard(row: Int, collum: Int) {
        updateGameState(with: gamePlan[row][collum])
    }
    
    // MARK: --=== Private ==---
    
    enum GameState {
        case regular
        case moveInProgress(previous: Card)
        case resolving
        case finished
    }
   
    private(set) var state: GameState = .regular
    
    private func updateGameState(with card: Card) {
        switch state {
        case .regular:
            card.flip()
            state = .moveInProgress(previous: card)
            
        case .moveInProgress(previous: let previousCard):
            card.flip()
            state = .resolving
            resolveMatch(card1: previousCard, card2: card)
            
        default:
            // Ignore flip in other states
            break
        }
    }
    
    private func resolveMatch(card1: Card, card2: Card) {
        
        if card1.matches(card2) {
            card1.animateMatch?(matchDelay)
            card2.animateMatch?(matchDelay)
            DispatchQueue.main.asyncAfter(deadline: .now() + matchDelay) {
                self.checkIfFinished()
            }
        
        } else {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + wrongMoveResetDelay) {
                self.resetCards(card1: card1, card2: card2)
            }
        }
    }
    
    private func resetCards(card1: Card, card2: Card) {
        card1.reset()
        card2.reset()
        state = .regular
    }
    
    private func checkIfFinished() {
        let unflippedCards = gamePlan.flatMap{ $0 }.filter{ $0.isFlipped == false }
        
        if unflippedCards.isEmpty {
            state = .finished
        } else {
            state = .regular
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
