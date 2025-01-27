//
//  StatisticViewController.swift
//  Tracker
//
//  Created by Alibi Mailan on 27.01.2025.
//

import UIKit

final class StatisticViewController: UIViewController {
    
    private let trackerStore = TrackerStore()
    private let recordStore = TrackerRecordStore()
    let cellReuseIdentifier = "StatisticViewController"
    var trackersViewController: TrackersViewController?
    
    private var bestPeriod: Int?
    private var idealDays: Int?
    private var completedTrackers: Int?
    private var avarageCompletedTrackers: Int?
    
    private let header: UILabel = {
        let header = UILabel()
        header.translatesAutoresizingMaskIntoConstraints = false
        header.text = "Статистика"
        header.textColor = .ypText
        header.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        return header
    }()
    
    private let emptyStatistic: UIImageView = {
        let emptySearch = UIImageView()
        emptySearch.translatesAutoresizingMaskIntoConstraints = false
        emptySearch.image = UIImage(named: "no-statistics")
        return emptySearch
    }()
    
    private let emptyStatisticText: UILabel = {
        let emptySearchText = UILabel()
        emptySearchText.translatesAutoresizingMaskIntoConstraints = false
        emptySearchText.text = "Анализировать пока нечего"
        emptySearchText.textColor = .ypText
        emptySearchText.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return emptySearchText
    }()
    
    private let statisticTableView: UITableView = {
        let statisticTableView = UITableView()
        statisticTableView.separatorStyle = .none
        statisticTableView.layer.cornerRadius = 16
        statisticTableView.translatesAutoresizingMaskIntoConstraints = false
        return statisticTableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBackgroundLight
        addSubviews()
        
        statisticTableView.backgroundColor = .ypBackgroundLight
        statisticTableView.delegate = self
        statisticTableView.dataSource = self
        statisticTableView.register(StatisticCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        statisticTableView.reloadData()
        
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            header.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            emptyStatistic.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStatistic.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 246),
            emptyStatistic.heightAnchor.constraint(equalToConstant: 80),
            emptyStatistic.widthAnchor.constraint(equalToConstant: 80),
            emptyStatisticText.centerXAnchor.constraint(equalTo: emptyStatistic.centerXAnchor),
            emptyStatisticText.topAnchor.constraint(equalTo: emptyStatistic.bottomAnchor, constant: 8),
            statisticTableView.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 77),
            statisticTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statisticTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            statisticTableView.heightAnchor.constraint(equalToConstant: 500)
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showPlaceholder()
        calculateStatistics()
        statisticTableView.reloadData()
    }
    
    private func addSubviews() {
        view.addSubview(header)
        view.addSubview(emptyStatistic)
        view.addSubview(emptyStatisticText)
        view.addSubview(statisticTableView)
    }
    
    private func calculateStatistics() {
        bestPeriod = largestConsecutivePeriod(objects: recordStore.trackerRecords)
        idealDays = countIdealDays(objects: recordStore.trackerRecords)
        completedTrackers = recordStore.trackerRecords.count
        avarageCompletedTrackers = averageDailyCountAsInt(objects: recordStore.trackerRecords)
    }
    
    private func largestConsecutivePeriod(objects: [TrackerRecord]) -> Int {
        guard !objects.isEmpty else { return 0 }
        let sorted = objects.sorted { $0.date < $1.date }
        
        var maxStreak = 1
        var currentStreak = 1
        
        let calendar = Calendar.current
        
        for i in 1..<sorted.count {
            let current = sorted[i]
            let previous = sorted[i - 1]
            
            if current.id == previous.id {
                let dayDiff = calendar.dateComponents([.day], from: previous.date, to: current.date).day ?? 0
                
                if dayDiff == 1 {
                    currentStreak += 1
                    maxStreak = max(maxStreak, currentStreak)
                } else {
                    currentStreak = 1
                }
            } else {
                currentStreak = 1
            }
        }
        
        return maxStreak
    }
    
    func countIdealDays(objects: [TrackerRecord]) -> Int {
        let allTypes = Set(objects.map(\.id))
        
        let calendar = Calendar.current
        func startOfDay(for date: Date) -> Date {
            return calendar.startOfDay(for: date)
        }

        let groupedByDate: [Date: [TrackerRecord]] = Dictionary(grouping: objects, by: {
            startOfDay(for: $0.date)
        })
        
        var idealDaysCount = 0
        for (_, dailyObjects) in groupedByDate {
            let typesForDay = Set(dailyObjects.map(\.id))
            if typesForDay == allTypes {
                idealDaysCount += 1
            }
        }

        return idealDaysCount
    }
    
    func averageDailyCountAsInt(objects: [TrackerRecord]) -> Int {
        guard !objects.isEmpty else { return 0 }

        let calendar = Calendar.current

        let groupedByDay = Dictionary(grouping: objects) {
            calendar.startOfDay(for: $0.date)
        }

        let totalDays = groupedByDay.count
        let totalObjects = objects.count

        let averageDouble = Double(totalObjects) / Double(totalDays)
        
        return Int(round(averageDouble))
    }
    
    private func showPlaceholder() {
        if recordStore.trackerRecords.isEmpty || trackerStore.trackers.isEmpty {
            emptyStatistic.isHidden = false
            emptyStatisticText.isHidden = false
            
            statisticTableView.isHidden = true
        } else {
            emptyStatistic.isHidden = true
            emptyStatisticText.isHidden = true
            
            statisticTableView.isHidden = false
        }
    }
}

// MARK: - UITableViewDelegate
extension StatisticViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 102
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 12
    }
}

// MARK: - UITableViewDataSource
extension StatisticViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as? StatisticCell else { return UITableViewCell() }
        
        var title = ""
        
        switch indexPath.row {
        case 0:
            title = "Лучший период"
        case 1:
            title = "Идеальные дни"
        case 2:
            title = "Трекеров завершено"
        case 3:
            title = "Среднее значение"
        default:
            break
        }
        
        var count = ""
        
        switch indexPath.row {
        case 0:
            count = "\(bestPeriod ?? 0)"
        case 1:
            count = "\(idealDays ?? 0)"
        case 2:
            count = "\(completedTrackers ?? 0)"
        case 3:
            count = "\(avarageCompletedTrackers ?? 0)"
        default:
            break
        }
        
        cell.update(with: title, count: count)
        cell.selectionStyle = .none
        cell.isUserInteractionEnabled = false
        
        return cell
    }
}

