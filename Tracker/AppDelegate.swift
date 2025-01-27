//
//  AppDelegate.swift
//  Tracker
//
//  Created by Alibi Mailan
//

import UIKit
import CoreData
import YandexMobileMetrica

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        DaysValueTransformer.register()
        
        if let configuration = YMMYandexMetricaConfiguration(apiKey: "7d2374f4-5d31-44eb-a005-3ddcb00a8fa4") {
            YMMYandexMetrica.activate(with: configuration)
        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TrackersEntities")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                print("Unresolved error \(error)")
            } else if let dbUrl = storeDescription.url?.absoluteString {
                print("DB url - ", dbUrl)
            }
        })
        return container
    }()
    
    lazy var context: NSManagedObjectContext = {
        return persistentContainer.viewContext
    }()
}
