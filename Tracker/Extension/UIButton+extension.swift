//
//  UIButton+extension.swift
//  Tracker
//
//  Created by Alibi Mailan
//

import UIKit

extension UIButton {
    public static func primaryButton(_ title: String) -> UIButton {
        let primaryButton = UIButton(type: .system)
        primaryButton.setTitle(title, for: .normal)
        primaryButton.setTitleColor(.white, for: .normal)
        primaryButton.backgroundColor = UIColor.black
        primaryButton.layer.cornerRadius = 16
        primaryButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        primaryButton.translatesAutoresizingMaskIntoConstraints = false
        return primaryButton
    }
    
    public static func cancelButton(_ title: String) -> UIButton {
        let primaryButton = UIButton(type: .system)
        primaryButton.setTitle(title, for: .normal)
        primaryButton.setTitleColor(UIColor(hex: "#F56B6C"), for: .normal)
        primaryButton.backgroundColor = UIColor.clear
        primaryButton.layer.cornerRadius = 16
        primaryButton.layer.borderWidth = 1
        primaryButton.layer.borderColor = UIColor(hex: "#F56B6C").cgColor
        primaryButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        primaryButton.translatesAutoresizingMaskIntoConstraints = false
        return primaryButton
    }
}
