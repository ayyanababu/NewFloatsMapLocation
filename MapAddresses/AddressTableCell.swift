//
//  AddressTableCell.swift
//  MapAddresses
//
//  Created by Raja Ayyan on 21/09/16.
//  Copyright © 2016 Raja Ayyanababu. All rights reserved.
//

import UIKit

class AddressTableCell: UITableViewCell {
    
    
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    
    func configureCell(data: Location){
        
        self.addressLabel.text = data.address
        
        let latitude:String = String(format:"%f", (data.latitude?.doubleValue)!)
        let longitude:String = String(format:"%f", (data.longitude?.doubleValue)!)
        let coordinates = "\(latitude) , \(longitude)"
        self.locationLabel.text = coordinates
        
    }
    

}
