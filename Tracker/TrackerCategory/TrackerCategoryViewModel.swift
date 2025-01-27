//
//  TrackerCategoryViewModel.swift
//  Tracker
//
//  Created by Alibi Mailan
//

final class TrackerCategoryViewModel {
    
    static let shared = TrackerCategoryViewModel()
    private var categoryStore = TrackerCategoryStore.shared
    private(set) var categories: [TrackerCategory] = []
    
    private init() {
        categoryStore.delegate = self
        self.categories = categoryStore.trackerCategories
    }
    
    func addCategory(_ toAdd: String) {
        try? self.categoryStore.addNewCategory(TrackerCategory(name: toAdd, trackers: []))
    }
    
    func addTrackerToCategory(to trackerCategory: TrackerCategory?, tracker: Tracker) {
        try? self.categoryStore.addTrackerToCategory(to: trackerCategory, tracker: tracker)
    }
    
    func removeTrackerFromCategory(of trackerCategory: TrackerCategory?, tracker: Tracker) {
        try? self.categoryStore.remove(from: trackerCategory, tracker: tracker)
    }
}

extension TrackerCategoryViewModel: TrackerCategoryStoreDelegate {
    func storeCategory() {
        self.categories = categoryStore.trackerCategories
    }
}
