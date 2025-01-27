//
//  PrimaryButton.swift
//  Tracker
//
//  Created by Alibi Mailan
//

import UIKit

final class PrimaryButton: UIButton {

    init(title: String) {
        super.init(frame: .zero)
        
        setTitle(title, for: .normal)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        setTitleColor(.ypTextLight, for: .normal)
        backgroundColor = .ypBackgroundDark
        layer.cornerRadius = 16
        titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    public func disable() {
        isEnabled = false
        backgroundColor = UIColor(hex: "#AEAFB4")
    }
    
    public func enable() {
        isEnabled = true
        backgroundColor = .black
    }
}
