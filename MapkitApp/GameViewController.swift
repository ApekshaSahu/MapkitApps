//
//  GameViewController.swift
//  MapkitApp
//
//  Created by Apeksha Sahu on 12/4/18.
//  Copyright © 2018 Apeksha Sahu. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import MapKit
import CoreLocation

class GameViewController: UIViewController {

    @IBOutlet weak var mapKitViews: MKMapView!
    let locationManager = CLLocationManager()
    let regionMeters :Double = 10000
    var previousLocation: CLLocation?
    
    @IBOutlet weak var addressLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load 'GameScene.sks' as a GKScene. This provides gameplay related content
        // including entities and graphs.
        if let scene = GKScene(fileNamed: "GameScene") {
            
            // Get the SKScene from the loaded GKScene
            if let sceneNode = scene.rootNode as! GameScene? {
                
                // Copy gameplay related content over to the scene
               // sceneNode.entities = scene.entities
                //sceneNode.graphs = scene.graphs
                
                // Set the scale mode to scale to fit the window
                sceneNode.scaleMode = .aspectFill
                
                // Present the scene
                if let view = self.view as! SKView? {
                    view.presentScene(sceneNode)
                    
                    view.ignoresSiblingOrder = true
                    
                    view.showsFPS = true
                    view.showsNodeCount = true
                }
            }
        }
    }
    
    
    func centerViewOnLocation(){
        
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: 10000, longitudinalMeters: 10000)
            
            mapKitViews.setRegion(region, animated: true)
        }
    }
    func checkLocationAuthorization(){
        
        switch CLLocationManager.authorizationStatus() {
            
        case .authorizedAlways: break
        case .authorizedWhenInUse:
            startTrackingUserLocation()
        case .denied: break
        case .notDetermined: locationManager.requestWhenInUseAuthorization()
        case .restricted: break
            
            
        }
        
    }
    
    func startTrackingUserLocation(){
        
        mapKitViews.showsUserLocation = true
        centerViewOnLocation()
        locationManager.startUpdatingLocation()
        previousLocation = getCenterLocation(for: mapKitViews)
        
    }
    func setupLocationManager(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
    }
    func checkLocationServices(){
        
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        }else {
            
        }
    }
    
    
    func getCenterLocation(for mkmapView: MKMapView )-> CLLocation {
      let lat = mkmapView.centerCoordinate.latitude
    let lon = mkmapView.centerCoordinate.longitude
    
    return CLLocation(latitude: lat, longitude: lon)
        
    }
    
    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
extension GameViewController: CLLocationManagerDelegate {
    
   /* func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionMeters, longitudinalMeters: regionMeters)
        mapKitViews.setRegion(region, animated: true)
        }*/
        
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
     checkLocationAuthorization()
}
    
}
    extension GameViewController: MKMapViewDelegate {
    
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            let center = getCenterLocation(for: mapView)
            
            let geoCoder = CLGeocoder()
            
            geoCoder.reverseGeocodeLocation(center) { [weak self] (placemarks, error) in
                guard let previousLocation = self?.previousLocation else { return }
                
                guard center.distance(from: previousLocation) > 50 else {return }
                self?.previousLocation = center
                guard self != nil else {return}
                
                if let _ = error {
                    return
                }
                
                guard let placemark = placemarks?.first else {
                    return
                }
                
                let streetNumber = placemark.subThoroughfare
                let streetName = placemark.thoroughfare
                
                DispatchQueue.main.async {
               
                    self?.addressLabel.text = "\(streetNumber ?? "0")\(streetName ?? "0")"
                }
                
        }
            
            
        }
        
    }


