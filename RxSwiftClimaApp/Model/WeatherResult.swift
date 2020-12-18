//
//  WeatherResult.swift
//  RxSwiftClimaApp
//
//  Created by Evgeniy Uskov on 30.11.2020.
//

import Foundation

struct WeatherResult: Decodable {
    let main: Weather
    let weather: [WeatherDescription]
}

extension WeatherResult {
    static var empty: WeatherResult {
        return WeatherResult(main: Weather(temp: nil, humidity: nil),
                             weather: [WeatherDescription(main: nil, desc: nil)])
    }
}

struct Weather: Decodable {
    var temp: Double?
    var humidity: Double?
}

struct WeatherDescription: Decodable {
    var main: String?
    var desc: String?
    
    enum CodingKeys: String, CodingKey{
        case main
        case desc = "description"
    }
}
