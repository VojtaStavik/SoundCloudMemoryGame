
import UIKit
import ReactiveSwift

class GameVC: UIViewController {
    
    // MARK: --=== Dependencies ==---
    
    var viewModel: GameVM!

    
    // MARK: --=== Public ==---

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCardViews()
        
        // Setup callback when game is finished
        viewModel.gameFinishedClosure = finishGame
    }
    
    func pressCard(sender: UITapGestureRecognizer) {
        let key = indicies.keys.filter { $0.gestureRecognizers?.contains(sender) ?? false }.first
        guard
            let cardView = key,
            let index = indicies[cardView]
        else {
            fatalError("Received a tap from a card not in indicies")
        }
        
        viewModel.flipCard(row: index.row, column: index.column)
    }
    
    
    // MARK: --=== Private ==---

    @IBOutlet fileprivate weak var mainStackView: UIStackView!

    private var indicies: [CardView: (row: Int, column: Int)] = [:]
    
    private func loadCardViews() {
        
        for rowIndex in 0..<viewModel.numberOfRows {
            let row = createRowStackView()
            mainStackView.addArrangedSubview(row)
            
            for collumnIndex in  0..<viewModel.numberOfColumns {
                
                let cardView = viewModel.cardView(at: rowIndex, column: collumnIndex)
                let recognizer = UITapGestureRecognizer(target: self, action: #selector(pressCard(sender:)))
                cardView.addGestureRecognizer(recognizer)
                
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
}

extension GameVC {
    
    fileprivate func finishGame() {
        UIAlertController.showAlert(with: "🎉 Completed! 🎉", message: "Great job ;-)", from: self) { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }
}
