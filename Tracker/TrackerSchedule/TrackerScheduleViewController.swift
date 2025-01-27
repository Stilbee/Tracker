//
//  TrackerScheduleViewController.swift
//  Tracker
//
//  Created by Alibi Mailan
//

import UIKit

protocol TrackerScheduleDelegate: AnyObject {
    func save(weekDays: Set<DayOfWeek>)
}

final class TrackerScheduleViewController: UIViewController {
    
    weak var delegate: TrackerScheduleDelegate?
    
    var weekDays: Set<DayOfWeek> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .ypBackgroundLight
        navigationItem.hidesBackButton = true
        navigationItem.title = "Расписание"
        
        let tableView = SwitchesTableView(items: DayOfWeek.allCases.map(\.self.name))
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.onSwitchToggle = { [weak self] (index, value) in
            guard let self = self else { return }
            let dayOfWeek = DayOfWeek.allCases[index]
            if (value) {
                self.weekDays.insert(dayOfWeek)
            } else {
                self.weekDays.remove(dayOfWeek)
            }
        }
        view.addSubview(tableView)
        
        let doneButton = PrimaryButton(title: "Готово")
        doneButton.addTarget(self, action: #selector(onClickSave), for: .touchUpInside)
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 525),
            
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func onClickSave() {
        delegate?.save(weekDays: weekDays)
        navigationController?.popViewController(animated: true)
    }
}
