//
//  LocationManager.swift
//  TabBarExample
//
//  Created by MAC PRO N-VIBE on 14/02/2023.
//

import Foundation
import CoreLocation

protocol LocationManagerDelegate: AnyObject {
    func onChangeAuthorization(status: CLAuthorizationStatus)
    func onLocationChanged(location: CLLocationCoordinate2D)
    func onAddressRetrieved(address: String)
}

class LocationManager: NSObject {
    static let shared = LocationManager()
    
    weak var delegate: LocationManagerDelegate?
    
    private var locationManager: CLLocationManager?
    private var isLocationUpdated = false
    private var currentLocation: CLLocationCoordinate2D? = nil
    
    deinit {
        changeLocationState(state: false)
        locationManager = nil
    }
    
    func requestAddress() {
        if let coordinate = currentLocation {
            getAddress(from: coordinate)
        } else {
            delegate?.onAddressRetrieved(address: "Aucune adresse trouvée, veuillez réessayer")
        }
    }
    
    /// Start/stop background location updates
    func changeLocationState(state: Bool) {
        if isLocationUpdated != state {
            if state {
                locationManager?.pausesLocationUpdatesAutomatically = false
                locationManager?.allowsBackgroundLocationUpdates = true
                locationManager?.desiredAccuracy = kCLLocationAccuracyBest
                locationManager?.startUpdatingLocation()
            } else {
                locationManager?.stopUpdatingLocation()
            }
            isLocationUpdated = state
        }
    }
    
    /// Returns `true` if all authorization is set otherwise returns `false`
    func askForLocation() -> Bool {
        if (locationManager == nil) {
            locationManager = CLLocationManager()
            locationManager?.delegate = self
            locationManager?.requestWhenInUseAuthorization()
        } else {
            if askForLocationServiceState() {
                if askForLocationAuthorization() {
                    if askForAccuracyAuthorization() {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    private func askForLocationServiceState() -> Bool {
        if CLLocationManager.locationServicesEnabled() {
            return true
        } else {
            //Need location active
            return false
        }
    }
    
    private func askForLocationAuthorization() -> Bool {
        if (CLLocationManager.authorizationStatus() == .authorizedWhenInUse) {
            return true
        } else {
            if CLLocationManager.authorizationStatus() == .notDetermined {
                locationManager?.requestWhenInUseAuthorization()
            } else {
                //Need location authorization
            }
            return false
        }
    }
    
    private func askForAccuracyAuthorization() -> Bool {
        if #available(iOS 14.0, *), let manager = locationManager {
            if (manager.accuracyAuthorization == .fullAccuracy) {
                return true
            } else {
                //Need precise location
                return false
            }
        }
        return true
    }
    
    /// Returns address from coordinate
    private func getAddress(from coordinate: CLLocationCoordinate2D) {
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)) { [self] (placemarks, error) in
            if let placemark = placemarks?.first, let dictionnary = placemark.addressDictionary?["FormattedAddressLines"] as? [String] {
                var address = ""
                for (index, data) in dictionnary.enumerated() {
                    if index == 0 {
                        address = data
                    } else {
                        address += ", \(data)"
                    }
                }
                if address != "" {
                    delegate?.onAddressRetrieved(address: "Vous êtes \(address)")
                } else {
                    delegate?.onAddressRetrieved(address: "Aucune adresse trouvée, veuillez réessayer")
                }
            } else {
                delegate?.onAddressRetrieved(address: "Aucune adresse trouvée, veuillez réessayer")
            }
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            print("didUpdateLocations : \(location.coordinate)")
            currentLocation = location.coordinate
            delegate?.onLocationChanged(location: location.coordinate)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError : \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            print("LocationManager :: authorization notDetermined")
            changeLocationState(state: false)
            delegate?.onChangeAuthorization(status: status)
        case .denied:
            print("LocationManager :: authorization denied")
            changeLocationState(state: false)
            delegate?.onChangeAuthorization(status: status)
        case .restricted:
            print("LocationManager :: authorization restricted")
            changeLocationState(state: false)
            delegate?.onChangeAuthorization(status: status)
        case .authorizedWhenInUse:
            print("LocationManager :: authorization when in use")
            changeLocationState(state: true)
            delegate?.onChangeAuthorization(status: status)
        default:
            break
        }
    }
}
