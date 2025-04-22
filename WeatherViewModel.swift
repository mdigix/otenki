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
    private let weatherService = WeatherService()

    @Published var currentTemperature: String = "Loading..."
    @Published var weatherDescription: String = "Loading..."
    @Published var weatherIcon: String = "⏳"
    @Published var humidity: String = "_"
    @Published var windSpeed: String = "_"
    @Published var weatherCondition: WeatherCondition? = nil

    // ✅ 正しい fetchWeather の位置
    func fetchWeather() async {
        let location = CLLocation(latitude: 35.6895, longitude: 139.6917)

        do {
            let weather = try await weatherService.weather(for: location)

            self.currentTemperature = "\(Int(weather.currentWeather.temperature.value))°C"
            self.weatherDescription = weather.currentWeather.condition.description
            self.weatherCondition = weather.currentWeather.condition

            // 詳細情報
            let humidityValue = Int(weather.currentWeather.humidity * 100)
            self.humidity = "\(humidityValue)%"
            self.windSpeed = String(format: "%.1f m/s", weather.currentWeather.wind.speed.value)

            // 天気アイコン
            self.weatherIcon = getWeatherIcon(for: weather.currentWeather.condition)

        } catch {
            print("❌ Error fetching weather:", error.localizedDescription)
            self.currentTemperature = "Error"
            self.weatherDescription = "Failed to load weather"
            self.weatherIcon = "❓"
            self.humidity = "_"
            self.windSpeed = "_"
        }
    }

    // ✅ 正しい位置
    private func getWeatherIcon(for condition: WeatherCondition) -> String {
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
        case .foggy: // iOS バージョンで対応
            return "🌫️"
        default:
            return "⏳"
        }
    }
}
        


