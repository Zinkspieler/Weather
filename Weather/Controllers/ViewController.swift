//
//  ViewController.swift
//  Weather
//
//  Created by Nathaniel Cox on 10/7/18.
//  Copyright © 2018 Nathaniel Cox. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController, CLLocationManagerDelegate {

  @IBOutlet weak var cityLabel: UILabel!
  @IBOutlet weak var weatherDescriptionLabel: UILabel!
  @IBOutlet weak var backgroundImageView: UIImageView!
  @IBOutlet weak var temperatureButton: UIButton!
  
  @IBOutlet weak var tableView: UITableView!
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  let locationManager = CLLocationManager()
  var location: CLLocation?
  
  var city: City?
  
  var lastLocationError: Error?
  var updatingLocation: Bool = false
  
  var timer: Timer?
  
  let weatherManager = WeatherManager()
  var weatherResult: WeatherResult?
  
  var forecasts: WeatherForecastResult?
  
  // MARK: - Object LifeCycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let swipe = UISwipeGestureRecognizer(target: self, action: #selector(swiped))
    swipe.direction = .left
    view.addGestureRecognizer(swipe)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if let city = city {
      let location = CLLocation(latitude: city.latitude, longitude: city.longitude)
      getWeather(location: location)
    } else {
      getLocation()
    }
    updateUI()
  }

  @IBAction func temperatureButtonPressed(_ sender: Any) {
    viewDidAppear(true)
  }
  
  @objc func swiped() {
    performSegue(withIdentifier: propertyKeys.selectCitySegue, sender: self)
  }
  
  func updateUI() {
    tableView.reloadData()
    if let weatherResult = weatherResult {
      cityLabel.text = weatherResult.city
      temperatureButton.setTitle("\(Int(weatherResult.temperature))°", for: .normal)
      weatherDescriptionLabel.text = weatherResult.description
      backgroundImageView.image = backgroundImage(forId: weatherResult.id)
    } else {
      cityLabel.text = ""
      temperatureButton.setTitle("", for: .normal)
      if location == nil {
        weatherDescriptionLabel.text = "Searching..."
      } else if weatherResult == nil {
        weatherDescriptionLabel.text = "Fetching weather..."
      } else {
        weatherDescriptionLabel.text = "Unable to get local weather"
      }
      
    }
  }
  
  /// Gets a UIImage from the bundle for a given weather id number
  /// - parameter id: The weather id number representing a range of weather conditions
  /// - returns: a UIImage appropriate for the weather condition
  private func backgroundImage(forId id: Int) -> UIImage? {
    switch id {
    case 200...232:
      return UIImage(named: "thunderstormBackground")
    case 300...531:
      return UIImage(named: "rainBackground")
    case 800...802:
      return UIImage(named: "sunnyBackground")
    default:
      return UIImage(named: "cloudBackground")
    }
  }
  
  /// Gets the users location
  func getLocation() {
    let authStatus = CLLocationManager.authorizationStatus()
    switch authStatus {
    case .notDetermined:
      locationManager.requestWhenInUseAuthorization()
      return
    case .denied, .restricted:
      showLocationDeniedAlert()
      return
    case .authorizedAlways, .authorizedWhenInUse:
      if updatingLocation {
        stopLocationManager()
      } else {
        location = nil
        lastLocationError = nil
        startLocationManager()
      }
    @unknown default:
      print("CLLocationManager.authorizationStatus has been updated with a new case.")
    }
    
  }
  
  // MARK:- Networking
  
  /// Makes a request for weather results and updates the UI
  /// - parameter location: The location to use for the weather request
  func getWeather(location: CLLocation) {
    let lat = String(format: "%.2f", location.coordinate.latitude)
    let lon = String(format: "%.2f", location.coordinate.longitude)
    UIApplication.shared.isNetworkActivityIndicatorVisible = true
    weatherManager.performWeatherRequest(lat: lat, lon: lon) { (result, errorMessage) in
      UIApplication.shared.isNetworkActivityIndicatorVisible = false
      if let result = result {
        self.weatherResult = result
        self.updateUI()
        print("\(result.city)")
      }
      if !errorMessage.isEmpty {
        print("Error fetching weather: \(errorMessage)")
      }
    }
    weatherManager.performWeatherForecastRequest(lat: lat, lon: lon) { (result, errorMessage) in
      if let result = result {
        self.forecasts = result
        self.updateUI()
      }
      if !errorMessage.isEmpty {
        print("Error fetching forecast: \(errorMessage)")
      }
    }
  }
  
  // MARK:- Helper Methods
  func startLocationManager() {
    if CLLocationManager.locationServicesEnabled() {
      locationManager.delegate = self
      locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
      locationManager.startUpdatingLocation()
      updatingLocation = true
      timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(didTimeOut), userInfo: nil, repeats: false)
    }
    
  }
  
  func stopLocationManager() {
    if updatingLocation {
      locationManager.stopUpdatingLocation()
      locationManager.delegate = nil
      updatingLocation = false
      if let timer = timer {
        timer.invalidate()
      }
    }
  }
  
  @objc func didTimeOut() {
    print("*** Time Out")
    if location == nil {
      stopLocationManager()
      lastLocationError = NSError(domain: "MyLocationsErrorDomain", code: 1, userInfo: nil)
      updateUI()
    }
  }
  
  /// Shows an alert if the user has disabled location services.
  ///
  /// Gives the user the option to directly open settings to enable location services.
  func showLocationDeniedAlert() {
    let title = "Location Services Disabled"
    let message = "To get current location, enable location services for this app in Settings"
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
    let enableAction = UIAlertAction(title: "Enable", style: .default) { (action) in
      guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
        return
      }
      if UIApplication.shared.canOpenURL(settingsURL) {
        UIApplication.shared.open(settingsURL, completionHandler: nil)
      }
    }
    alert.addAction(okAction)
    alert.addAction(enableAction)
    present(alert, animated: true, completion: nil)
  }
  
  // MARK: - Navigation
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let navController = segue.destination as? UINavigationController, let controller = navController.viewControllers.first as? SelectCityTableViewController else { return }
    
    controller.delegate = self
  }
  
  @IBAction func unwindToWeatherViewController(segue: UIStoryboardSegue) {
    
  }
  
  // MARK:- Location Manager Deleagate
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("didFailWithError: \(error.localizedDescription)")
    
    if (error as NSError).code == CLError.locationUnknown.rawValue {
      return
    }
    lastLocationError = error
    stopLocationManager()
    updateUI()
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    let newLocation = locations.last!
    print("didUpdateLocations: \(newLocation)")
    
    if newLocation.timestamp.timeIntervalSinceNow < -5 {
      return
    }
    
    if newLocation.horizontalAccuracy < 0 {
      return
    }
    
    if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy {
      location = newLocation
      lastLocationError = nil
      
      if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
        stopLocationManager()
      }
      
      updateUI()
      getWeather(location: location!)
    }
    
    
  }


}

