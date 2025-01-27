//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Alibi Mailan
//

import UIKit
import CoreData

enum TrackerCategoryStoreError: Error {
    case decodingErrorInvalidTitle
    case decodingErrorInvalidTracker
    case decodingErrorInvalidFetchTitle
    case decodingErrorInvalid
}

protocol TrackerCategoryStoreDelegate: AnyObject {
    func storeCategory() -> Void
}

final class TrackerCategoryStore: NSObject {

    static let shared = TrackerCategoryStore()
    
    private var context: NSManagedObjectContext
    private lazy var fetchedResultsController = {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCategoryCoreData.name, ascending: true)
        ]
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
        try? controller.performFetch()
        return controller
    }()
    
    private let uiColorMarshalling = UIColorMarshalling()
    private let trackerStore = TrackerStore()
    
    weak var delegate: TrackerCategoryStoreDelegate?
    
    var trackerCategories: [TrackerCategory] {
        guard
            let objects = self.fetchedResultsController.fetchedObjects
        else { return [] }
        return objects.map({ self.trackerCategory(from: $0)})
    }
    
    convenience override init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            self.init()
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        fetchedResultsController.delegate = self
    }
    
    func addNewCategory(_ category: TrackerCategory) throws {
        let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
        trackerCategoryCoreData.name = category.name
        trackerCategoryCoreData.trackers = category.trackers.compactMap {
            $0.id
        }
        try context.save()
    }
    
    func addTrackerToCategory(to category: TrackerCategory?, tracker: Tracker) throws {
        guard let fromDb = self.fetchTrackerCategory(with: category) else {
            fatalError()
        }
        fromDb.trackers = trackerCategories.first {
            $0.name == fromDb.name
        }?.trackers.map { $0.id }
        fromDb.trackers?.append(tracker.id)
        try context.save()
    }
    
    func remove(from category: TrackerCategory?, tracker: Tracker) throws {
        guard let fromDb = self.fetchTrackerCategory(with: category) else {
            fatalError()
        }
        fromDb.trackers = fromDb.trackers?.filter({$0 != tracker.id}) ?? []
        try context.save()
    }
    
    func deleteCategory(_ category: TrackerCategory?) throws {
        let toDelete = fetchTrackerCategory(with: category)
        guard let toDelete = toDelete else { return }
        context.delete(toDelete)
        try context.save()
    }
    
    func trackerCategory(from trackerCategoryCoreData: TrackerCategoryCoreData) -> TrackerCategory {
        guard let name = trackerCategoryCoreData.name,
              let trackers = trackerCategoryCoreData.trackers
        else {
            fatalError()
        }
        return TrackerCategory(name: name, trackers: trackerStore
            .trackers
            .filter { trackers.contains($0.id) })
    }
    
    func fetchTrackerCategory(with trackerCategory: TrackerCategory?) -> TrackerCategoryCoreData? {
        guard let trackerCategory = trackerCategory else { fatalError() }
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "name == %@",
            trackerCategory.name as CVarArg
        )
        do {
            let result = try context.fetch(fetchRequest)
            return result.first
        } catch {
            return nil
        }
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.storeCategory()
    }
}
