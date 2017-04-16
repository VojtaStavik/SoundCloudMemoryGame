
import UIKit
import ReactiveSwift

class GameVC: UIViewController {
    
    // MARK: --=== Dependencies ==---
    
    var viewModel: GameVM!

    
    // MARK: --=== Public ==---

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareCardViews(gamePlan: viewModel.gamePlan)
    }
    
    func pressCard(sender: UITapGestureRecognizer) {
        let key = indicies.keys.filter { $0.gestureRecognizers?.contains(sender) ?? false }.first
        guard
            let cardView = key,
            let index = indicies[cardView]
        else {
            fatalError("Received a tap from a card not in indicies")
        }
        
        viewModel.flipCard(row: index.row, collum: index.collum)
    }
    
    
    // MARK: --=== Private ==---

    @IBOutlet fileprivate weak var mainStackView: UIStackView!
    
    private var indicies: [CardView: (row: Int, collum: Int)] = [:]
    
    private func prepareCardViews(gamePlan: [[Card]]) {

        for (rowIndex, cardsInRow) in gamePlan.enumerated() {
            let row = createRowStackView()
            mainStackView.addArrangedSubview(row)
            
            for (collumIndex, card) in cardsInRow.enumerated() {
                let cardView = createCardView(with: card)
                indicies[cardView] = (rowIndex, collumIndex)
                row.addArrangedSubview(cardView)
            }
        }
    }
}

extension GameVC {
    
    fileprivate func createRowStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = mainStackView.spacing
        return stackView
    }
    
    fileprivate func createCardView(with card: Card) -> CardView {
        let cardView = CardView(image: card.image)
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(pressCard(sender:)))
        cardView.addGestureRecognizer(recognizer)
        
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
        
        // Setup Match animation callback
        card.animateMatch = { [weak cardView] _ in
            UIView.animate(withDuration: 0.33, delay: 0, options: [.autoreverse], animations: {
                cardView?.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            }) { _ in
                cardView?.transform = CGAffineTransform.identity
            }
        }
        
        return cardView
    }
}
