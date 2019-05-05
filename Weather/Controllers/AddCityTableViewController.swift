//
//  AddCityTableViewController.swift
//  Weather
//
//  Created by Nathaniel Cox on 5/2/19.
//  Copyright © 2019 Nathaniel Cox. All rights reserved.
//

import UIKit

/// A view controller that allows the user to add a new `City` to the list of available Cities
class AddCityViewController: UIViewController {
  
  var city: City?
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }

  // MARK: - Navigation
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard segue.identifier == propertyKeys.saveUnwindSegue else { return }
   
  }

}
