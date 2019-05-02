//
//  SelectCityTableViewController.swift
//  Weather
//
//  Created by Nathaniel Cox on 4/30/19.
//  Copyright © 2019 Nathaniel Cox. All rights reserved.
//

import UIKit

protocol SelectCityDelegate {
  
  func didSelect(city: City)
  func useCurrentLocation()
  
}

class SelectCityTableViewController: UITableViewController {

  var cities: [City] = []
  var delegate: SelectCityDelegate?
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .default
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
    tableView.tableFooterView = UIView()
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: propertyKeys.cityCellIdentifier)
    
    loadCities()

  }

  // MARK: - Table view data source

  override func numberOfSections(in tableView: UITableView) -> Int {
    
    return 2
  }
  
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return " "
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
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
      let city = cities[indexPath.row]
      delegate?.didSelect(city: city)
    } else {
      delegate?.useCurrentLocation()
    }
    
    return indexPath
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    performSegue(withIdentifier: propertyKeys.unwindToWeatherViewController, sender: self)
  }
  
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return indexPath.section == 1 ? true : false
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    guard editingStyle == .delete else { return }
    
    cities.remove(at: indexPath.row)
    tableView.deleteRows(at: [indexPath], with: .automatic)
    saveCities()
  }
  
  // MARK: - Navigation

  @IBAction func unwindToSelectCityController(segue: UIStoryboardSegue) {
    guard segue.identifier == propertyKeys.saveUnwindSegue, let controller = segue.source as? AddCityTableViewController,
      let newCity = controller.city else { return }
    
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
