//
//  FilterStack.swift
//  Tracker
//
//  Created by Alibi Mailan on 25.01.2025.
//

import Foundation

enum Filters: CaseIterable {
    case allTrackers
    case trackersToday
    case completedTrackers
    case unCompletedTrackers
    
    var description: String {
        switch self {
        case .allTrackers:
            return NSLocalizedString("filter.allTrackers", comment: "")
        case .trackersToday:
            return NSLocalizedString("filter.trackersToday", comment: "")
        case .completedTrackers:
            return NSLocalizedString("filter.completedTrackers", comment: "")
        case .unCompletedTrackers:
            return NSLocalizedString("filter.uncompletedTrackers", comment: "")
        }
    }
}
