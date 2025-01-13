//
//  ButtonsTableView.swift
//  Tracker
//
//  Created by Alibi Mailan
//

import UIKit

final class ButtonsTableView: UITableView {
    
    private var items: [TableButtonItem]
    
    var onItemSelected: ((Int) -> Void)?
    
    init(items: [TableButtonItem]) {
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
        self.register(UITableViewCell.self, forCellReuseIdentifier: "ButtonCell")
        self.layer.cornerRadius = 16
        self.isScrollEnabled = false
        self.backgroundColor = .ypBackground2
        self.separatorStyle = .none
    }
    
    func updateSubtitle(index: Int, subtitle: String) {
        items[index].subtitle = subtitle
        reloadData()
    }
}

// MARK: UITableViewDataSource
extension ButtonsTableView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "ButtonCell")
        
        cell.textLabel?.text = items[indexPath.row].title
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17)
        cell.detailTextLabel?.text = items[indexPath.row].subtitle
        cell.detailTextLabel?.textColor = .ypGray
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 17)
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = .ypBackground2
        
        return cell
    }
}


// MARK: UITableViewDelegate
extension ButtonsTableView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        onItemSelected?(indexPath.row)
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
