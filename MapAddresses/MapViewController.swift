//
//  MapViewController.swift
//  MapAddresses
//
//  Created by Raja Ayyan on 20/09/16.
//  Copyright © 2016 Raja Ayyanababu. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


protocol loadDataProtocol {
    func reloadLocations()
}

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    lazy var locationManager = CLLocationManager()
    var annotation = MKPointAnnotation()
    let geocoder = CLGeocoder()
    var address: Address!
    var location: Location!
    
    @IBOutlet weak var saveMessageLabel: UILabel!
    var delegate: loadDataProtocol?
    lazy var timer = NSTimer()

    
    // MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureNavBar()
        self.setUpCurrentLocation()
    }
    
    func configureNavBar(){
        self.saveMessageLabel.hidden = true
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationItem.title = "Map"
        
        let saveButton = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: #selector(saveLocation))
        self.navigationItem.rightBarButtonItem = saveButton
    }
    
    
    func setUpCurrentLocation(){
        if self.location != nil{
            
            let lat = Double(self.location.latitude!)
            let long = Double(self.location.longitude!)
            let coordinates: CLLocation = CLLocation(latitude: lat, longitude: long)
            self.setMapRegion(coordinates)
            
        }else{
            
            self.locationManager.requestAlwaysAuthorization()
            self.locationManager.requestWhenInUseAuthorization()
            
            
            
            if CLLocationManager.locationServicesEnabled() {
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.startUpdatingLocation()
            }
            
            mapView.mapType = .Standard
            mapView.zoomEnabled = true
            mapView.scrollEnabled = true
            mapView.showsUserLocation = true;
            
        }
        
    }
    
    
    
    
    
    // MARK: - CLLocatoinManager DelegateMethod
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        self.setMapRegion(location!)
        self.locationManager.stopUpdatingLocation()
    }
    
    
    // MARK: - MapKit DelegateMethod
    
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.animatesDrop = true
            pinView?.canShowCallout = true
            pinView?.draggable = true
            pinView?.pinTintColor = UIColor.redColor()
            
        }
        else {
            pinView?.annotation = annotation
        }
        
        return pinView
    }
    
    
    //MARK: Pin DraggingEnd DelegateMethod
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        if newState == MKAnnotationViewDragState.Ending {
            let droppedAtCoordinates = view.annotation?.coordinate
            let coordinates: CLLocation = CLLocation(latitude: droppedAtCoordinates!.latitude, longitude: droppedAtCoordinates!.longitude)
            
            self.getAddressFromCoordinates(coordinates, completion: { (address, placemark) in
                
                let address = Address(lat: droppedAtCoordinates!.latitude, long: droppedAtCoordinates!.longitude, address: address, date: (NSDate().timeIntervalSince1970))
                self.address = address
                dispatch_async(dispatch_get_main_queue(), {
                    if let locality = placemark.locality,
                        let country = placemark.country{
                        self.annotation.title = "\(locality) , \(country) "
                        
                    }
                    
                })
            })
            
            
        }
    }
    
    
    // MARK: - Helper Methods
    
    
    func  getAddressFromCoordinates(droppedAtCoordinates: CLLocation, completion: ((String, CLPlacemark) -> Void)){
        
        
        geocoder.reverseGeocodeLocation(droppedAtCoordinates) { (pleacemarks, error) in
            if error == nil && pleacemarks!.count > 0 {
                let placemark = pleacemarks!.last
                
                var totalAddress = ""
                
                if let locality = placemark?.locality{
                    totalAddress = locality
                }
                
                //                if let thoroughfare = placemark?.thoroughfare{
                //                    totalAddress.appendContentsOf(" ,\(thoroughfare)")
                //                }
                //
                if let adminstrativearea = placemark?.administrativeArea{
                    totalAddress.appendContentsOf(" ,\(adminstrativearea)")
                }
                
                if let country = placemark?.country{
                    totalAddress.appendContentsOf(" ,\(country)")
                }
                
                
                completion(totalAddress, placemark!)
                
            }
        }
        
    }
    
    
    
    func setMapRegion(location: CLLocation){
        let lat = (location.coordinate.latitude)
        let long = (location.coordinate.longitude)
        
        let center = CLLocationCoordinate2D(latitude: lat, longitude: long)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0))
        self.mapView.setRegion(region, animated: true)
        
        annotation.coordinate = center
        annotation.title = "Current Location"
        self.mapView.addAnnotation(annotation)
        
        //get address from coordinates
        let coordinates: CLLocation = CLLocation(latitude: lat, longitude: long)
        self.getAddressFromCoordinates(coordinates, completion: { (address, placemark) in
            
            let address = Address(lat: lat, long: long, address: address, date: (NSDate().timeIntervalSince1970))
            self.address = address
            dispatch_async(dispatch_get_main_queue(), {
                if let locality = placemark.locality,
                    let country = placemark.country{
                    self.annotation.title = "\(locality) , \(country) "
                    
                }
                
            })
        })
        
        
    }
    
    
    // MARK: - Back and Save Delegate Methods
    
    override func didMoveToParentViewController(parent: UIViewController?) {
        if parent == nil {
            //"Back pressed"
            delegate?.reloadLocations()
        }
    }
    
    
    func hideLabel(){
        self.saveMessageLabel.hidden = true
        
    }
    
    
    func saveLocation(){
        
        if self.address == nil{
            
            print("Data is not captured, so cannot save")
            Utility.showAlert("Error", confirmText: "OK", msgText: "Data is not captured, so cannot save", showConfirm: true, style: .Alert, viewController: self, alertHandler: { (data) -> () in
                
            })
            return
        }
        
        
        
        
        
        CoreDataManager.SharedInstance.saveLocationIntoDB(Constants.LOCATION_ENTITY_NAME, data: self.address, error: { (errormsg) in
            //error
            Utility.showAlert("Error", confirmText: "OK", msgText: errormsg, showConfirm: true, style: .Alert, viewController: self, alertHandler: { (data) -> () in
                
            })
        }) { (sucessmsg) in
            //sucess
            self.saveMessageLabel.hidden = false
            self.timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(MapViewController.hideLabel), userInfo: nil, repeats: false)
        }
        
        
        
        
    }
    
    
    
}
