//
//  AddCityTableViewController.swift
//  Weather
//
//  Created by Nathaniel Cox on 5/2/19.
//  Copyright © 2019 Nathaniel Cox. All rights reserved.
//

import UIKit

/// A view controller that allows the user to add a new `City` to the list of available Cities
class AddCityTableViewController: UITableViewController {

  @IBOutlet weak var nameTextField: UITextField!
  @IBOutlet weak var latTextField: UITextField!
  @IBOutlet weak var lonTextField: UITextField!
  
  var city: City?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.tableFooterView = UIView()
  }

  // MARK: - Navigation
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard segue.identifier == propertyKeys.saveUnwindSegue else { return }
    // Ensure that there are valid values for latitude and longitude before creating a new City object
    guard let cityName = nameTextField.text,
      let latString = latTextField.text, let lat = Double(latString), lat >= -90, lat <= 90,
      let lonString = lonTextField.text, let lon = Double(lonString), lon >= -180, lon <= 180 else {
        // TODO: - Notify user that save failed
        print("Failed to create new city")
        return
    }
  
    city = City(name: cityName, latitude: lat, longitude: lon)
  }

}
