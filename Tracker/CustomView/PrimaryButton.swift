//
//  PrimaryButton.swift
//  Tracker
//
//  Created by Alibi Mailan
//

import UIKit

class PrimaryButton: UIButton {

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
        setTitleColor(.white, for: .normal)
        backgroundColor = UIColor.black
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
