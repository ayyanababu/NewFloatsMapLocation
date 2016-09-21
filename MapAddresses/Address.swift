//
//  Address.swift
//  MapAddresses
//
//  Created by Raja Ayyan on 20/09/16.
//  Copyright © 2016 Raja Ayyanababu. All rights reserved.
//

import Foundation


struct Address {
    var longitude: Double!
    var latitude: Double!
    var address: String!
    var timeStamp: Double!
    
    init(lat: Double, long: Double, address: String, date: Double){
        self.longitude = long
        self.latitude = lat
        self.address = address
        self.timeStamp = date
    }
}