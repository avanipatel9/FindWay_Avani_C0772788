//
//  ViewController.swift
//  FindWay_Avani_C0772788
//
//  Created by Avani Patel on 6/11/20.
//  Copyright © 2020 Avani Patel. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressLabel: UILabel!
    
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 10000
    var previousLocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        checkLocationServices()
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
            
//            let pin = MKPointAnnotation()
//            pin.coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
//            mapView.addAnnotation(pin)
        }
    }
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            // setup location manager
            setupLocationManager()
            checkLocationAuthorization()
        }
        else {
            // Show alert letting the user know they have to turn this on.
        }
    }
    
    func checkLocationAuthorization() {
        
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            startTrackingUserLocation()
        case .denied:
            //Show alert instructing them how to turn on permissions
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            //show them alert letting them know what's up
            break
        case .authorizedAlways:
            break
        @unknown default:
            break
        }
    }
    
    func startTrackingUserLocation() {
        mapView.showsUserLocation = true
        centerViewOnUserLocation()
        locationManager.startUpdatingLocation()
        previousLocation = getCenterLocation(for: mapView)
    }
    
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
}

extension ViewController: CLLocationManagerDelegate
{
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//
//        guard let location = locations.last else { return }
//
//        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
//
//        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
//
//        mapView.setRegion(region, animated: true)
//    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        checkLocationAuthorization()
    }
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        let center = getCenterLocation(for: mapView)
        
        let geoCoder = CLGeocoder()
        
        guard let previousLocation = self.previousLocation else { return }
        
        guard center.distance(from: previousLocation) > 50 else { return }
        self.previousLocation = center
        
        geoCoder.reverseGeocodeLocation(center) { [weak self] (placemarks, error) in
        guard let self = self else { return }
        
        if let _ = error {
            //TODO: Show alert informing the user
            return
        }
        
        guard let placemark = placemarks?.first else {
            //TODO: Show alert informing the user
            return
        }
        
        let streetNumber = placemark.subThoroughfare ?? ""
        let streetName = placemark.thoroughfare ?? ""
        
        DispatchQueue.main.async {
            self.addressLabel.text = "\(streetNumber) \(streetName)"
        }
            
        }
        
    }
}
