//
//  SelectItemCollectionView.swift
//  Tracker
//
//  Created by Alibi Mailan
//

import UIKit

class SelectItemCollectionView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private var items: [Any] = []
    
    var onItemSelected: ((Int) -> Void)?
    
    private var selectedIndex: Int?
    
    init(items: [Any], cellSize: CGSize = CGSize(width: 52, height: 52)) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 0
        layout.itemSize = cellSize
        
        super.init(frame: .zero, collectionViewLayout: layout)
        self.items = items
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.delegate = self
        self.dataSource = self
        self.backgroundColor = .clear
        self.isScrollEnabled = false
        self.register(SelectItemCollectionViewCell.self, forCellWithReuseIdentifier: "SelectItemCell")
    }
    
    // MARK: - UICollectionView DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectItemCell", for: indexPath) as! SelectItemCollectionViewCell
        
        if let color = items[indexPath.item] as? UIColor {
            cell.configureWithColor(color, isSelected: indexPath.item == selectedIndex)
        } else if let emoji = items[indexPath.item] as? String {
            cell.configureWithEmoji(emoji, isSelected: indexPath.item == selectedIndex)
        }
        
        return cell
    }
    
    // MARK: - UICollectionView Delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.item
        reloadData()
        onItemSelected?(indexPath.item)
    }
}


