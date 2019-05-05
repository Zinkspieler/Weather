//
//  AddCityViewController.swift
//  Weather
//
//  Created by Nathaniel Cox on 5/2/19.
//  Copyright © 2019 Nathaniel Cox. All rights reserved.
//

import UIKit
import MapKit

/// A view controller that allows the user to add a new `City` to the list of available Cities
class AddCityViewController: UIViewController {
  
  @IBOutlet weak var mapView: MKMapView!
  
  var resultSearchController: CustomSearchController?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // set up location search controller
    guard let locationSearchController = storyboard?.instantiateViewController(withIdentifier: propertyKeys.locationSearchControllerID) as? LocationSearchTableViewController else { return }
    resultSearchController = CustomSearchController(searchResultsController: locationSearchController)
    resultSearchController?.searchResultsUpdater = locationSearchController
    locationSearchController.mapView = mapView
    
    let searchBar = resultSearchController?.searchBar
    searchBar?.sizeToFit()
    searchBar?.placeholder = "Search for places"
    navigationItem.titleView = searchBar
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelPressed))
    
    resultSearchController?.hidesNavigationBarDuringPresentation = false
    resultSearchController?.dimsBackgroundDuringPresentation = true
    definesPresentationContext = true
    
  }
  
  @objc func cancelPressed() {
    performSegue(withIdentifier: propertyKeys.unwindToWeatherViewController, sender: self)
  }

}


