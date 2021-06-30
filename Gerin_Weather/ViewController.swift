//
//  ViewController.swift
//  Gerin_Weather
//
//  Created by Gerin Puig on 2021-05-21.
//

import UIKit
import CoreLocation
import MapKit
import Combine

class ViewController: UIViewController {
    
    @IBOutlet weak var txtTemp: UILabel!
    @IBOutlet weak var txtFeelLIkeTemp: UILabel!
    @IBOutlet weak var txtWindSpeed: UILabel!
    @IBOutlet weak var txtWindDir: UILabel!
    @IBOutlet weak var txtUVIndex: UILabel!
    @IBOutlet weak var txtCity: UILabel!
    
    let geocoder = CLGeocoder()
    let locationManager = CLLocationManager()
    var myInfo:CLLocationCoordinate2D? = nil
    @IBOutlet weak var myMapKit: MKMapView!
    
    private let weatherFetcher = WeatherFetcher.getInstance()
    private var cancellables: Set<AnyCancellable> = []
    
    var cityName:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            print("Location access granted")
            
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        else{
            print("Location access denied")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){
            self.weatherFetcher.setCity(city: self.cityName)
            self.weatherFetcher.fetchDataFromAPI()
            self.receiveChanges()
        }
    }
    
    private func receiveChanges(){
        self.weatherFetcher.$weatherDataList.receive(on: RunLoop.main).sink{ (weatherData) in
            print("Data updates received")
            self.txtTemp.text = "Temperature: \(weatherData.temp) C"
            self.txtWindDir.text = "Wind Direction: \(weatherData.windDir)"
            self.txtWindSpeed.text = "Wind Speed: \(weatherData.windSpeed) k\\h"
            self.txtFeelLIkeTemp.text = "Feels Like: \(weatherData.feelsLike) C"
            self.txtUVIndex.text = "UV Index: \(weatherData.uvIndex)"
        }.store(in: &cancellables)
    }

    @IBAction func btnGetWeatherPressed(_ sender: UIButton) {
        self.weatherFetcher.setCity(city: cityName)
        self.weatherFetcher.fetchDataFromAPI()
        self.receiveChanges()
    }
    
}

extension ViewController:CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        //fetch device location
        guard let currentLocation:CLLocationCoordinate2D = manager.location?.coordinate else { return }
        
        print("Current Location: lat \(currentLocation.latitude)    lng \(currentLocation.longitude)")
        
        displayLocationOnMap(location: currentLocation)
        
        getAddress(location: CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude))
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Unable to get location \(error)")
    }
    
    func displayLocationOnMap(location:CLLocationCoordinate2D) {
        //zoom level
        let span = MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
        let region = MKCoordinateRegion(center: location, span: span)
        
        self.myMapKit?.setRegion(region, animated: true)
        
        //display annotation
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = "You"
        myMapKit?.addAnnotation(annotation)
    }
    
}

extension ViewController{
    func getAddress(location: CLLocation){
        geocoder.reverseGeocodeLocation(location, completionHandler: { placemark, error in
            self.processGeoResponse(placemarkList: placemark, error: error)
        })
    }
    
    func processGeoResponse(placemarkList: [CLPlacemark]?, error:Error?) {
        if error != nil{
            txtCity.text = "Unable to get address"
        }
        else{
            if let placemarks = placemarkList, let placemark = placemarks.first{
                let city = placemark.locality ?? "N/A"
                let country = placemark.country ?? "N/A"
                
                self.cityName = city
                txtCity.text = "\(city), \(country)"
            }else{
                txtCity.text = "No address is found"
            }
        }
    }
}
