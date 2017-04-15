
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
        guard let cardView = key else {
            fatalError("Received tap from card not in indicies")
        }
        
        let index = indicies[cardView]!
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
                let cardView = CardView(image: card.image)
                indicies[cardView] = (rowIndex, collumIndex)
                row.addArrangedSubview(cardView)
                
                let recognizer = UITapGestureRecognizer(target: self, action: #selector(pressCard(sender:)))
                cardView.addGestureRecognizer(recognizer)
                
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
                
                card.animateMatch = { [weak cardView] _ in
                    UIView.animate(withDuration: 0.33, delay: 0, options: [.autoreverse], animations: {
                        cardView?.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                    }) { _ in
                        cardView?.transform = CGAffineTransform.identity
                    }
                }
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
}
