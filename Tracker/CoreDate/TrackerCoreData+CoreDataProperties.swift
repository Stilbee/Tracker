//
//  TrackerCoreData+CoreDataProperties.swift
//  Tracker
//
//  Created by Alibi Mailan
//
//

import Foundation
import CoreData


extension TrackerCoreData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackerCoreData> {
        return NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
    }

    @NSManaged public var color: String?
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var pinned: Bool
    @NSManaged public var schedule: [Int]?
    @NSManaged public var emoji: String?
    @NSManaged public var category: TrackerCategoryCoreData?
    @NSManaged public var record: NSSet?

}

// MARK: Generated accessors for record
extension TrackerCoreData {

    @objc(addRecordObject:)
    @NSManaged public func addToRecord(_ value: TrackerRecordCoreData)

    @objc(removeRecordObject:)
    @NSManaged public func removeFromRecord(_ value: TrackerRecordCoreData)

    @objc(addRecord:)
    @NSManaged public func addToRecord(_ values: NSSet)

    @objc(removeRecord:)
    @NSManaged public func removeFromRecord(_ values: NSSet)

}

extension TrackerCoreData : Identifiable {

}
