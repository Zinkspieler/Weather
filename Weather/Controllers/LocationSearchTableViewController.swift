//
//  LocationSearchTableViewController.swift
//  Weather
//
//  Created by Nathaniel Cox on 5/5/19.
//  Copyright © 2019 Nathaniel Cox. All rights reserved.
//

import UIKit
import MapKit

class LocationSearchTableViewController: UITableViewController {

  var matchingItems: [MKMapItem] = []
  var mapView: MKMapView?
  var city: City?
  
}

// MARK: - Search Results Delegate

extension LocationSearchTableViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {

    guard let mapView = mapView, let searchBarText = searchController.searchBar.text else { return }
  
    // create new request from search bar text
    let request = MKLocalSearch.Request()
    request.naturalLanguageQuery = searchBarText
    request.region = mapView.region
    let search = MKLocalSearch(request: request)
    
    search.start { (response, _) in
      guard let response = response else { return }
      self.matchingItems = response.mapItems
      self.tableView.reloadData()
    }
  }
  
  
}


// MARK: - Table View Data Source

extension LocationSearchTableViewController {
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return matchingItems.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: propertyKeys.locationSearchCell, for: indexPath)
    
    let selectedItem = matchingItems[indexPath.row].placemark
    cell.textLabel?.text = selectedItem.title
    // set detail label to display lat lon coordinates
    let lat = selectedItem.coordinate.latitude
    let latString = String(format: "%.2f", abs(lat)) + "° " + (lat > 0 ? "N" : "S")
    let lon = selectedItem.coordinate.longitude
    let lonString = String(format: "%.2f", abs(lon)) + "° " + (lon > 0 ? "E" : "W")
    cell.detailTextLabel?.text = "Latitude: \(latString): Longitude: \(lonString)"
    return cell
    
  }
}

// MARK: - Table View Delegate

extension LocationSearchTableViewController {
  
  override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    // create new City object in preparation for unwind segue
    let selectedItem = matchingItems[indexPath.row]
    guard let name = selectedItem.placemark.title else {
      return indexPath
    }
    let lat = selectedItem.placemark.coordinate.latitude
    let lon = selectedItem.placemark.coordinate.longitude
    city = City(name: name, latitude: lat, longitude: lon)
    
    return indexPath
  }
  
}
