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
    private(set) var selectedCategory: TrackerCategory?
    var onSelectCategory: ((TrackerCategory) -> Void)? = nil
    
    private init() {
        categoryStore.delegate = self
        self.categories = categoryStore.trackerCategories
    }
    
    func addCategory(_ toAdd: String) {
        try? self.categoryStore.addNewCategory(TrackerCategory(name: toAdd, trackers: []))
    }
    
    func addTrackerToCategory(to trackerCategory: TrackerCategory?, tracker: Tracker) {
        
    }
    
    func selectCategory(_ at: Int) {
        self.selectedCategory = self.categories[at]
        self.onSelectCategory?(self.categories[at] )
    }
}

extension TrackerCategoryViewModel: TrackerCategoryStoreDelegate {
    func storeCategory() {
        self.categories = categoryStore.trackerCategories
    }
}
