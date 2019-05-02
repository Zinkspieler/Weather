//
//  WeatherForecast.swift
//  Weather
//
//  Created by Nathaniel Cox on 1/19/19.
//  Copyright © 2019 Nathaniel Cox. All rights reserved.
//

import Foundation



struct WeatherForecastResult: Decodable {
  
  private let list: [WeatherForecast]
  
  // the results to display. The JSON returns a list of forecasts at 4-hour intervals.
  // This condences those results to one per day, finding the min and max temperature from the forecasts
  var results: [DisplayResult] {
    var results = [DisplayResult]()
    // TODO: at the moment, this simply uses the first id for a given day. A better approach would be to find the mode
    // of all the results with the same day
    var id = list[0].weather[0].id
    var day = list[0].day
    var maxTemp = list[0].maxTemp
    var minTemp = list[0].minTemp
    
    for i in 1..<list.count {
      
      if list[i].day != list[i-1].day {
        results.append(DisplayResult(id: id, day: day, maxTemp: maxTemp, minTemp: minTemp))
        id = list[i].weather[0].id
        day = list[i].day
        maxTemp = list[i].maxTemp
        minTemp = list[i].minTemp
      } else {
        maxTemp = max(maxTemp, list[i].maxTemp)
        minTemp = min(minTemp, list[i].minTemp)
      }
      
    }
    
    return results
  }
  
  /// The information from the Forecast Result to display
  struct DisplayResult {
    let id: Int
    let day: String
    let maxTemp: Double
    let minTemp: Double
  }
  
  struct WeatherForecast: Decodable {
    struct Weather: Decodable {
      let description: String
      let id: Int
    }
    
    private let dt: Double
    let maxTemp: Double
    let minTemp: Double
    let weather: [Weather]

    
    private var date: Date {
      return Date(timeIntervalSince1970: TimeInterval(dt))
    }
    
    
    var day: String {
      // get the current day of the week as an integer
      let calendar = Calendar.autoupdatingCurrent
      let today = calendar.component(.weekday, from: Date())
      // get the day of the week for the forecast as an integer
      let forecastDay = calendar.component(.weekday, from: date)
      
      let daysOfTheWeek = [1 : "Sunday", 2: "Monday", 3: "Tuesday", 4: "Wednesday", 5: "Thursday", 6: "Friday", 7: "Saturday"]
      // if the forecast is for today or tomorrow, return custom value, otherwise name of the day of the week
      switch (forecastDay - today) {
      case 0:
        return "Today"
      case 1, -6:
        return "Tomorrow"
      default:
        guard let day = daysOfTheWeek[forecastDay] else { return "" }
        return day
      }
    }
    
    private enum CodingKeys: String, CodingKey {
      case dt
      case main
      case weather
    }
    
    private enum MainCodingKeys: String, CodingKey {
      case maxTemp = "temp_max"
      case minTemp = "temp_min"
    }
    
    
    init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      let main = try container.nestedContainer(keyedBy: MainCodingKeys.self, forKey: .main)
      self.weather = try container.decode([Weather].self, forKey: .weather)
      self.dt = try container.decode(Double.self, forKey: .dt)
      self.maxTemp = try main.decode(Double.self, forKey: .maxTemp)
      self.minTemp = try main.decode(Double.self, forKey: .minTemp)
     
    }
    
    

  }
  
  
  
}
