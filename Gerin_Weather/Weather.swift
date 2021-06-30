//
//  Weather.swift
//  Gerin_Weather
//
//  Created by Gerin Puig on 2021-05-21.
//

import Foundation

struct Weather:Codable {
    var temp:Double //temp_c
    var feelsLike:Double //feelslike_c
    var windSpeed:Double //wind_kph
    var windDir:String //wind_dir
    var uvIndex:Double //uv
    
    init() {
        self.temp = 0.0
        self.feelsLike = 0.0
        self.windSpeed = 0.0
        self.windDir = ""
        self.uvIndex = 0.0
    }
    
    enum CodingKeys:String, CodingKey{
        case current = "current"
        case temp = "temp_c"
        case feelsLike = "feelslike_c"
        case windSpeed = "wind_kph"
        case windDir = "wind_dir"
        case uvIndex = "uv"
    }
    
    func encode(to encoder: Encoder) throws {
        //nothing
    }
    
    init(from decoder: Decoder) throws {
        let response = try decoder.container(keyedBy: CodingKeys.self)
        
        let currentData = try response.decodeIfPresent(CurrentData.self, forKey: .current)
        self.feelsLike = currentData?.feelsLike ?? 0.0
        self.windSpeed = currentData?.windSpeed ?? 0.0
        self.uvIndex = currentData?.uvIndex ?? 0.0
        self.windDir = currentData?.windDir ?? ""
        self.temp = currentData?.temp ?? 0.0
    }
}

struct CurrentData:Codable {
    var feelsLike:Double //feelslike_c
    var windSpeed:Double //wind_kph
    var windDir:String //wind_dir
    var uvIndex:Double //uv
    var temp:Double
    
    enum CodingKeys:String, CodingKey{
        case feelsLike = "feelslike_c"
        case windSpeed = "wind_kph"
        case windDir = "wind_dir"
        case uvIndex = "uv"
        case temp = "temp_c"
    }
    
    func encode(to encoder: Encoder) throws {
        //nothing
    }
    
    init(from decoder: Decoder) throws {
        let response = try decoder.container(keyedBy: CodingKeys.self)
        self.feelsLike = try response.decodeIfPresent(Double.self, forKey: .feelsLike) ?? 0.0
        self.windSpeed = try response.decodeIfPresent(Double.self, forKey: .windSpeed) ?? 0.0
        self.windDir = try response.decodeIfPresent(String.self, forKey: .windDir) ?? "cant find"
        self.uvIndex = try response.decodeIfPresent(Double.self, forKey: .uvIndex) ?? 0.0
        self.temp = try response.decodeIfPresent(Double.self, forKey: .temp) ?? 0.0
    }
}
