//
//  SwitchTableViewCell.swift
//  Tracker
//
//  Created by Alibi Mailan
//


import UIKit

class SwitchTableViewCell: UITableViewCell {
    
    private let dayLabel = UILabel()
    private let daySwitch = UISwitch()
    
    var onSwitchToggle: ((Bool) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        dayLabel.font = UIFont.systemFont(ofSize: 17)
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(dayLabel)
        
        daySwitch.addTarget(self, action: #selector(switchToggled), for: .valueChanged)
        daySwitch.translatesAutoresizingMaskIntoConstraints = false
        daySwitch.onTintColor = .ypSwitcher
        contentView.addSubview(daySwitch)
        
        NSLayoutConstraint.activate([
            dayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            dayLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            daySwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            daySwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    func configure(with day: String, isOn: Bool) {
        dayLabel.text = day
        daySwitch.isOn = isOn
    }
    
    @objc private func switchToggled() {
        onSwitchToggle?(daySwitch.isOn)
    }
}
