//
//  WeatherViewModel.swift
//  Sample_Weatherapp
//
//  Created by mdigix on 2025/04/20.
//

import Foundation
import WeatherKit
import CoreLocation
import SwiftUI

@MainActor
class WeatherViewModel: ObservableObject {
    private let weatherService: WeatherService()
    
    @Published var currentTemperature: String = "Loading..."
    @Published var weatherDescription: String = "Loading..."
    @Published var weatherIcon: String = "⏳"
    @Published var humidity: String = "_"
    @Published var windSpeed: String = "_"
    
    func fetchWeather() async {
        let location = CLLocation(latitude: 35.6895, longitude: 139.6917)
        
        do {
            let weather = try await weatherService.weather(for: location)
            
            let temp = Int(weather.currentWeather.temperature.value)
            self.currentTemperature = "\(temp)°C"
            self.weatherDescription = weather.currentWeather.condition.description
            self.weatherIcon = getWeatherIcon(for: weather.currentWeather.condition)
            
            //詳細情報
            let humidityValue = Int(weather.currentWeather.humidity * 100)
            self.humidity = "\(humidityValue)%"
            self.windSpeed = String(format: "%.1f m/s", weather.currentWeather.wind.speed.value)
            
        } catch {
            print("❌ Error fetching weather:", error.localizedDescription)
            self.currentTemperature = "Error"
            self.currentDescription = "Faild to load weather"
            self.weatherIcon = "❓"
            self.humidity = "_"
            self.windSpeed = "_"
        }
    }
    func getWeatherIcon(for condition: WeatherCondition) -> String {
        switch condition {
        case .clear:
            return "☀️"
        case .cloudy mostlyCloudy:
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
        default :
            return "⏳"
        }
    }
}
            
        


