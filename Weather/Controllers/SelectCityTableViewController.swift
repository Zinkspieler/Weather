//
//  SelectCityTableViewController.swift
//  Weather
//
//  Created by Nathaniel Cox on 4/30/19.
//  Copyright © 2019 Nathaniel Cox. All rights reserved.
//

import UIKit

/// Delegate for the `SelectCityTableViewController`
///
/// Can be told which `City` to get the weather for, or to use the current location
protocol SelectCityDelegate: class {
  
  func didSelect(city: City)
  func useCurrentLocation()
  
}

/// A view controller that allows the user to select a `City`
class SelectCityTableViewController: UITableViewController {

  var cities: [City] = []
  weak var delegate: SelectCityDelegate?
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .default
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
    tableView.tableFooterView = UIView()
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: propertyKeys.cityCellIdentifier)
    
    loadCities()

    let swipe = UISwipeGestureRecognizer(target: self, action: #selector(swiped))
    view.addGestureRecognizer(swipe)
  }
  
  @objc func swiped() {
    performSegue(withIdentifier: propertyKeys.unwindToWeatherViewController, sender: self)
  }

  // MARK: - Table view data source

  override func numberOfSections(in tableView: UITableView) -> Int {
    
    return 2
  }
  
  
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    // create empty header for each section for visual separation
    return " "
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // section 0 has only 1 cell: Current Location, section 1 lists cities
    return section == 0 ? 1 : cities.count
  }

  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.section == 0 {
      let cell = UITableViewCell()
      cell.textLabel?.text = "Current Location"
      return cell
    } else {
      let cell = tableView.dequeueReusableCell(withIdentifier: propertyKeys.cityCellIdentifier, for: indexPath)
      
      cell.textLabel?.text = cities[indexPath.row].name
      
      return cell
    }
    
    
  }
  
  // MARK: - Table View Delegate
  
  override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    
    if indexPath.section == 1 {
      // the user selected a City, inform the delegate to use that City
      let city = cities[indexPath.row]
      delegate?.didSelect(city: city)
    } else {
      // no City selected, inform the delegate to use current location
      delegate?.useCurrentLocation()
    }
    
    return indexPath
  }
  
  // unwind to root view controller when cell is selected
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    performSegue(withIdentifier: propertyKeys.unwindToWeatherViewController, sender: self)
  }
  
  // first section is just current location, so shouldn't be editable
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return indexPath.section == 1 ? true : false
  }
  
  // swipe to delete cells
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    
    guard editingStyle == .delete else { return }
    // update model, update view, save
    cities.remove(at: indexPath.row)
    tableView.deleteRows(at: [indexPath], with: .automatic)
    saveCities()
  }
  
  // MARK: - Navigation

  @IBAction func unwindToSelectCityController(segue: UIStoryboardSegue) {
    // check if there is a new city to add
    guard segue.identifier == propertyKeys.saveUnwindSegue, let controller = segue.source as? LocationSearchTableViewController,
      let newCity = controller.city else { return }
    // update model, update view, save
    cities.append(newCity)
    tableView.reloadData()
    saveCities()
    
  }
  
  // MARK: - Data Persistence
  
  let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("cities")
  
  func saveCities() {
    do {
      let encoder = JSONEncoder()
      let data = try encoder.encode(cities)
      try data.write(to: url)
    } catch {
      print("Error saving data: \(error.localizedDescription)")
    }
  }
  
  func loadCities() {
    do {
      let decoder = JSONDecoder()
      let data = try Data(contentsOf: url)
      cities = try decoder.decode([City].self, from: data)
    } catch {
      print("Error loading data: \(error.localizedDescription)")
    }
  }
  

}
