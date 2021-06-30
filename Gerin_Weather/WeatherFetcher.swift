//
//  WeatherFetcher.swift
//  Gerin_Weather
//
//  Created by Gerin Puig on 2021-05-21.
//

import Foundation

class WeatherFetcher: ObservableObject {
    var apiURL = "https://api.weatherapi.com/v1/current.json?key=0e512c8791cc45d0bdb225319212105&q=toronto&aqi=no"
    
    @Published var weatherDataList = Weather()
    
    private static var shared:WeatherFetcher?
    
    static func getInstance() -> WeatherFetcher{
        if shared != nil{
            //instance already exists
            return shared!
        }
        else
        {
            shared = WeatherFetcher()
            return shared!
        }
    }
    
    func setCity(city:String){
        apiURL = "https://api.weatherapi.com/v1/current.json?key=0e512c8791cc45d0bdb225319212105&q=" + city + "&aqi=no"
    }
    
    func fetchDataFromAPI(){
        //convert string to url
        guard let api = URL(string: apiURL) else {
            return
        }
        
        //initiate data transfer over network
        //must .resume() at end of {}
        URLSession.shared.dataTask(with: api){ (data: Data?, response: URLResponse?, error: Error?) in
            
            if let err = error
            {
                print("\(err)")
            }
            else
            {
                DispatchQueue.global().async {
                    do
                    {
                        if let jsonData = data{
                            let decoder = JSONDecoder()
                            
                            //one json object
                            let decodedList = try decoder.decode(Weather.self, from: jsonData)
                            
                            DispatchQueue.main.async {
                                self.weatherDataList = decodedList
                                print(self.weatherDataList)
                            }
                            
                        }
                        else{
                            print("No json data received")
                        }
                    }
                    catch let error{
                        print(error)
                    }
                }
            }
        }.resume()
    }
}
