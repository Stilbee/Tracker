//
//  TrackerCollectionVC.swift
//  Tracker
//
//  Created by Alibi Mailan
//

import Foundation
import UIKit

final class TrackersViewController: UICollectionViewController, UISearchResultsUpdating {
    
    private var trackerStore = TrackerStore()
    private let trackerCategoryStore = TrackerCategoryStore()
    private var trackerRecordStore = TrackerRecordStore()
    
    private(set) var categoryViewModel = TrackerCategoryViewModel.shared
    private let analytics = Analytics.shared
    
    private var currentDate = Date()
    private var selectedDay: Int?
    private var filterText: String?
    private let datePicker = UIDatePicker()
    
    private var trackers: [Tracker] = []
    private var pinnedTrackers: [Tracker] = []
    
    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []
    
    private(set) var completedTrackers: [TrackerRecord] = []
    
    private let searchController = UISearchController(searchResultsController: nil)
    private let searchBar: UISearchBar = {
        let search = UISearchBar()
        search.placeholder = "Search"
        search.translatesAutoresizingMaskIntoConstraints = false
        search.sizeToFit()
        search.barStyle = .default
        return search
    }()
    
    private var filtersButton: UIButton = {
        let filtersButton = UIButton()
        filtersButton.layer.cornerRadius = 16
        filtersButton.backgroundColor = .ypBlue
        filtersButton.setTitle(NSLocalizedString("filter.title", comment: ""), for: .normal)
        filtersButton.translatesAutoresizingMaskIntoConstraints = false
        return filtersButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStore()
        setupViews()
        dateChanged(datePicker)
    }
    
    private func setupStore() {
        trackerStore.delegate = self
        trackerRecordStore.delegate = self
        trackers = trackerStore.trackers.filter { !$0.pinned }
        pinnedTrackers = trackerStore.trackers.filter { $0.pinned }
        completedTrackers = trackerRecordStore.trackerRecords
        categories = categoryViewModel.categories
        categories.insert(TrackerCategory(name: "Закрепленные", trackers: pinnedTrackers), at: 0)
        filterVisibleCategories()
    }
    
