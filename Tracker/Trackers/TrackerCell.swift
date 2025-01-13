import UIKit

protocol TrackerCellDelegate: AnyObject {
    func completeTracker(id: UUID, at indexPath: IndexPath)
    func uncompleteTracker(id: UUID, at indexPath: IndexPath)
}

final class TrackerCell: UICollectionViewCell {
    
    static let identifier = "TrackerCell"
    weak var delegate: TrackerCellDelegate?
    
    private let colorView = UIView()
    private let emojiLabel = UILabel()
    private let titleLabel = UILabel()
    private let daysLabel = UILabel()
    private let plusButton = UIButton()
    
    private var isDone = false
    private var trackerId: UUID?
    private var indexPath: IndexPath?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        colorView.layer.cornerRadius = 16
        colorView.layer.borderWidth = 1
        colorView.layer.borderColor = UIColor(ciColor: CIColor(red: 174, green: 175, blue: 180, alpha: 0.3)).cgColor
        colorView.layer.masksToBounds = true
        colorView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(colorView)
        
        let emojiBackground = UIView()
        emojiBackground.layer.cornerRadius = 12
        emojiBackground.translatesAutoresizingMaskIntoConstraints = false
        emojiBackground.backgroundColor = .white.withAlphaComponent(0.3)
        colorView.addSubview(emojiBackground)
        
        emojiLabel.font = UIFont.systemFont(ofSize: 12)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        emojiBackground.addSubview(emojiLabel)
        
        titleLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        titleLabel.numberOfLines = 2
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        colorView.addSubview(titleLabel)
        
        daysLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        daysLabel.numberOfLines = 1
        daysLabel.textColor = .black
        daysLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(daysLabel)
        
        plusButton.layer.cornerRadius = 17
        plusButton.layer.masksToBounds = true
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        plusButton.tintColor = .white
        plusButton.addTarget(self, action: #selector(plusButtonPressed), for: .touchUpInside)
        contentView.addSubview(plusButton)

        NSLayoutConstraint.activate([
            colorView.topAnchor.constraint(equalTo: contentView.topAnchor),
            colorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            colorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            colorView.heightAnchor.constraint(equalToConstant: 90),

            emojiBackground.topAnchor.constraint(equalTo: colorView.topAnchor, constant: 12),
            emojiBackground.leadingAnchor.constraint(equalTo: colorView.leadingAnchor, constant: 12),
            emojiBackground.widthAnchor.constraint(equalToConstant: 24),
            emojiBackground.heightAnchor.constraint(equalToConstant: 24),
            
            emojiLabel.centerXAnchor.constraint(equalTo: emojiBackground.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiBackground.centerYAnchor),

            titleLabel.bottomAnchor.constraint(equalTo: colorView.bottomAnchor, constant: -12),
            titleLabel.leadingAnchor.constraint(equalTo: colorView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: colorView.trailingAnchor, constant: -12),
            
            plusButton.topAnchor.constraint(equalTo: colorView.bottomAnchor, constant: 8),
            plusButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            plusButton.widthAnchor.constraint(equalToConstant: 34),
            plusButton.heightAnchor.constraint(equalToConstant: 34),
            
            daysLabel.centerYAnchor.constraint(equalTo: plusButton.centerYAnchor),
            daysLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12)
        ])
    }

    func configure(with tracker: Tracker, isDone: Bool, days: Int, indexPath: IndexPath) {
        self.trackerId = tracker.id
        self.indexPath = indexPath
        self.isDone = isDone
        
        colorView.backgroundColor = tracker.color
        emojiLabel.text = "\(tracker.emoji)"
        titleLabel.text = tracker.name
        daysLabel.text = format(days: days)
        
        plusButton.backgroundColor = tracker.color
        if (isDone) {
            plusButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
        } else {
            plusButton.setImage(UIImage(systemName: "plus"), for: .normal)
        }
    }
    
    private func format(days: Int) -> String {
        let lastDigit = days % 10
        let lastTwoDigits = days % 100
        if lastTwoDigits >= 11 && lastTwoDigits <= 19 {
            return "\(days) дней"
        }
        
        switch lastDigit {
        case 1:
            return "\(days) день"
        case 2, 3, 4:
            return "\(days) дня"
        default:
            return "\(days) дней"
        }
    }
    
    @objc func plusButtonPressed() {
        guard let trackerId = trackerId, let indexPath = indexPath else { return }
        if isDone {
            delegate?.uncompleteTracker(id: trackerId, at: indexPath)
        } else {
            delegate?.completeTracker(id: trackerId, at: indexPath)
        }
    }
}
