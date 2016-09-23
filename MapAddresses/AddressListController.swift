//
//  AddressListController.swift
//  MapAddresses
//
//  Created by Raja Ayyan on 20/09/16.
//  Copyright © 2016 Raja Ayyanababu. All rights reserved.
//

import UIKit


class AddressListController: UIViewController, loadDataProtocol {
    
    struct  StoryboardConstants {
        static let CELL_IDENTIFIER = "addresscell"
        static let MAP_CONTROLLER_SEGUE = "mapsegue"
        static let CELL_ITEM_CLICKED_SEGUE = "cellitemsegue"
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var floatButton: FloatButton!
    var locations = [Location]()
    
    
    
    // MARK: - Controller Methods
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.navigationItem.title = "Locations"
        self.getTableSourceData()
        self.setFloatButton()
        
    }
    
    func setFloatButton(){
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.draggedFloatButton))
        panGesture.cancelsTouchesInView = true
        self.floatButton.addGestureRecognizer(panGesture)
    }
    
    
    func draggedFloatButton(recognizer: UIPanGestureRecognizer){
        
        let button = (recognizer.view! as! UIButton)
        let translation = recognizer.translationInView(button)
        button.center = CGPoint(x: button.center.x + translation.x, y: button.center.y + translation.y)
        recognizer.setTranslation(CGPointZero, inView: button)
        
    }
    

    
    
    func getTableSourceData(){
        
        let locations = CoreDataManager.SharedInstance.getLocationsFromDb("Location")
        if locations?.count > 0 {
            self.locations = locations!
            self.tableView.reloadData()
        }
        
    }
    
    @IBAction func clickToOpenMap(sender: AnyObject) {
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == StoryboardConstants.MAP_CONTROLLER_SEGUE{
            let mapcontroller  = segue.destinationViewController as? MapViewController
            mapcontroller?.delegate = self
            
        }else if segue.identifier == StoryboardConstants.CELL_ITEM_CLICKED_SEGUE{
            let mapcontroller  = segue.destinationViewController as? MapViewController
            mapcontroller?.delegate = self
            let cell = sender as! AddressTableCell
            let indexPath = self.tableView.indexPathForCell(cell)
            print(indexPath?.row)
            if let index = indexPath?.row{
                mapcontroller?.location = self.locations[index]
            }
            
        }
        
    }
    
    
    func reloadLocations(){
        self.getTableSourceData()
    }
    
    
}




// MARK: - TableView Delegate & DataSource Methods

extension AddressListController: UITableViewDelegate, UITableViewDataSource{
    
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let cellcount = self.locations.count
        return cellcount > 0 ? cellcount : 0
        
    }
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(StoryboardConstants.CELL_IDENTIFIER, forIndexPath: indexPath) as? AddressTableCell
        
        cell?.configureCell(self.locations[indexPath.row])
        return cell!
    }
    
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 75
    }
    
    
}


extension AddressListController{

    // MARK: - Edit Method

    @IBAction func editButton(sender: AnyObject) {
        
        let cel = sender.superview??.superview as? AddressTableCell
        let indexPath = self.tableView.indexPathForCell(cel!)
        print(indexPath?.row)
        
        var addressField: UITextField?
        var latitudeField: UITextField?
        var longitudeField: UITextField?
        
        let alertController = UIAlertController(
            title: "Edit Coordinates",
            message: "Please enter your Coordinates",
            preferredStyle: UIAlertControllerStyle.Alert)
        
        let okAction = UIAlertAction(
        title: "Ok", style: UIAlertActionStyle.Default) {
            (action) -> Void in
            
            
            
            if addressField?.text != "" {
                print(" addressfield = \(addressField?.text)")
            } else {
                print("No address entered")
            }
            
            
            if latitudeField?.text != "" {
                print(" latitude = \(latitudeField?.text)")
            } else {
                print("No latitude entered")
            }
            
            if longitudeField?.text != "" {
                print("longitude = \(longitudeField?.text)")
            } else {
                print("No longitude entered")
            }
            
            
            
            //save into DB
            if latitudeField?.text != "" && longitudeField?.text != "" &&  addressField?.text != ""{
                
                let add = (addressField?.text)!
                
                let lat = Double((latitudeField?.text)!)
                let long = Double((longitudeField?.text)!)
                let address = Address(lat: lat!, long: long!, address: add, date: (NSDate().timeIntervalSince1970))
                
                
                let location = self.locations[(indexPath?.row)!]
                CoreDataManager.SharedInstance.updateValue("Location", originalData: location, data: address, error: { (errormsg) in
                    print("didnt update sucessfully wrong")
                    }, sucess: { (sucessmsg) in
                        self.getTableSourceData()
                })
                
            }
        }
        
        
        let cancleAction = UIAlertAction(
        title: "Dismiss", style: UIAlertActionStyle.Default) {
            (action) -> Void in
        }
        
        
        alertController.addTextFieldWithConfigurationHandler {
            (addressstring) -> Void in
            addressField = addressstring
            addressField!.placeholder = "Enter Address Here"
        }
        
        alertController.addTextFieldWithConfigurationHandler {
            (latitudename) -> Void in
            latitudeField = latitudename
            latitudeField!.placeholder = "Enter Latitude Here"
        }
        
        alertController.addTextFieldWithConfigurationHandler {
            (longitudename) -> Void in
            longitudeField = longitudename
            longitudeField!.placeholder = "Enter Longitude Here"
        }
        
        alertController.addAction(okAction)
        alertController.addAction(cancleAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
}
