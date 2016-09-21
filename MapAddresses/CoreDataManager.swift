//
//  CoreDataManager.swift
//  MapAddresses
//
//  Created by Raja Ayyan on 20/09/16.
//  Copyright © 2016 Raja Ayyanababu. All rights reserved.
//

import Foundation
import CoreData

class CoreDataManager{
    
    lazy var coreDataStack = CoreDataStack()
    static let SharedInstance = CoreDataManager()
    
    private init(){
        
    }
    
    
    //MARK: Save
    
    func saveLocationIntoDB(tableName: String, data: Address, error: ((String) -> Void), sucess: ((String) -> Void)){
        
        //Checking while saving is duplicate if duplicate throw error
        //else save data into DB
        
        let managedContext = coreDataStack.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: tableName)
        fetchRequest.predicate = NSPredicate(format: "\(Constants.ADDRESS_ATTRIBUTE) = %@", data.address)
        do{
            let location = try managedContext.executeFetchRequest(fetchRequest) as! [Location]
            if location.count == 0{
                let userEntity = NSEntityDescription.entityForName(tableName, inManagedObjectContext: coreDataStack.managedObjectContext)
                
                let loc = Location(entity:userEntity!, insertIntoManagedObjectContext: coreDataStack.managedObjectContext)
                loc.address = data.address
                loc.latitude = NSNumber(double: data.latitude)
                loc.longitude = NSNumber(double: data.longitude)
                loc.timestamp = NSNumber(double: data.timeStamp)
                
                coreDataStack.saveMainContext()
                sucess("sucess")
            }else{
                error("This Coordinates Already Available in DB")
            }
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        
        
    }
    
    
    //MARK: Retrieve

    func getLocationsFromDb(tablename: String) -> [Location]?{
        
        //Getting Locations from DB based on TimeStamp Desending order
        
        let managedContext = coreDataStack.managedObjectContext
        let request = NSFetchRequest(entityName: tablename)
        let sortDescriptor = NSSortDescriptor(key: "\(Constants.TIMESTAMP_ATTRIBUTE)", ascending: false)
        let sortDescriptors = [sortDescriptor]
        request.sortDescriptors = sortDescriptors
        
        do{
            let locatoins = try managedContext.executeFetchRequest(request) as! [Location]
            if locatoins.count > 0{
                return locatoins
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        return nil
    }
    
    
    //MARK: Update

    
    func updateValue(tablename: String, originalData: Location, data: Address, error: ((String) -> Void), sucess: ((String) -> Void)){
        
        let managedContext = coreDataStack.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: tablename)
        
        fetchRequest.predicate = NSPredicate(format: "\(Constants.ADDRESS_ATTRIBUTE) = %@", originalData.address!)
        do{
            let location = try managedContext.executeFetchRequest(fetchRequest) as! [Location]
            if location.count > 0 {
                let loc = location.last
                loc!.address = data.address
                loc!.latitude =  NSNumber(double: data.latitude)
                loc!.longitude = NSNumber(double: data.longitude)
                loc!.timestamp = data.timeStamp
                
                coreDataStack.saveMainContext()
                sucess("sucess")
                
            }else{
                error("Records not updated")
            }
        }catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
    }
    
    
    
    
}