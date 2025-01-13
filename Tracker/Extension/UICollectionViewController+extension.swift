//
//  UICollectionViewController+extension.swift
//  Tracker
//
//  Created by Alibi Mailan
//

import UIKit

extension UICollectionView {

        func setEmptyMessage(_ message: String,_ img:UIImage) {
            let mainView = UIView()
            
            let stack = UIStackView()
            stack.alignment = .center
            stack.spacing = 8
            stack.translatesAutoresizingMaskIntoConstraints = false
            stack.axis = .vertical
            mainView.addSubview(stack)
            
            let image = UIImageView()
            image.contentMode = .scaleAspectFit
            image.image = img
            image.translatesAutoresizingMaskIntoConstraints = false
            stack.addArrangedSubview(image)
            
            let messageLabel = UILabel()
            messageLabel.text = message
            messageLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
            messageLabel.textColor = .ypText
            messageLabel.numberOfLines = 0
            messageLabel.textAlignment = .center
            messageLabel.sizeToFit()
            messageLabel.translatesAutoresizingMaskIntoConstraints = false
            stack.addArrangedSubview(messageLabel)
           
            NSLayoutConstraint.activate([
                image.widthAnchor.constraint(equalToConstant: 80),
                image.heightAnchor.constraint(equalToConstant: 80),
                
                stack.centerYAnchor.constraint(equalTo: mainView.centerYAnchor),
                stack.centerXAnchor.constraint(equalTo: mainView.centerXAnchor)
            ])
            
            self.backgroundView = mainView
        }
        
        func restoreBackgroundView() {
            self.backgroundView = nil
        }
    }
