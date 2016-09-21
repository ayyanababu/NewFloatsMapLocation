//
//  Utility.swift
//  MapAddresses
//
//  Created by Raja Ayyan on 21/09/16.
//  Copyright © 2016 Raja Ayyanababu. All rights reserved.
//


import Foundation
import UIKit

class Utility{
    
    
    //MARK: Common Alert Control 
    
    static func showAlert(titleText:String?, confirmText:String, msgText:String, showConfirm:Bool, style:UIAlertControllerStyle, viewController:UIViewController, alertHandler:( (String)-> ())) {
        
        
        let alertController = UIAlertController(title: titleText, message: msgText, preferredStyle: style)
        
        let actionRight = UIAlertAction(title:confirmText, style: .Default) { action in
            
            alertHandler("clicked on cancel")
        }
        
        alertController.addAction(actionRight)
        
        viewController.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    
    
}

