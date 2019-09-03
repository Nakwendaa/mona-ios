//
//  CoreDataStack.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-10.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class CoreDataStack {
    
    static var applicationDocumentsDirectory: URL = {
        
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    static var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        
        // We store the location of the application's model in modelURL. A .momd is the extension of a .xcdatamodeld compiled file
        // Il est possible d'avoir plusieurs modèles de données, et NSManagedObjectfModel peut gérer plusieurs modèles de données et les fusionner en un modèle
        let modelURL = Bundle.main.url(forResource: "Model", withExtension: "momd")!
        // And we pass modelURL to contentsOf: to create an instance of the NSManagedObjectModel class
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    static var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        let url = applicationDocumentsDirectory.appendingPathComponent("Model.sqlite") // type your database name here...

        // Copy the data
        if !FileManager.default.fileExists(atPath: url.path) {
            print("Bundle url: \(Bundle.main.bundlePath)")
            let sourceSqliteURLs = [
                Bundle.main.url(forResource: "Model", withExtension: "sqlite")!,
                Bundle.main.url(forResource: "Model", withExtension: "sqlite-shm")!,
                Bundle.main.url(forResource: "Model", withExtension: "sqlite-wal")!
            ]
            
            let destSqliteURLs = [
                applicationDocumentsDirectory.appendingPathComponent("Model.sqlite"),
                applicationDocumentsDirectory.appendingPathComponent("Model.sqlite-shm"),
                applicationDocumentsDirectory.appendingPathComponent("Model.sqlite-wal"),
            ]
            
            for index in 0..<sourceSqliteURLs.count {
                do {
                    try FileManager.default.copyItem(at: sourceSqliteURLs[index], to: destSqliteURLs[index])
                }
                catch let error as NSError {
                    print("Could not copy item. \(error), \(error.userInfo)")
                }
            }
        }
        
        // Create the store
        var failureReason = "There was an error creating or loading the application's saved data."
        let options = [
         NSMigratePersistentStoresAutomaticallyOption: NSNumber(value: true as Bool),
         NSInferMappingModelAutomaticallyOption: NSNumber(value: true as Bool)
        ]
        do {
            // Create the store
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
        }
        catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            log.error("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }

        return coordinator
    }()
    
    static var mainContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    static func getEntity<T: NSManagedObject>(context: NSManagedObjectContext) -> T {
        if #available(iOS 10, *) {
            let obj = T.init(context: context)
            return obj
        } else {
            guard let entityDescription = NSEntityDescription.entity(forEntityName: NSStringFromClass(T.self), in: context) else {
                fatalError("Core Data entity name doesn't match.")
            }
            let obj = T(entity: entityDescription, insertInto: context)
            return obj
        }
    }
    
    static func isValid(entityName: String) -> Bool {
        return (managedObjectModel.entitiesByName[entityName] != nil) ? true : false
    }
    
    static func count(forEntityName entityName: String, into context: NSManagedObjectContext) -> Int {
        
        guard isValid(entityName: entityName) else {
            log.error("Entity \"\(entityName)\" doesn't exist in the managed object model in Core Data Stack.")
            return 0
        }
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.includesSubentities = false
        fetchRequest.includesPropertyValues = false
        
        do {
            let count = try context.count(for: fetchRequest)
            return count
        }
        catch {
            log.error("Error counting objects for \"\(entityName)\": \(error)")
            return 0
        }
    }
    
    static func fetchAsynchronously<T: NSManagedObject>(type: T.Type, context: NSManagedObjectContext, entityName: String, predicate : NSPredicate? = nil, completion: @escaping ([T]) -> Void) {
        
        let privateManagedContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateManagedContext.parent = context
        
        let syncFetchRequest = NSFetchRequest<T>(entityName: entityName)
        syncFetchRequest.predicate = predicate
        let asyncFetchRequest = NSAsynchronousFetchRequest(fetchRequest: syncFetchRequest) { result in
            guard let finalResult = result.finalResult else { return }
            
            DispatchQueue.main.async {
                let arrayResult: [T] = finalResult.lazy
                    .compactMap { $0.objectID } // Retrives all the objectsID
                    .compactMap { context.object(with: $0) as? T }
                
                completion(arrayResult)
            }
        }
        do {
            try privateManagedContext.execute(asyncFetchRequest)
        }
        catch {
            log.error("Failed to fetch techniques asynchronously. Error: \(error)")
        }
    }
    
    static func fetchAsynchronously<T: NSManagedObject>(type: T.Type, context: NSManagedObjectContext, entityName: String, predicate : NSPredicate? = nil, completion: @escaping ([T], NSManagedObjectContext) -> Void) {
        
        let privateManagedContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateManagedContext.parent = context
        
        let syncFetchRequest = NSFetchRequest<T>(entityName: entityName)
        syncFetchRequest.predicate = predicate
        let asyncFetchRequest = NSAsynchronousFetchRequest(fetchRequest: syncFetchRequest) { result in
            guard let finalResult = result.finalResult else { return }
            
            DispatchQueue.main.async {
                let arrayResult: [T] = finalResult.lazy
                    .compactMap { $0.objectID } // Retrives all the objectsID
                    .compactMap { context.object(with: $0) as? T }
                
                completion(arrayResult, privateManagedContext)
            }
        }
        do {
            try privateManagedContext.execute(asyncFetchRequest)
        }
        catch {
            log.error("Failed to fetch techniques asynchronously. Error: \(error)")
        }
    }
    
    // MARK: - Core Data Saving support
    
    static func saveMainContext () {
        if mainContext.hasChanges {
            do {
                try mainContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                log.error("Unresolved error \(error)")
                abort()
            }
        }
    }
    
}

extension CoreDataStack {

    static func deleteAllObjectsInCoreData() {
        let moc = CoreDataStack.mainContext
        let allEntities = managedObjectModel.entities
        
        for entityDescription in allEntities {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityDescription.name!)
            let batcheDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            let deletedObjectCount : Int
            do {
                let batchDeleteResultBox = try moc.execute(batcheDeleteRequest) as! NSBatchDeleteResult
                deletedObjectCount = batchDeleteResultBox.result as! Int
            } catch {
                log.error("Error requesting items from Core Data: \(error)")
                abort()
            }
            log.debug("Removed \(deletedObjectCount) entities")
            
        }
    }
}

