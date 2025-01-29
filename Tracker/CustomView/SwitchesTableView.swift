//
//  SwitchesTableView.swift
//  Tracker
//
//  Created by Alibi Mailan
//


import UIKit

final class SwitchesTableView: UITableView, UITableViewDelegate, UITableViewDataSource {

    private let items: [String]

    private var switchStates: [Bool]
    
    var onSwitchToggle: ((Int, Bool) -> Void)?
    
    init(items: [String]) {
        self.items = items
        self.switchStates = Array(repeating: false, count: items.count)
        super.init(frame: .zero, style: .plain)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.delegate = self
        self.dataSource = self
        self.register(SwitchTableViewCell.self, forCellReuseIdentifier: "SwitchCell")
        self.layer.cornerRadius = 16
        self.backgroundColor = .ypBackgroundGray
        self.separatorStyle = .none
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as? SwitchTableViewCell else {
            return SwitchTableViewCell(style: .default, reuseIdentifier: "SwitchCell")
        }
        
        cell.configure(with: items[indexPath.row], isOn: switchStates[indexPath.row])
        cell.selectionStyle = .none
        cell.onSwitchToggle = { [weak self] isOn in
            self?.switchStates[indexPath.row] = isOn
            self?.onSwitchToggle?(indexPath.row, isOn)
        }
        
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
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
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
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
}
