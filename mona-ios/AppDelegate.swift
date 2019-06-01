//
//  AppDelegate.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-10.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import UIKit
import CoreData
import SwiftyBeaver
import Foundation
let log = SwiftyBeaver.self

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        setupLogger()
        setupPreferences()
        
        let username = "drix6"
        let password = "123456"
        UserDefaults.Credentials.set(username, forKey: .username)
        UserDefaults.Credentials.set(password, forKey: .password)
        
        MonaAPI.shared.register(username: username, email: nil, password: password) { (result) in
            switch result {
            case .success(let registerResponse):
                log.debug(registerResponse.token)
                UserDefaults.Credentials.set(registerResponse.token, forKey: .token)
            case .failure(let httpError):
                MonaAPI.shared.login(username: username, password: password) { (result) in
                    switch result {
                    case .success(let loginResponse):
                        log.debug(loginResponse.token)
                        UserDefaults.Credentials.set(loginResponse.token, forKey: .token)
                    case .failure(let httpError):
                        log.error(httpError)
                        log.error(httpError.localizedDescription)
                    }
                }
                log.error(httpError)
                log.error(httpError.localizedDescription)
            }
        }

        //print(CoreDataStack.applicationDocumentsDirectory.path)
        setupData()
        showApp()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        //self.saveContext()
    }
    
    private func setupLogger() {
        let console = ConsoleDestination()
        log.addDestination(console)
    }
    
    private func setupPreferences() {
        UserDefaults.standard.defaultSetup()
    }
    
    private func setupData() {
        MonaAPI.shared.artworks { (result) in
            switch result {
            case .success(let artworksResponse):
                if let artworks = artworksResponse.data {
                    let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
                    context.persistentStoreCoordinator = CoreDataStack.persistentStoreCoordinator
                    artworks.createOrUpdate(into: context)
                    do {
                        try context.save()
                    }
                    catch {
                        log.error("Saving failed. Error: \(error)")
                    }
                }
            case .failure(let artworksError):
                log.error(artworksError)
                log.error(artworksError.localizedDescription)
            }
        }
    }
    
    private func showApp() {
        let storyboard = UIStoryboard(name: "Tabbar", bundle: nil)
        let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarController") as! TabBarController
        tabBarController.viewContext = CoreDataStack.mainContext
        self.window?.rootViewController = tabBarController
        self.window?.rootViewController!.view.alpha = 0.0;
        UIView.animate(withDuration: 0.5, animations: {
            self.window?.rootViewController!.view.alpha = 1.0
        })
    }

}
