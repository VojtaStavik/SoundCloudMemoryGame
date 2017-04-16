
import UIKit
import ReactiveSwift

class GameVC: UIViewController {
    
    // MARK: --=== Dependencies ==---
    
    var viewModel: GameVM!

    
    // MARK: --=== Public ==---

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareCardViews(gamePlan: viewModel.gamePlan)
        
        // Observe game state
        viewModel.state.producer
            .observe(on: UIScheduler())
            .startWithValues { [unowned self] (state) in
                if case .finished = state {
                    self.finishGame()
                }
            }
    }
    
    func pressCard(sender: UITapGestureRecognizer) {
        let key = indicies.keys.filter { $0.gestureRecognizers?.contains(sender) ?? false }.first
        guard
            let cardView = key,
            let index = indicies[cardView]
        else {
            fatalError("Received a tap from a card not in indicies")
        }
        
        viewModel.flipCard(row: index.row, collumn: index.collumn)
    }
    
    
    // MARK: --=== Private ==---

    @IBOutlet fileprivate weak var mainStackView: UIStackView!
    
    private var indicies: [CardView: (row: Int, collumn: Int)] = [:]
    
    private func prepareCardViews(gamePlan: [[Card]]) {

        for (rowIndex, cardsInRow) in gamePlan.enumerated() {
            let row = createRowStackView()
            mainStackView.addArrangedSubview(row)
            
            for (collumnIndex, card) in cardsInRow.enumerated() {
                let cardView = createCardView(with: card)
                indicies[cardView] = (rowIndex, collumnIndex)
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
        card.matchAnimationClosure = animateMatch(with: cardView)
        return cardView
    }
    
    fileprivate func animateMatch(with cardView: CardView) -> () -> Void {
        return {
            UIView.animate(withDuration: AnimationTime.match/2.0,
                           delay: 0,
                           options: [.beginFromCurrentState],
                           animations:
                {
                    cardView.transform = CGAffineTransform(scaleX: Animation.matchAnimationScale,
                                                           y: Animation.matchAnimationScale)
            }) { _ in
                
                UIView.animate(withDuration: AnimationTime.match/2.0,
                               delay: 0,
                               options: [.beginFromCurrentState],
                               animations:
                    {
                        cardView.transform = CGAffineTransform.identity
                })
            }
        }
    }
}

extension GameVC {
    fileprivate func finishGame() {
        UIAlertController.showAlert(with: "🎉🎉🎉", message: "Great job!", from: self) { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }
}
