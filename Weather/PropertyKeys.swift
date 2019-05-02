//
//  PropertyKeys.swift
//  Weather
//
//  Created by Nathaniel Cox on 5/2/19.
//  Copyright © 2019 Nathaniel Cox. All rights reserved.
//

import Foundation


struct PropertyKeys {
  let forecastCellIdentifier = "ForecastCell"
  let cityCellIdentifier = "cityCell"
  let unwindToWeatherViewController = "unwindSegue"
  let saveUnwindSegue = "saveUnwind"
  
  fileprivate init() { }
}

let propertyKeys = PropertyKeys()

