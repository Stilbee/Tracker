//
//  TrackerRecordCoreData+CoreDataProperties.swift
//  Tracker
//
//  Created by Alibi Mailan
//
//

import Foundation
import CoreData


extension TrackerRecordCoreData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackerRecordCoreData> {
        return NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
    }

    @NSManaged public var date: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var trackers: TrackerCoreData?

}

extension TrackerRecordCoreData : Identifiable {

}
