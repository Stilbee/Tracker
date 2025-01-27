//
//  Analytics.swift
//  Tracker
//
//  Created by Alibi Mailan on 22.01.2025.
//

import Foundation
import YandexMobileMetrica

final class Analytics {
    static let shared = Analytics()
    
    func report(_ event: String, params : [AnyHashable : Any]) {
        YMMYandexMetrica.reportEvent(event, parameters: params, onFailure: { error in
            print("error: %@", error.localizedDescription)
        })
    }
}