    private func setupViews() {
        view.backgroundColor = .ypBackgroundLight
        view.addSubview(filtersButton)
        filtersButton.addTarget(self, action: #selector(filtersButtonTapped), for: .touchUpInside)
        
        setupNavigationBar()
        
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.identifier)
        collectionView.register(TrackerSectionHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: TrackerSectionHeader.identifier)
        collectionView.collectionViewLayout = createLayout()
        collectionView.delegate = self
        collectionView.backgroundColor = .ypBackgroundLight
        
        NSLayoutConstraint.activate([
            filtersButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 130),
            filtersButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -130),
            filtersButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100),
            filtersButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout(sectionProvider: { (sectionIndex, environment) -> NSCollectionLayoutSection? in
            let fraction: CGFloat = 1 / 2
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(fraction), heightDimension: .absolute(148))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 9, bottom: 0, trailing: 0)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(148))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
            
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(46))
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
            section.boundarySupplementaryItems = [header]
            
            return section
        })
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .ypBackgroundLight
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.title = NSLocalizedString("trackers.title", comment: "")
        
        datePicker.datePickerMode = .date
        datePicker.tintColor = .ypBlue
        datePicker.preferredDatePickerStyle = .compact
        datePicker.calendar = Calendar(identifier: .gregorian)
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
        addButton.tintColor = .ypText
        navigationItem.leftBarButtonItems = [addButton]
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = NSLocalizedString("search.placeholder", comment: "")
        searchController.searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchController.isActive = true
        searchController.searchBar.tintColor = .ypBackgroundDark
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func isTrackerCompletedToday(id: UUID) -> Bool {
        completedTrackers.contains { trackerRecord in
            isSameTrackerRecord(trackerRecord: trackerRecord, id: id)
        }
    }
    
    private func isSameTrackerRecord(trackerRecord: TrackerRecord, id: UUID) -> Bool {
        let isSameDay = Calendar.current.isDate(trackerRecord.date, inSameDayAs: currentDate)
        return trackerRecord.id == id && isSameDay
    }

    @objc private func didTapAdd() {
        let trackerTypeSelectionVC = TrackerTypeSelectionViewController()
        trackerTypeSelectionVC.trackersViewController = self
        let navVC = UINavigationController(rootViewController: trackerTypeSelectionVC)
        navVC.modalPresentationStyle = .popover
        self.present(navVC, animated: true, completion: nil)
    }
    
    @objc private func dateChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: currentDate)
        selectedDay = (weekday + 5) % 7 + 1
        filterTrackers()
    }
    
    @objc private func filtersButtonTapped() {
        analytics.report("click", params: ["target": "filterButton"])
        let filterViewController = FilterViewController()
        filterViewController.delegate = self
        present(filterViewController, animated: true)
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visibleCategories.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleCategories[section].trackers.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.identifier, for: indexPath) as? TrackerCell else {
            return UICollectionViewCell()
        }
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        let isCompletedToday = isTrackerCompletedToday(id: tracker.id)
        let completedDays = completedTrackers.filter {
            $0.id == tracker.id
        }.count
        cell.configure(with: tracker, isDone: isCompletedToday, days: completedDays, indexPath: indexPath)
        cell.delegate = self
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TrackerSectionHeader.identifier, for: indexPath) as! TrackerSectionHeader
        header.titleLabel.text = visibleCategories[indexPath.section].name
        return header
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
    func showVisibleViews() {
        if trackerStore.trackers.count == 0 || visibleCategories.isEmpty {
            self.collectionView.setEmptyMessage("Что будем отслеживать?", UIImage(named: "il-error-1") ?? UIImage())
        } else {
            self.collectionView.restoreBackgroundView()
        }
        
        collectionView.reloadData()
    }
    
    private func filterTrackers() {
        filterVisibleCategories()
        showVisibleViews()
        collectionView.reloadData()
    }
    
    private func filterVisibleCategories() {
        visibleCategories = categories.map { category in
            if category.name == "Закрепленные" {
                let filteredTrackers = pinnedTrackers.filter { tracker in
                    return tracker.name.contains(self.filterText ?? "") || (self.filterText ?? "").isEmpty
                }
                return TrackerCategory(name: category.name, trackers: filteredTrackers)
            } else {
                let filteredTrackers = trackers.filter { tracker in
                    let categoriesContains = category.trackers.contains { $0.id == tracker.id }
                    let pinnedContains = pinnedTrackers.contains{ $0.id == tracker.id }
                    let titleContains = (self.filterText ?? "").isEmpty
                        || tracker.name.localizedCaseInsensitiveContains(self.filterText ?? "")
                    let scheduleContains = tracker.schedule?.contains(where: { dayOfWeek in
                        guard let currentDate = self.selectedDay else { return true }
                        return dayOfWeek.rawValue == currentDate
                    }) ?? true
                    return scheduleContains && titleContains && categoriesContains && !pinnedContains
                }
                return TrackerCategory(name: category.name, trackers: filteredTrackers)
            }
        }
        .filter { category in
            !category.trackers.isEmpty
        }
        showVisibleViews()
    }
}

extension TrackersViewController: TrackerCellDelegate {
    func completeTracker(id: UUID, at indexPath: IndexPath) {
        let currentDate = Date()
        let calendar = Calendar.current
        let selectedDate = datePicker.date
        if calendar.compare(selectedDate, to: currentDate, toGranularity: .day) != .orderedDescending {
            let trackerRecord = TrackerRecord(id: id, date: selectedDate)
            try?
            self.trackerRecordStore.addNewTrackerRecord(trackerRecord)
            collectionView.reloadItems(at: [indexPath])
        } else {
            return
        }
    }
    
    func uncompleteTracker(id: UUID, at indexPath: IndexPath) {
        let toRemove = completedTrackers.first {
            isSameTrackerRecord(trackerRecord: $0, id: id)
        }
        try? self.trackerRecordStore.removeTrackerRecord(toRemove)
    }
}

extension TrackersViewController: SaveTrackerViewControllerDelegate {
    func appendTracker(tracker: Tracker, category: String?) {
        guard let category = category else { return }
        self.trackerStore.addNewTracker(tracker)
        let foundCategory = self.categories.first { categoryLoop in
            categoryLoop.name == category
        }
        if foundCategory != nil {
            self.categories = self.categories.map { categoryLoop in
                if (categoryLoop.name == category) {
                    var updatedTrackers = categoryLoop.trackers
                    updatedTrackers.append(tracker)
                    return TrackerCategory(name: categoryLoop.name, trackers: updatedTrackers)
                } else {
                    return TrackerCategory(name: categoryLoop.name, trackers: categoryLoop.trackers)
                }
            }
        } else {
            self.categories.append(TrackerCategory(name: category, trackers: [tracker]))
        }
        filterTrackers()
    }
    
