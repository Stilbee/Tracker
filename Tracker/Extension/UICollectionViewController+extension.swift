//
//  UICollectionViewController+extension.swift
//  Tracker
//
//  Created by Alibi Mailan
//

import UIKit

extension UICollectionView {

        func setEmptyMessage(_ message: String,_ img:UIImage) {
            
            let image = UIImageView()
            image.contentMode = .scaleAspectFit
            image.image = img
            
            
            let messageLabel = UILabel()
            messageLabel.text = message
            messageLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            messageLabel.textColor = .gray
            messageLabel.numberOfLines = 0
            messageLabel.textAlignment = .center
            messageLabel.sizeToFit()
            
            let mainView = UIView()
            mainView.addSubview(image)
            mainView.addSubview(messageLabel)
           
            image.translatesAutoresizingMaskIntoConstraints = false
            image.centerXAnchor.constraint(equalTo: mainView.centerXAnchor).isActive = true
            image.centerYAnchor.constraint(equalTo: mainView.centerYAnchor , constant: -40).isActive = true
            image.widthAnchor.constraint(equalToConstant: 80).isActive = true
            image.heightAnchor.constraint(equalToConstant: 80).isActive = true
            
            messageLabel.translatesAutoresizingMaskIntoConstraints = false
            messageLabel.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 20).isActive = true
            messageLabel.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 10).isActive = true
            messageLabel.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: 10).isActive = true
            
            self.backgroundView = mainView
        }
        
        func restoreBackgroundView() {
            self.backgroundView = nil
        }
    }
