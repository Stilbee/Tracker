//
//  SelectItemCollectionViewCell.swift
//  Tracker
//
//  Created by Alibi Mailan
//


import UIKit

class SelectItemCollectionViewCell: UICollectionViewCell {
    
    private let colorItemSelectedView = UIView()
    private let colorItemView = UIView()
    
    private let emojiItemSelectedView = UIView()
    private let emojiLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        colorItemSelectedView.layer.cornerRadius = 8
        colorItemSelectedView.layer.borderWidth = 3
        colorItemSelectedView.layer.masksToBounds = true
        colorItemSelectedView.backgroundColor = .clear
        colorItemSelectedView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(colorItemSelectedView)
        
        colorItemView.layer.cornerRadius = 8
        colorItemView.layer.masksToBounds = true
        colorItemView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(colorItemView)
        
        emojiItemSelectedView.layer.cornerRadius = 16
        emojiItemSelectedView.layer.masksToBounds = true
        emojiItemSelectedView.backgroundColor = UIColor(hex: "#E6E8EB")
        emojiItemSelectedView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(emojiItemSelectedView)
        
        emojiLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(emojiLabel)
        
        NSLayoutConstraint.activate([
            colorItemSelectedView.topAnchor.constraint(equalTo: contentView.topAnchor),
            colorItemSelectedView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            colorItemSelectedView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            colorItemSelectedView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            colorItemView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            colorItemView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            colorItemView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 6),
            colorItemView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -6),
            
            emojiItemSelectedView.topAnchor.constraint(equalTo: contentView.topAnchor),
            emojiItemSelectedView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            emojiItemSelectedView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            emojiItemSelectedView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
    }
    
    func configureWithColor(_ color: UIColor, isSelected: Bool) {
        colorItemSelectedView.isHidden = !isSelected
        colorItemSelectedView.layer.borderColor = color.withAlphaComponent(0.3).cgColor
        colorItemView.backgroundColor = color
        
        emojiItemSelectedView.isHidden = true
        emojiLabel.isHidden = true
    }
    
    func configureWithEmoji(_ emoji: String, isSelected: Bool) {
        emojiItemSelectedView.isHidden = !isSelected
        emojiLabel.isHidden = false
        emojiLabel.text = emoji
        
        colorItemSelectedView.isHidden = true
        colorItemView.isHidden = true
    }
}
