//
//  ButtonsTableView.swift
//  Tracker
//
//  Created by Alibi Mailan
//

import UIKit

final class SelectItemTableView: UITableView, UITableViewDelegate, UITableViewDataSource {
    
    private var items: [String]
    
    var onItemSelected: ((Int?) -> Void)?
    
    private var selectedIndex: Int?
    
    init(items: [String]) {
        self.items = items
        super.init(frame: .zero, style: .plain)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.delegate = self
        self.dataSource = self
        self.register(UITableViewCell.self, forCellReuseIdentifier: "SelectItemTableViewCell")
        self.layer.cornerRadius = 16
        self.isScrollEnabled = false
        self.separatorStyle = .none
    }
    
    func updateItems(_ items: [String]) {
        self.items = items
        reloadData()
    }
    
    // MARK: - TableView DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectItemTableViewCell")
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: "SelectItemTableViewCell")
        
        cell.textLabel?.text = items[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17)
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 17)
        if (selectedIndex == indexPath.row) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        cell.backgroundColor = .ypBackground2
        
        let isLastCell = indexPath.row == items.count - 1
        if isLastCell {
            cell.layer.cornerRadius = 16
            cell.layer.masksToBounds = true
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else {
            cell.layer.cornerRadius = 0
            cell.layer.masksToBounds = false
        }
        
        return cell
    }
    
    // MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if (selectedIndex == indexPath.row) {
            selectedIndex = nil
        } else {
            selectedIndex = indexPath.row
        }
        reloadData()
        onItemSelected?(selectedIndex)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let separatorInset: CGFloat = 16
        let separatorWidth = tableView.bounds.width - separatorInset * 2
        let separatorHeight: CGFloat = 0.5
        let separatorX = separatorInset
        let separatorY = cell.frame.height - separatorHeight
        
        let isLastCell = indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1
        
        if !isLastCell {
            let separatorView = UIView(frame: CGRect(x: separatorX, y: separatorY, width: separatorWidth, height: separatorHeight))
            separatorView.backgroundColor = .ypGray
            cell.addSubview(separatorView)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
}
