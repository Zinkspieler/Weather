//
//  WeatherManager.swift
//  Weather
//
//  Created by Nathaniel Cox on 1/15/19.
//  Copyright © 2019 Nathaniel Cox. All rights reserved.
//

import Foundation

class WeatherManager {
  
  private struct Constants {
    static let baseURL = "https://api.openweathermap.org/data/2.5"
    static let appID = "abc31d63cf8d09eeb1149c32265e89ac"
  }
  
  enum Unit: String {
    case metric, imperial
  }
  
  
  var result: WeatherResult?
  var forecast: WeatherForecastResult?
  var measurementUnit: Unit = .imperial
  var errorMessage = ""
  
  private let defaultSession = URLSession(configuration: .default)
  private var weatherTask: URLSessionDataTask?
  private var forecastTask: URLSessionDataTask?
  
  func performWeatherRequest(lat: String, lon: String, completion: @escaping (WeatherResult?, String) -> ()) {
    weatherTask?.cancel()

    guard let url = weatherURL(lat: lat, lon: lon) else { return }
    
    weatherTask = defaultSession.dataTask(with: url) { (data, response, error) in
      defer { self.weatherTask = nil }
      
      if let error = error {
        self.errorMessage += "Weather dataTask error: " + error.localizedDescription + "\n"
      } else if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
        
        do {
          let decoder = JSONDecoder()
          self.result = try decoder.decode(WeatherResult.self, from: data)
          
        } catch {
          print("Error parsing json: \(error)")
        }
        
        DispatchQueue.main.async {
          completion(self.result, self.errorMessage)
        }
      }
    }
    
    weatherTask?.resume()
  }
  
  func performWeatherForecastRequest(lat: String, lon: String, completion: @escaping (WeatherForecastResult?, String) -> ()) {
    forecastTask?.cancel()
    
    guard let url = weatherURL(lat: lat, lon: lon, forecast: true) else { return }
    
    forecastTask = defaultSession.dataTask(with: url) { (data, response, error) in
      defer { self.forecastTask = nil }
      
      if let error = error {
        self.errorMessage += "Forecast dataTask error: " + error.localizedDescription + "\n"
      } else if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
  
        do {
          let decoder = JSONDecoder()
          self.forecast = try decoder.decode(WeatherForecastResult.self, from: data)
        } catch {
          print("Error decoding weather forecast result \(error.localizedDescription)")
        }
        
        DispatchQueue.main.async {
          completion(self.forecast, self.errorMessage)
        }
      }
    }
    forecastTask?.resume()
  }
  
  /// Form a URL for making a weather request
  /// - parameter lat: latitude in format %.2f
  /// - parameter lon: longitude in format %.2f
  /// - parameter forecast: whether the request is for a forecast (default is for current weather)
  /// - returns: A valid URL for a weather request, or nil if a valid URL could not be constructed
  private func weatherURL(lat: String, lon: String, forecast: Bool = false) -> URL? {
    
    let urlString = Constants.baseURL + (forecast ? "/forecast?" : "/weather?")
      + "lat=" + lat + "&lon=" + lon
      + "&appid=" + Constants.appID
      + "&units=" + measurementUnit.rawValue
    return URL(string: urlString)
  }

  

}