    func updateTracker(tracker: Tracker, oldTracker: Tracker?, category: String?) {
        guard let category = category, let oldTracker = oldTracker else { return }
        try? self.trackerStore.updateTracker(tracker, oldTracker: oldTracker)
        let foundCategory = self.categories.first { ctgry in
            ctgry.name == category
        }
        if foundCategory != nil {
            self.categories = self.categories.map { ctgry in
                if (ctgry.name == category) {
                    var updatedTrackers = ctgry.trackers
                    updatedTrackers.append(tracker)
                    return TrackerCategory(name: ctgry.name, trackers: updatedTrackers)
                } else {
                    return TrackerCategory(name: ctgry.name, trackers: ctgry.trackers.filter({$0.id != oldTracker.id}))
                }
            }
        } else {
            self.categories.append(TrackerCategory(name: category, trackers: [tracker]))
        }
        filterTrackers()
    }
    
    func reload() {
        self.collectionView.reloadData()
    }
}

extension TrackersViewController: TrackerStoreDelegate {
    func store() {
        let fromDatabase = trackerStore.trackers
        trackers = fromDatabase.filter { !$0.pinned }
        pinnedTrackers = fromDatabase.filter { $0.pinned }
        filterTrackers()
    }
}

extension TrackersViewController: TrackerRecordStoreDelegate {
    func storeRecord() {
        completedTrackers = trackerRecordStore.trackerRecords
        collectionView.reloadData()
    }
}

extension TrackersViewController {
    
    override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        let tracker = self.visibleCategories[indexPath.section].trackers[indexPath.row]
        
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: { [weak self] () -> UIViewController? in
            guard let self = self else { return nil }
            
            let previewVC = TrackerPreviewViewController()
            let cellSize = CGSize(width: self.collectionView.bounds.width / 2 - 5, height: (self.collectionView.bounds.width / 2 - 5) * 0.55)
            previewVC.configureView(sizeForPreview: cellSize, tracker: tracker)
            
            return previewVC
        }) { [weak self] _ in
            let pinAction: UIAction
            if tracker.pinned {
                pinAction = UIAction(title: "Открепить", handler: { [weak self] _ in
                    try? self?.trackerStore.pinTracker(tracker, value: false)
                })
            } else {
                pinAction = UIAction(title: "Закрепить", handler: { [weak self] _ in
                    try? self?.trackerStore.pinTracker(tracker, value: true)
                })
            }
            
            let editAction = UIAction(title: "Редактировать", handler: { [weak self] _ in
                guard let self = self else { return }
                self.analytics.report("click", params: ["target": "editTracker"])
                let saveTrackerVC = SaveTrackerViewController()
                saveTrackerVC.delegate = self
                saveTrackerVC.edit(tracker: tracker,
                              category: self.categories.first {
                                  $0.trackers.contains {
                                      $0.id == tracker.id
                                  }
                              }
                )
                let navVC = UINavigationController(rootViewController: saveTrackerVC)
                navVC.modalPresentationStyle = .popover
                self.present(navVC, animated: true, completion: nil)
            })
            
            let deleteAction = UIAction(title: "Удалить", attributes: .destructive) { [weak self] _ in
                guard let self = self else { return }
                self.analytics.report("click", params: ["target": "deleteTracker"])
                
                let alertController = UIAlertController(title: nil, message: "Уверены что хотите удалить трекер?", preferredStyle: .actionSheet)
                let deleteConfirmationAction = UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
                    try? self?.trackerStore.deleteTracker(tracker)
                    self?.uncompleteTracker(id: tracker.id, at: indexPath)
                    self?.showVisibleViews()
                }
                alertController.addAction(deleteConfirmationAction)
                
                let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
                alertController.addAction(cancelAction)
                
                self.present(alertController, animated: true, completion: nil)
            }
            
            let actions = [pinAction, editAction, deleteAction]
            return UIMenu(title: "", children: actions)
        }
        
        return configuration
    }
}

// MARK: - TrackerStoreDelegate

extension TrackersViewController: FilterViewControllerDelegate {
    func allTrackers() {
        trackers = trackerStore.trackers
        filterTrackers()
    }
    
    func trackersToday() {
        let weekday = Calendar.current.component(.weekday, from: Date())
        
        trackers = trackerStore.trackers.filter {
            $0.schedule?.contains(where: { $0.rawValue ==  weekday}) ?? false
        }
        
        filterTrackers()
    }
    
    func completedTrackersToday() {
        analytics.report("click", params: ["target": "completeTracker"])
        trackers = trackerStore.trackers.filter { isTrackerCompletedToday(id: $0.id) }
        
        filterTrackers()
    }
        
    func unCompletedTrackersToday() {
        analytics.report("click", params: ["target": "uncompleteTracker"])
        trackers = trackerStore.trackers.filter { !isTrackerCompletedToday(id: $0.id) }
        filterTrackers()
    }
}

extension TrackersViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterText = searchText
        filterTrackers()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        filterText = searchBar.text
        filterTrackers()
    }
}
