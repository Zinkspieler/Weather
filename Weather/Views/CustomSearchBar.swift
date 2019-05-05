//
//  CustomSearchBar.swift
//  Weather
//
//  Created by Nathaniel Cox on 5/5/19.
//  Copyright © 2019 Nathaniel Cox. All rights reserved.
//

import UIKit

/// Custom search bar subclass that allows the cancel button to remain hidden
class CustomSearchBar: UISearchBar {

  override func setShowsCancelButton(_ showsCancelButton: Bool, animated: Bool) {
    super.setShowsCancelButton(false, animated: false)
  }
}
