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
  
  var resultSearchController: UISearchController?
  var city: City?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    guard let locationSearchController = storyboard?.instantiateViewController(withIdentifier: "LocationSearchController") as? LocationSearchTableViewController else { return }
    resultSearchController = UISearchController(searchResultsController: locationSearchController)
    resultSearchController?.searchResultsUpdater = locationSearchController
    locationSearchController.mapView = mapView
    
    let searchBar = resultSearchController?.searchBar
    searchBar?.sizeToFit()
    searchBar?.placeholder = "Search for places"
    navigationItem.titleView = searchBar
    
    resultSearchController?.hidesNavigationBarDuringPresentation = false
    resultSearchController?.dimsBackgroundDuringPresentation = true
    definesPresentationContext = true
  }

  // MARK: - Navigation
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard segue.identifier == propertyKeys.saveUnwindSegue else { return }
   
  }

}
