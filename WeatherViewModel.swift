//
//  WeatherViewModel.swift
//  Sample_Weatherapp
//
//  Created by mdigix on 2025/04/20.
//

import Foundation
import SwiftUI
import CoreLocation
import WeatherKit

enum WeatherCondition {
    case sunny
    case cloudy
    case rainy
}

@MainActor
class WeatherViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    private let weatherService = WeatherService()
    
    // 🌡️ 基本情報
    @Published var currentLocationName: String = "Loading..."
    @Published var location: CLLocation?
    @Published var currentTemperature: String = "Loading..."
    @Published var weatherDescription: String = "Loading..."
    @Published var weatherIcon: String = "⏳"
    @Published var humidity: String = "_"
    @Published var windSpeed: String = "_"
    @Published var weatherCondition: WeatherCondition? = nil
    @Published var dailyForecasts: [Forecast] = []
    
    // 🌅 日の出・日の入り
    @Published var sunrise: String = "_"
    @Published var sunset: String = "_"
    
    // 📅 週間予報
    struct Forecast: Identifiable {
        let id = UUID()
        let day: String
        let icon: String
        let temp: String
    }
    
    func fetchWeather() async {
        let location = CLLocation(latitude: 35.6895, longitude: 139.6917)
        
        do {
            // 🌤️ 現在の天気取得
            let weather = try await weatherService.weather(for: location)
            self.currentTemperature = "\(Int(weather.currentWeather.temperature.value))°C"
            self.weatherDescription = weather.currentWeather.condition.description
            self.weatherCondition = mapWeatherCondition(weather.currentWeather.condition)
            
            let humidityValue = Int(weather.currentWeather.humidity * 100)
            self.humidity = "\(humidityValue)%"
            self.windSpeed = String(format: "%.1f m/s", weather.currentWeather.wind.speed.value)
            self.weatherIcon = getWeatherIcon(for: weather.currentWeather.condition)
            
            // 🌅 Astronomy データ取得
            //let astronomy = try await WeatherService.shared.astronomy(for: location, date: Date.now)
            
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            formatter.locale = Locale.current
            
            //self.sunrise = formatter.string(from: astronomy.sunrise)
            //self.sunset = formatter.string(from: astronomy.sunset)
            
            // 📅 週間予報
            self.dailyForecasts = weather.dailyForecast.forecast.prefix(5).map { day in
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale.current
                dateFormatter.dateFormat = "E" // 曜日 (例: 火)
                return Forecast(
                    day: dateFormatter.string(from: day.date),
                    icon: getWeatherIcon(for: day.condition),
                    temp: "\(Int(day.highTemperature.value))°C"
                )
            }
            
        } catch {
            print("❌ Error fetching weather:", error.localizedDescription)
            self.currentTemperature = "Error"
            self.weatherDescription = "Failed to load weather"
            self.weatherIcon = "❓"
            self.humidity = "_"
            self.windSpeed = "_"
            self.sunrise = "_"
            self.sunset = "_"
            self.dailyForecasts = []
        }
    }
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    private func fetchLocationName(for location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let placemark = placemarks?.first {
                self.currentLocationName = placemark.locality ?? "Unknown location"
            } else {
                self.currentLocationName = "Unknown location"
                
            }
        }
    }
}

    

    

    
    // 🌦️ 天気アイコン取得
    private func getWeatherIcon(for condition: WeatherKit.WeatherCondition) -> String {
        switch condition {
        case .clear:
            return "☀️"
        case .cloudy, .mostlyCloudy:
            return "☁️"
        case .partlyCloudy:
            return "🌤️"
        case .rain:
            return "🌧️"
        case .thunderstorms:
            return "⚡️"
        case .snow:
            return "❄️"
        case .foggy:
            return "🌫️"
        default:
            return "⏳"
        }
    }
    // 🌤️ 天気Conditionのマッピング（WeatherKit → 独自定義）
    private func mapWeatherCondition(_ condition: WeatherKit.WeatherCondition) -> WeatherCondition {
        switch condition {
        case .clear, .mostlyClear, .partlyCloudy:
            return .sunny
        case .cloudy, .mostlyCloudy, .foggy:
            return .cloudy
        case .rain, .drizzle, .thunderstorms, .snow:
            return .rainy
        default:
            return .cloudy
        }
    }

