//
//  TrackerTypeSelectionViewController.swift
//  Tracker
//
//  Created by Alibi Mailan
//


import UIKit

final class TrackerTypeSelectionViewController: UIViewController {
    
    weak var trackersViewController: TrackersViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews() {
        view.backgroundColor = .ypBackground
        navigationItem.title = "Создание трекера"
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        let habitButton = UIButton.primaryButton("Привычка")
        habitButton.addTarget(self, action: #selector(habitButtonTapped), for: .touchUpInside)
        stackView.addArrangedSubview(habitButton)

        let irregularEventButton = UIButton.primaryButton("Нерегулярные событие")
        irregularEventButton.addTarget(self, action: #selector(irregularEventButtonTapped), for: .touchUpInside)
        stackView.addArrangedSubview(irregularEventButton)
        
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            habitButton.heightAnchor.constraint(equalToConstant: 60),
            irregularEventButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
    
    @objc private func habitButtonTapped() {
        toSaveTrackerVC(withSchedule: true)
    }
    
    @objc private func irregularEventButtonTapped() {
        toSaveTrackerVC(withSchedule: false)
    }
    
    private func toSaveTrackerVC(withSchedule: Bool) {
        let saveTrackerVC = SaveTrackerViewController()
        saveTrackerVC.delegate = trackersViewController
        saveTrackerVC.isRegular = withSchedule
        navigationController?.pushViewController(saveTrackerVC, animated: true)
    }
}
