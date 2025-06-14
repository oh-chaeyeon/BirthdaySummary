import UIKit

class BirthdayCardView: UIView {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!

    var entry: BirthdayEntry?
    var onTapped: ((BirthdayEntry) -> Void)?

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadFromNib()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadFromNib()
    }

    
    private func loadFromNib() {
        let nib = UINib(nibName: "BirthdayCardView", bundle: nil)
        guard let contentView = nib.instantiate(withOwner: self).first as? UIView else { return }
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(contentView)

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.addGestureRecognizer(tap)

        self.layer.cornerRadius = 12
        self.layer.borderWidth = 0
        self.layer.borderColor = UIColor.clear.cgColor
        self.clipsToBounds = true

        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.1
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 4
        self.layer.masksToBounds = false
    }

    @objc private func handleTap() {
        guard let entry = entry else { return }
        onTapped?(entry)
    }

    func configure(entry: BirthdayEntry) {
        self.entry = entry
        nameLabel.text = entry.name
        nicknameLabel.text = "별명: \(entry.nickname)"
        categoryLabel.text = entry.category
        categoryLabel.textColor = entry.categoryColor
        
        if self.backgroundColor == nil || self.backgroundColor == .clear {
            self.backgroundColor = entry.categoryColor.withAlphaComponent(0.12)
        }
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: 280, height: 80)
    }
}
