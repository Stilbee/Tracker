//
//  FilterCell.swift
//  Tracker
//
//  Created by Alibi Mailan on 25.01.2025.
//

import UIKit

final class FilterCell: UITableViewCell {
    static let cellIdentifier = "FilterCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        backgroundColor = .ypBackgroundGray
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
