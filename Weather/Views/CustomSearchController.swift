//
//  CustomSearchController.swift
//  Weather
//
//  Created by Nathaniel Cox on 5/5/19.
//  Copyright © 2019 Nathaniel Cox. All rights reserved.
//

import UIKit

/// Custom Search Controller subclass that uses custom search bar
class CustomSearchController: UISearchController, UISearchBarDelegate {
  
  lazy var _searchBar: CustomSearchBar = {
    [unowned self] in
    let customSearchBar = CustomSearchBar(frame: CGRect.zero)
    customSearchBar.delegate = self
    return customSearchBar
  }()
  
  override var searchBar: UISearchBar {
    return _searchBar
  }
  
}
