import UIKit

class BirthdayCardCell: UITableViewCell {
    static let identifier = "BirthdayCardCell"
    let cardView = BirthdayCardView()

    var onCardTapped: ((BirthdayEntry) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCard()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCard()
    }

    private func setupCard() {
        contentView.addSubview(cardView)
        cardView.onTapped = { [weak self] entry in
            self?.onCardTapped?(entry)
        }
        cardView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
        selectionStyle = .none
    }

    func configure(with entry: BirthdayEntry) {
        cardView.configure(entry: entry)
    }
}

