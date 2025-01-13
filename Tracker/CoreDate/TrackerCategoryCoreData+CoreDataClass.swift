//
//  TrackerCategoryCoreData+CoreDataClass.swift
//  Tracker
//
//  Created by Alibi Mailan
//
//

import Foundation
import CoreData


public class TrackerCategoryCoreData: NSManagedObject, Identifiable {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackerCategoryCoreData> {
        return NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
    }

    @NSManaged public var name: String?
    @NSManaged public var trackers: Set<TrackerCoreData>?

    @objc(addTrackersObject:)
    @NSManaged public func addToTrackers(_ value: TrackerCoreData)

    @objc(removeTrackersObject:)
    @NSManaged public func removeFromTrackers(_ value: TrackerCoreData)

    @objc(addTrackers:)
    @NSManaged public func addToTrackers(_ values: NSSet)

    @objc(removeTrackers:)
    @NSManaged public func removeFromTrackers(_ values: NSSet)
}
