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
            
            DispatchQueue.global().async {
                if LocationManager.shared.askForLocation() {
                    LocationManager.shared.requestAddress()
                }
            }
            
            ///Permet de changer l'accessibilité sur un temps très court, c'était ma 1ère idée mais en fait AriadneGPS ne fait pas comme ça
            /*let defaultAccessibilityLabel = item.accessibilityLabel
            item.accessibilityLabel = currentAddress ?? "Aucune adresse trouvée, veuillez réessayer"
            print(currentAddress ?? "Aucune adresse trouvée, veuillez réessayer")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.100) {
                item.accessibilityLabel = defaultAccessibilityLabel
            }*/
        }
    }
}

extension ViewController: LocationManagerDelegate {
    func onChangeAuthorization(status: CLAuthorizationStatus) { }
    
    func onLocationChanged(location: CLLocationCoordinate2D) { }
    
    func onAddressRetrieved(address: String) {
        if UIAccessibility.isVoiceOverRunning {
            //Le fait d'annoncer l'adresse via Voice Over annule le "Où suis-je" oral mais parfois, le reverse geocoding est trop lent et il a quand même le temps de dire "Où suis-je" puis l'adresse où on se trouve
            //Le comportement est exactement le même sur AriadneGPS, si on spam le bouton, on peut arriver à lui faire dire "Où suis-je" avant l'énonciation de l'adresse
            UIAccessibility.post(notification: .announcement, argument: address)
        } else {
            //Speak from default voice
        }
    }
}
