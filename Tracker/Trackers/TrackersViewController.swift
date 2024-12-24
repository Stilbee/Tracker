//
//  TrackerCollectionVC.swift
//  Tracker
//
//  Created by Alibi Mailan
//

import Foundation
import UIKit

class TrackersViewController: UICollectionViewController, UISearchResultsUpdating {
    
    private var trackerStore = TrackerStore()
    private let trackerCategoryStore = TrackerCategoryStore()
    private var trackerRecordStore = TrackerRecordStore()
    
    private(set) var categoryViewModel = TrackerCategoryViewModel.shared
    
    private var currentDate = Date()
    private var selectedDay: Int?
    private var filterText: String?
    private let datePicker = UIDatePicker()
    
    private var trackers: [Tracker] = []
    private var pinnedTrackers: [Tracker] = []
    
    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []
    
    private var completedTrackers: [TrackerRecord] = []
    
    private let searchController = UISearchController(searchResultsController: nil)
    private let searchBar: UISearchBar = {
        let search = UISearchBar()
        search.placeholder = "Search"
        search.translatesAutoresizingMaskIntoConstraints = false
        search.sizeToFit()
        search.barStyle = .default
        return search
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStore()
        setupViews()
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
        setupNavigationBar()
        collectionView.backgroundColor = .white
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.identifier)
        collectionView.register(TrackerSectionHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: TrackerSectionHeader.identifier)
        collectionView.collectionViewLayout = createLayout()
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
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.title = "Трекеры"
        
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.calendar = Calendar(identifier: .gregorian)
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        
        navigationItem.leftBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
        ]
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск"
        searchController.searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchController.isActive = true
        definesPresentationContext = true
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func completedTrackersToday() {
        trackers = trackerStore.trackers.filter { isTrackerCompletedToday(id: $0.id) }
        
        filterVisibleCategories()
        collectionView.reloadData()
    }
    
    private func unCompletedTrackersToday() {
        trackers = trackerStore.trackers.filter { !isTrackerCompletedToday(id: $0.id) }
        filterVisibleCategories()
        collectionView.reloadData()
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
        filterTrackers(forToday: false)
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visibleCategories.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleCategories[section].trackers.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.identifier, for: indexPath) as! TrackerCell
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
        header.titleLabel.text = categories[indexPath.section].name
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
    
    private func filterTrackers(forToday: Bool = false) {
        filterVisibleCategories(forToday: forToday)
        showVisibleViews()
        collectionView.reloadData()
    }
    
    private func filterVisibleCategories(forToday: Bool = false) {
        visibleCategories = categories.map { category in
            if category.name == "Закрепленные" {
                return TrackerCategory(name: category.name, trackers: pinnedTrackers.filter { tracker in
                    return tracker.name.contains(self.filterText ?? "") || (self.filterText ?? "").isEmpty
                })
            } else {
                return TrackerCategory(name: category.name, trackers: trackers.filter { tracker in
                    let categoriesContains = category.trackers.contains { $0.id == tracker.id }
                    let pinnedContains = pinnedTrackers.contains{ $0.id == tracker.id }
                    let scheduleContains = forToday ? (tracker.schedule?.contains { day in
                        guard let currentDay = self.selectedDay else {
                            return true
                        }
                        return day.rawValue == currentDay
                    } ?? false) : true
                    
                    
                    let titleContains = tracker.name.contains(self.filterText ?? "") || (self.filterText ?? "").isEmpty
                    return scheduleContains && titleContains && categoriesContains && !pinnedContains
                })
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
                    return TrackerCategory(name: ctgry.name, trackers: ctgry.trackers)
                }
            }
        } else {
            self.categories.append(TrackerCategory(name: category, trackers: [tracker]))
        }
        filterTrackers()
    }
    
    func updateTracker(tracker: Tracker, oldTracker: Tracker?, category: String?) {
        
    }
    
    func reload() {
        self.collectionView.reloadData()
    }
}

extension TrackersViewController: TrackerStoreDelegate {
    func store() {
        let fromDb = trackerStore.trackers
        trackers = fromDb.filter { !$0.pinned }
        pinnedTrackers = fromDb.filter { $0.pinned }
        filterVisibleCategories()
        collectionView.reloadData()
    }
}

extension TrackersViewController: TrackerRecordStoreDelegate {
    func storeRecord() {
        completedTrackers = trackerRecordStore.trackerRecords
        collectionView.reloadData()
    }
}
