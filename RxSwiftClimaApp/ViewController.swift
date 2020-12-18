//
//  ViewController.swift
//  RxSwiftClimaApp
//
//  Created by Evgeniy Uskov on 30.11.2020.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    let API_KEY = "c77efaf75561a5efe09e13392a44f50d"
    var disposeBag = DisposeBag()
    
    @IBOutlet weak var cityNameTextField: UITextField!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        self.cityNameTextField.rx.controlEvent(.editingDidEndOnExit)
            .asObservable()
            .map{ self.cityNameTextField.text }
            .subscribe(onNext: {
                city in
                if let city = city {
                    if city.isEmpty {
                        self.displayWeather(nil)
                    } else {
                        self.fetchWeather(by: city)
                    }
                }
            }).disposed(by: disposeBag)
        
        // on every change in textField
//        self.cityNameTextField.rx.value
//            .subscribe(onNext: {
//                city in
//                if let city = city {
//                    if city.isEmpty {
//                        self.displayWeather(nil)
//                    } else {
//                        self.fetchWeather(by: city)
//                    }
//                }
//            }).disposed(by: disposeBag)
    }
    
    private func displayWeather(_ weather: WeatherResult?) {
        if let weather = weather,
           let temp = weather.main.temp {
            if temp >= 32.0 {
                self.changeImage(toImage: UIImage(named: "hot"))
            } else if temp < 32.0 && temp >= 15 {
                self.changeImage(toImage: UIImage(named: "rainy"))
            } else if temp < 15 {
                self.changeImage(toImage: UIImage(named: "night"))
            }
            self.changeLabels(weather: weather)
            
        } else {
            self.tempLabel.text = "No data"
            self.humidityLabel.text = "No data"
            self.conditionLabel.text = "No data"
        }
    }
    
    private func fetchWeather(by city: String) {
        guard let url = URL.urlForWeatherAPI(city: city) else {return}
        let resource = Resource<WeatherResult>(url: url)
        
        let search = URLRequest.load(resource: resource)
                   .observeOn(MainScheduler.instance)// execution on main Queue
            .retry(3)
            .catchError { error in
                print(error)
                return Observable.of(WeatherResult.empty)
            }.asDriver(onErrorJustReturn: WeatherResult.empty)
        
//        let search = URLRequest.load(resource: resource)
//            .observeOn(MainScheduler.instance)// execution on main Queue
//            .asDriver(onErrorJustReturn: WeatherResult.empty)
       
        search.map {
            print($0)
            if let temp = $0.main.temp {
                return "\(temp) ℉"
            }
            return "No data"
        }
            .drive(self.tempLabel.rx.text)
            .disposed(by: disposeBag)
        
        search.map {
            if let hum = $0.main.humidity {
                return "\(hum) %"
            }
            return "No data"
        }
            .drive(self.humidityLabel.rx.text)
            .disposed(by: disposeBag)
        
        search.map {
            if let desc = $0.weather[0].desc {
                return "\(desc)"
            }
            return "No data"
        }
            .drive(self.conditionLabel.rx.text)
            .disposed(by: disposeBag)
        
//            .subscribe(
//                onNext: {
//                    result in
//                    let weather = result
//                    self.displayWeather(weather)
//
//                }).disposed(by: disposeBag)
        }
}

extension ViewController {
    
    private func changeImage(toImage image: UIImage?) {
        guard let image = image else {return}
        UIView.transition(with: imageView,
                          duration: 0.75,
                          options: .transitionCrossDissolve,
                          animations: { self.imageView.image = image },
                          completion: nil)
    }
    
    private func changeLabels(weather: WeatherResult) {
        if let temp = weather.main.temp,
           let humidity = weather.main.humidity,
           let description = weather.weather[0].desc {
        UIView.transition(with: tempLabel,
                          duration: 0.75,
                          options: .transitionFlipFromBottom,
                          animations: { self.tempLabel.text = "\(temp) ℉" },
                          completion: nil)
        UIView.transition(with: humidityLabel,
                          duration: 0.75,
                          options: .transitionFlipFromBottom,
                          animations: { self.humidityLabel.text = "\(humidity) ％" },
                          completion: nil)
        UIView.transition(with: conditionLabel,
                          duration: 0.75,
                          options: .transitionFlipFromBottom,
                          animations: { self.conditionLabel.text = description },
                          completion: nil)
        }
    }
    
    private func setupUI() {
        self.tempLabel.text = ""
        self.humidityLabel.text = ""
        self.conditionLabel.text = ""
    }
}

