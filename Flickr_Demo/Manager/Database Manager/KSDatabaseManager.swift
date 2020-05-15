//
//  KSDatabaseManager.swift
//  Flickr_Demo
//
//  Created by Kedar Sukerkar on 05/05/20.
//  Copyright © 2020 Kedar-27. All rights reserved.
//

import Foundation
import CoreData


class KSCoreDataManager: NSObject{
    
    // MARK: - Initializer
    static var shared: KSCoreDataManager = KSCoreDataManager()
    private override init() {}
    
    
    // MARK: - Properties
    
    /// name of .xcdatamodelId file
    public var modelName = String()
    
    
    // MARK: - Private Properties
    lazy var persistenceContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: self.modelName)
        container.loadPersistentStores { (description, error) in
            if let error = error as NSError?{
                fatalError(error.localizedRecoverySuggestion ?? "")
            }
        }
        return container
    }()

    public lazy var backgroundContext: NSManagedObjectContext = {
        let managedObjectContext = self.persistenceContainer.newBackgroundContext()
        return managedObjectContext
    }()
    
    
    public lazy var mainContext: NSManagedObjectContext = {
        let context = self.persistenceContainer.viewContext
        return context
        
    }()
    
    
    // MARK: - Fetch Request
    func fetchRequest<T: NSManagedObject>(entity: T.Type) -> [T]{
        let entityName = String(describing: entity)
        let request = NSFetchRequest<T>(entityName: entityName)
        request.returnsObjectsAsFaults = true
        
        //        // Creates `asynchronousFetchRequest` with the fetch request and the completion closure
        //        let asynchronousFetchRequest = NSAsynchronousFetchRequest(fetchRequest: request) { asynchronousFetchResult in
        //            // Retrieves an array of dogs from the fetch result `finalResult`
        //            guard let results = asynchronousFetchResult.finalResult else { return }
        //
        //            completion(results)
        //        }
        //        do {
        //            // Executes `asynchronousFetchRequest`
        //            try self.backgroundContext.execute(asynchronousFetchRequest)
        //        } catch let error {
        //            print("NSAsynchronousFetchRequest error: \(error)")
        //        }
        
        do {
            let results = try self.backgroundContext.fetch(request)
            return results
        }catch {
            
        }
        return []
    }
    
    // MARK: - Save Changes
    func saveChanges () {
    
        self.backgroundContext.perform {
            do {
                if self.backgroundContext.hasChanges {
                    try self.backgroundContext.save()
                }
            } catch {
                let saveError = error as NSError
                print("Unable to Save Changes of Private Managed Object Context")
                print("\(saveError), \(saveError.localizedDescription)")
            }
        }
        
        do {
                 if self.mainContext.hasChanges {
                     try self.mainContext.save()
                 }
             } catch {
                 let saveError = error as NSError
                 print("Unable to Save Changes of Managed Object Context")
                 print("\(saveError), \(saveError.localizedDescription)")
             }
        
        
        
    }
    
    
    // MARK: - Clear Data
    func deleteAllData<T: NSManagedObject>(entity: T.Type){
        let results = self.fetchRequest(entity: entity)
        for object in results {
            self.backgroundContext.delete(object)
        }
        self.saveChanges()
    }
    
    
    
    
}
