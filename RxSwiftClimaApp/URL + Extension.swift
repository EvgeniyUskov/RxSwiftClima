//
//  URL + Extension.swift
//  RxSwiftClimaApp
//
//  Created by Evgeniy Uskov on 11.12.2020.
//

import Foundation

extension URL {
    static func urlForWeatherAPI(city: String) -> URL? {
        let API_KEY = "602bd76403b6c805beffd65666648373"
        if let cityEncoded = city.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
        return URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(cityEncoded)&APPID=\(API_KEY)&units=imperial")
        }
        return nil
    }
}
