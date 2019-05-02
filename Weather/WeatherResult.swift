//
//  WeatherModel.swift
//  Weather
//
//  Created by Nathaniel Cox on 1/13/19.
//  Copyright © 2019 Nathaniel Cox. All rights reserved.
//

import Foundation

struct WeatherResult: Decodable {
  struct Weather: Decodable {
    let description: String
    let id: Int
  }
  private enum CodingKeys: String, CodingKey {
    case city = "name"
    case main
    case weather
  }
  
 
  
  private enum MainCodingKeys: String, CodingKey {
    case temperature = "temp"
  }
  
  // The JSON returns an array of weather objects with only one element. Just to annoy me.
  private var weather: [Weather]
  
  /// The city or locale for the weather result
  var city: String
  /// The current temperature at the locale
  var temperature: Double
  // The description is nested inside an array in the JSON response, so it
  // must be unpacked as a computer property.
  var description: String {
    return weather.first?.description ?? "description not found"
  }
  // The weather id number is nested inside an array, like the description.
  /// The weather id number for the weather result.
  var id: Int {
    return weather.first?.id ?? 800
  }
  
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let main = try container.nestedContainer(keyedBy: MainCodingKeys.self, forKey: .main)
    self.weather = try container.decode([Weather].self, forKey: .weather)
    self.temperature = try main.decode(Double.self, forKey: .temperature)
    self.city = try container.decode(String.self, forKey: .city)
  }
  
  
}