// MARK: - TableView delegate and data source

extension WeatherViewController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 44
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let forecasts = forecasts {
      return forecasts.results.count
    } else {
      return 0
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let forecasts = forecasts else {
      // TODO: handle no forecasts case
      return UITableViewCell()
    }
    let cell = tableView.dequeueReusableCell(withIdentifier: propertyKeys.forecastCellIdentifier, for: indexPath) as! ForecastCell
    
    let forecast = forecasts.results[indexPath.row]
    cell.dayLabel.text = forecast.day
    cell.maxTempLabel.text = String(Int(forecast.maxTemp))
    cell.minTempLabel.text = String(Int(forecast.minTemp))
    cell.iconImageVIew.image = iconImage(forId: forecast.id)
    
    return cell
  }
  
  /// Gets a UIImage from the bundle for a given weather id number
  /// - parameter id: The weather id number representing a range of weather conditions
  /// - returns: a UIImage appropriate for the weather condition
  private func iconImage(forId id: Int) -> UIImage? {
    let imageName: String = {
      switch id {
      case 200..<300: return "thunder"
      case 300..<400: return "lightRain"
      case 500..<600: return "rain"
      case 600..<700: return "snow"
      case 700..<800: return "cloudy"
      case 800: return "sunny"
      case 801: return "partiallyCloudy"
      case 802...804: return "cloudy"
      default: return "sunny"
      }
    }()
    let image = UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate)
    return image
  }
  
}

// MARK: - Select City Delegate

extension WeatherViewController: SelectCityDelegate {
  
  func didSelect(city: City) {
    self.city = city
  }
  
  func useCurrentLocation() {
    city = nil
  }
}
