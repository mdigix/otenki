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

struct HourlyForecast: Identifiable {
    let id = UUID()
    let time: String
    let iconName: String
    let temperature: String
}

struct DailyForecast: Identifiable {
    let id = UUID()
    let date: String
    let iconName: String
    let temperatureRange: String
}

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
    
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    private let weatherService = WeatherService()
    private var lastGeocodeTime: Date?
    
    // 基本情報
    @Published var currentLocationName: String = "Loading..."
    @Published var currentTemperature: String = "Loading..."
    @Published var weatherDescription: String = "Loading..."
    @Published var weatherIcon: String = "⏳"
    @Published var humidity: String = "_"
    @Published var windSpeed: String = "_"
    @Published var weatherCondition: WeatherCondition? = nil
    @Published var location: CLLocation?
    @Published var hourlyForecasts: [HourlyForecast] = []
    @Published var dailyForecasts: [DailyForecast] = []
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    // 現在地が更新されたら呼ばれる
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print("📍 現在地取得: \(location.coordinate.latitude), \(location.coordinate.longitude)")
            Task { @MainActor in
                self.location = location
                self.fetchLocationName(for: location)
                await self.fetchWeather(for: location)
            }
        } else {
            print("⚠️ 位置情報が取得できませんでした。")
        }
    }
    
    // 住所名取得
    @MainActor
     func fetchLocationName(for location: CLLocation) {
        let now = Date()
        if let lastTime = lastGeocodeTime, now.timeIntervalSince(lastTime) < 10 {
            // 10秒以内はスキップ
            return
        }
        lastGeocodeTime = now
        
         geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self else { return }
            if let placemark = placemarks?.first {
                self.currentLocationName = placemark.locality ?? "Unknown location"
            } else {
                self.currentLocationName = "Unknown location"
            }
        }
    }
    
    // 天気情報取得
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
            
            self.hourlyForecasts = weather.hourlyForecast.forecast.map { hourlyWeather in
                let formatter = DateFormatter()
                formatter.timeStyle = .short
                formatter.dateStyle = .none
                let timeString = formatter.string(from: hourlyWeather.date)
                
                return HourlyForecast(
                    time: timeString,
                    iconName: getWeatherIcon(for: mapWeatherCondition(hourlyWeather.condition)),
                    temperature: String(format: "%.1f°C", hourlyWeather.temperature.value)
                )
            }
            
            self.dailyForecasts = weather.dailyForecast.forecast.map { dailyWeather in
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "M/d"
                let dateString = dateFormatter.string(from: dailyWeather.date)
                
                let minTemp = Int(dailyWeather.lowTemperature.value)
                let maxTemp = Int(dailyWeather.highTemperature.value)
                let temperatureRangeString = "\(minTemp)°C - \(maxTemp)°C"
                
                let mappedCondition = mapWeatherCondition(dailyWeather.condition)
                let iconNameString = getWeatherIcon(for: mappedCondition)
                
                return DailyForecast(
                    date: dateString,
                    iconName: iconNameString,
                    temperatureRange: temperatureRangeString
                )
            }
            
            } catch {
                print("❌ Error fetching weather:", error.localizedDescription)
                self.currentTemperature = "Error"
                self.weatherDescription = "Failed to load weather"
                self.weatherIcon = "❓"
                self.humidity = "_"
                self.windSpeed = "_"
                self.hourlyForecasts = []
                self.dailyForecasts = []
            }
        }
        
        // 天気Conditionのマッピング（WeatherKit → 独自定義）
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
        
        // 天気アイコン取得
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
