//
//  TrackersViewControllerSnapshots.swift
//  TrackersViewControllerSnapshots
//
//  Created by Alibi Mailan on 21.01.2025.
//

import XCTest
import SnapshotTesting

@testable import Tracker

final class TrackersViewControllerSnapshots: XCTestCase {

    private var subject: TrackersViewController!
    
    override func setUp() {
        super.setUp()
        subject = .init()
    }
    
    override func tearDown() {
        subject = nil
        super.tearDown()
    }
    
    func testLightSnapshot() throws {
        let embeddedController = UINavigationController(rootViewController: subject)
        
        assertSnapshot(
            of: embeddedController,
            as: .image(traits: .init(userInterfaceStyle: .light))
        )
    }
    
    func testDarkSnapshot() throws {
        let embeddedController = UINavigationController(rootViewController: subject)
        
        assertSnapshot(
            of: embeddedController,
            as: .image(traits: .init(userInterfaceStyle: .dark))
        )
    }
}
