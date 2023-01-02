//
//  ViewController.swift
//  MapNavigator
//
//  Created by Arish Khan on 31/12/22.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController,MKMapViewDelegate,CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        // for asking the authentication from the user .
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            //for best accuracy
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
    }
    
    // for getting location of the user(ie. source address) and destination adderss.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let loc1: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print(loc1)
        
        
        // Default location of destination (White house USA).
        let whiteHouseLocation = CLLocationCoordinate2D.init(latitude: 38.897957, longitude: -77.036560)
        //40.730610 73.935242
        //38.897957 77.036560
        //40.759211 73.984638
        showRouteOnTheMap(pickupCoordinate: loc1, destinationCoordinator: whiteHouseLocation)
        
        // making cllocation distance.
        let coordinate₀ = CLLocation(latitude: loc1.latitude, longitude: loc1.longitude)
        let coordinate₁ = CLLocation(latitude: whiteHouseLocation.latitude, longitude: whiteHouseLocation.longitude)
        // finding distance between source and destination.
        let distanceInMeters = coordinate₀.distance(from: coordinate₁)
        print(distanceInMeters)
        
        if distanceInMeters < 100 {
            let alert = UIAlertController(title: "Welcome!", message: "You have reached your destination", preferredStyle: UIAlertController.Style.alert)
            let okButtonAction = UIAlertAction(title: "ok", style: UIAlertAction.Style.default, handler: nil)
            alert.addAction(okButtonAction)
            present(alert, animated: true)
        }
    }
    
    //For creating route on the map
    func showRouteOnTheMap(pickupCoordinate: CLLocationCoordinate2D, destinationCoordinator: CLLocationCoordinate2D) {
        // creating or computing directions
        let request = MKDirections.Request()
        
        //for initial(user/source)
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: pickupCoordinate, addressDictionary: nil))
        //for destination
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destinationCoordinator, addressDictionary: nil))
        
        request.requestsAlternateRoutes = true
        
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        
        directions.calculate { [unowned self] response, error in
            if let error = error {
                debugPrint(error)
                return
            }
            
            
            guard let unwrappedResponse = response else { return }
            
            
            //for getting just one route
            if let route = unwrappedResponse.routes.first {
                
                //show on map
                self.mapView.addOverlay(route.polyline)
                
                //set the map area to show the route
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets.init(top: 80.0, left: 20.0, bottom: 100.0, right: 20.0), animated: true)
                
            }
        }
        
    }
    
    // This is use for disigning the locator line on the route.
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.red
        renderer.lineWidth = 3.0
        return renderer
    }
    
}

