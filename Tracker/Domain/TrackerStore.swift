//
//  TrackerStore.swift
//  Tracker
//
//  Created by Alibi Mailan
//
import CoreData
import UIKit

protocol TrackerStoreDelegate: AnyObject {
    func store() -> Void
}

final class TrackerStore: NSObject {
    private var context: NSManagedObjectContext
    
    private lazy var fetchedResultsController = {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCoreData.id, ascending: true)
        ]
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        try? controller.performFetch()
        return controller
    }()
        
    private let uiColorMarshalling = UIColorMarshalling()
    weak var delegate: TrackerStoreDelegate?
    
    var trackers: [Tracker] {
        guard
            let objects = self.fetchedResultsController.fetchedObjects,
            let trackers = try? objects.map({ try self.tracker(from: $0) })
        else { return [] }
        return trackers
    }
    
    // MARK: - Initializers
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
    
    func addNewTracker(_ tracker: Tracker) {
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.color = uiColorMarshalling.hexString(from: tracker.color)
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.pinned = tracker.pinned
        trackerCoreData.schedule = tracker.schedule?.map {
            $0.rawValue
        }
        do {
            try context.save()
        } catch {
            print(error)
        }
    }
    
    func updateTracker(_ tracker: Tracker, oldTracker: Tracker?) throws {
        let updated = try fetchTracker(with: oldTracker)
        guard let updated = updated else { return }
        updated.name = tracker.name
        updated.color = uiColorMarshalling.hexString(from: tracker.color)
        updated.emoji = tracker.emoji
        updated.schedule = tracker.schedule?.map {
            $0.rawValue
        }
        try context.save()
    }
    
    func deleteTracker(_ tracker: Tracker?) throws {
        let toDelete = try fetchTracker(with: tracker)
        guard let toDelete = toDelete else { return }
        context.delete(toDelete)
        try context.save()
    }
    
    func tracker(from trackerCoreData: TrackerCoreData) throws -> Tracker {
        let pinned = trackerCoreData.pinned
        guard let id = trackerCoreData.id,
              let emoji = trackerCoreData.emoji,
              let color = uiColorMarshalling.color(from: trackerCoreData.color ?? ""),
              let name = trackerCoreData.name
        else {
            fatalError()
        }
        return Tracker(id: id, name: name, color: color, emoji: emoji,
                       schedule: trackerCoreData.schedule == nil ? nil : Set(trackerCoreData.schedule!.compactMap({ DayOfWeek(rawValue: $0)})), pinned: pinned)
    }
    
    func pinTracker(_ tracker: Tracker?, value: Bool) throws {
        let toPin = try fetchTracker(with: tracker)
        guard let toPin = toPin else { return }
        toPin.pinned = value
        try context.save()
    }
    
    func fetchTracker(with tracker: Tracker?) throws -> TrackerCoreData? {
        guard let tracker = tracker else { return nil }
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        let result = try context.fetch(fetchRequest)
        return result.first
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.store()
    }
}
