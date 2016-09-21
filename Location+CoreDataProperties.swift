//
//  Location+CoreDataProperties.swift
//  MapAddresses
//
//  Created by Raja Ayyan on 20/09/16.
//  Copyright © 2016 Raja Ayyanababu. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Location {

    @NSManaged var timestamp: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var latitude: NSNumber?
    @NSManaged var address: String?

}
