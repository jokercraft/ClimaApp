//
//  ViewController.swift
//  WeatherApp
//
//  Created by Serdar Ilarslan on 21/06/2018.
//
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON


class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {

    
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "a5f114298517152eb9f17726d93e3796"
    

    //Declaring instance variables here
    
    let locationManager = CLLocationManager()
    var weatherDataModel = WeatherDataModel()
    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //Setting up the location manager here.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //getWeatherData method here:
    
    func getWeatherData(url : String , parameters : [String : String]){
        Alamofire.request(url, method : .get, parameters : parameters).responseJSON{
            response in
            if response.result.isSuccess{
                
                print("Success...")
                let weatherJSON : JSON = JSON(response.result.value!)
                self.updateWeatherData(json: weatherJSON)
                
            }else{
                
                print("Error \(String(describing: response.result.error))")
                self.cityLabel.text = "Internet Connection Issue"
                
            }
        }
    }

    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    // updateWeatherData method here:
    
    func updateWeatherData(json : JSON){
        if let tempResult = json["main"]["temp"].double{
        weatherDataModel.temperature = Int(tempResult - 273.15)
        weatherDataModel.city = json["name"].string!
        weatherDataModel.condition = json["weather"][0]["id"].intValue
        weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
        updateUIWithWeatherData()
        }else{
            cityLabel.text = "Weather Unavailable...Please try again later"
        }
    }

    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    // updateUIWithWeatherData method here:
    
    func updateUIWithWeatherData(){
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = "\(weatherDataModel.temperature)℃"
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
    }
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    // didUpdateLocations method here:
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0{
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            print("longtitude: \(location.coordinate.longitude)  latitude: \(location.coordinate.latitude)")
            
            let latitude = location.coordinate.latitude
            let longtitude = location.coordinate.longitude
            let params : [String : String] = [ "lat" : String(latitude), "lon" : String(longtitude), "appid" : APP_ID]
            getWeatherData(url : WEATHER_URL, parameters : params)
        }
    }
    
    // didFailWithError method here:
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavailable!"
    }
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //The userEnteredANewCityName Delegate method here:
    func userEnteredANewCityName(city: String) {
        let params : [String : String] = ["q" : city, "appid" : APP_ID]
        getWeatherData(url: WEATHER_URL, parameters: params)
    }

    
    //Write the PrepareForSegue Method here
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName"{
            let destinationVC = segue.destination as! ChangeCityViewController
            destinationVC.delegate = self
        }
    }
    
    
    
    
}


