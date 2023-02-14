//
//  ViewController.swift
//  TabBarExample
//
//  Created by MAC PRO N-VIBE on 14/02/2023.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    @IBOutlet weak var menuTabBar: UITabBar!
    @IBOutlet weak var locationTabBarItem: UITabBarItem!
    @IBOutlet weak var favoriteTabBarItem: UITabBarItem!
    @IBOutlet weak var moreTabBarUtem: UITabBarItem!
    
    private var previousSelectedItem: UITabBarItem?
    private var currentAddress: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        menuTabBar.selectedItem = favoriteTabBarItem
        previousSelectedItem = menuTabBar.selectedItem
        
        locationTabBarItem.accessibilityLabel = "Où suis-je ?"
        favoriteTabBarItem.accessibilityLabel = "Section favoris"
        moreTabBarUtem.accessibilityLabel = "Section Autres"
        
        LocationManager.shared.delegate = self
        _ = LocationManager.shared.askForLocation()
    }
}

extension ViewController: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item == locationTabBarItem {
            menuTabBar.selectedItem = previousSelectedItem
            
            let defaultAccessibilityLabel = item.accessibilityLabel
            item.accessibilityLabel = currentAddress ?? "Aucune adresse trouvée, veuillez réessayer"
            print(currentAddress ?? "Aucune adresse trouvée, veuillez réessayer")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.100) {
                item.accessibilityLabel = defaultAccessibilityLabel
            }
        }
    }
}

extension ViewController: LocationManagerDelegate {
    func onChangeAuthorization(status: CLAuthorizationStatus) { }
    
    func onLocationChanged(location: CLLocationCoordinate2D) { }
    
    func onAddressRetrieved(address: String) {
        currentAddress = address
    }
}
