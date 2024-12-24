//
//  UITextField+extension.swift
//  Tracker
//
//  Created by Alibi Mailan
//

import UIKit

extension UITextField {
    public static func primary(_ placeholder: String) -> UITextField {
        let textField = TextField()
        textField.placeholder = placeholder
        textField.font = UIFont.systemFont(ofSize: 17)
        textField.borderStyle = .none
        textField.clearButtonMode = .whileEditing
        textField.backgroundColor = .ypBackground2
        textField.layer.cornerRadius = 16
        textField.clearButtonMode = .whileEditing
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.heightAnchor.constraint(equalToConstant: 75).isActive = true
        return textField
    }
}


class TextField: UITextField {

    let padding = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 32)

    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}
