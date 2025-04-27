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
    case mostlyCloudy
    case partlyCloudy
    case rainy
    case foggy
    case thunderstorms
    case snow
    case clear
    case mostlyclear
    
    
}


class WeatherViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    // 📍 現在地が更新されたら呼ばれる
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print("📍 現在地取得: \(location.coordinate.latitude), \(location.coordinate.longitude)")
            Task { @MainActor in
                self.fetchLocationName(for: location)
                await self.fetchWeather(for: location)
            }
        } else {
            print("⚠️ 位置情報が取得できませんでした。")
        }
    }
    
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    private let weatherService = WeatherService()
    
    // 🌡️ 基本情報
    @Published var currentLocationName: String = "Loading..."
    @Published var currentTemperature: String = "Loading..."
    @Published var weatherDescription: String = "Loading..."
    @Published var weatherIcon: String = "⏳"
    @Published var humidity: String = "_"
    @Published var windSpeed: String = "_"
    @Published var weatherCondition: WeatherCondition? = nil
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    
    
    // 🌍 住所名取得
    @MainActor
    private func fetchLocationName(for location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let placemark = placemarks?.first {
                self.currentLocationName = placemark.locality ?? "Unknown location"
            } else {
                self.currentLocationName = "Unknown location"
        }
    }
}
    
    // 🌦️ 天気情報取得
    @MainActor
    func fetchWeather(for location: CLLocation) async {
        do {
            let weather = try await weatherService.weather(for: location)
            self.currentTemperature = "\(Int(weather.currentWeather.temperature.value))°C"
            self.weatherDescription = weather.currentWeather.condition.description
            let mappedCondition = mapWeatherCondition(weather.currentWeather.condition)
            self.weatherCondition = mappedCondition
            
            
            let humidityValue = Int(weather.currentWeather.humidity * 100)
            self.humidity = "\(humidityValue)%"
            self.windSpeed = String(format: "%.1f m/s", weather.currentWeather.wind.speed.value)
            
            
            self.weatherIcon = getWeatherIcon(for: mappedCondition)
            
        } catch {
            print("❌ Error fetching weather:", error.localizedDescription)
            self.currentTemperature = "Error"
            self.weatherDescription = "Failed to load weather"
            self.weatherIcon = "❓"
            self.humidity = "_"
            self.windSpeed = "_"
        }
    }

    


    // 🌤️ 天気Conditionのマッピング（WeatherKit → 独自定義）
    private func mapWeatherCondition(_ condition: WeatherKit.WeatherCondition) -> WeatherCondition {
        switch condition {
        case .clear, .mostlyClear, .partlyCloudy:
            return .sunny
        case .cloudy, .mostlyCloudy, .foggy:
            return .cloudy
        case .rain, .drizzle, .thunderstorms:
            return .rainy
        default:
            return .cloudy
        }
    }

    // 🌈 天気アイコン取得
    private func getWeatherIcon(for condition: WeatherCondition) -> String {
        switch condition {
        case .clear:
            return "☀️"
        case .cloudy, .mostlyCloudy:
            return "☁️"
        case .partlyCloudy:
            return "🌤️"
        case .rainy:
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
}
