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
    
    print(searchBarText)
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
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "LocationSearchCell") else { return UITableViewCell() }
    let selectedItem = matchingItems[indexPath.row].placemark
    cell.textLabel?.text = selectedItem.title
    let lat = String(format: "%.2f", selectedItem.coordinate.latitude)
    let lon = String(format: "%.2f", selectedItem.coordinate.longitude)
    cell.detailTextLabel?.text = "lat: \(lat): lon: \(lon)"
    return cell
  }
}

// MARK: - Table View Delegate

extension LocationSearchTableViewController {
  
  override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
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
