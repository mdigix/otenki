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

// 🔹 自作の簡易的な天気分類
enum WeatherCondition {
    case sunny
    case cloudy
    case rainy
}

@MainActor
class WeatherViewModel: ObservableObject {
    private let weatherService = WeatherService()

    @Published var currentTemperature: String = "Loading..."
    @Published var weatherDescription: String = "Loading..."
    @Published var weatherIcon: String = "⏳"
    @Published var humidity: String = "_"
    @Published var windSpeed: String = "_"
    @Published var weatherCondition: WeatherCondition? = .sunny // ← 自作 enum を使う

    func fetchWeather() async {
        let location = CLLocation(latitude: 35.6895, longitude: 139.6917)

        do {
            let weather = try await weatherService.weather(for: location)

            self.currentTemperature = "\(Int(weather.currentWeather.temperature.value))°C"
            self.weatherDescription = weather.currentWeather.condition.description
            self.humidity = "\(Int(weather.currentWeather.humidity * 100))%"
            self.windSpeed = String(format: "%.1f m/s", weather.currentWeather.wind.speed.value)

            // 🔹 正しくマッピングしてからアイコン取得
            let mappedCondition = mapCondition(weather.currentWeather.condition)
            self.weatherCondition = mappedCondition
            self.weatherIcon = getWeatherIcon(for: mappedCondition)

        } catch {
            print("❌ Error fetching weather:", error.localizedDescription)
            self.currentTemperature = "Error"
            self.weatherDescription = "Failed to load weather"
            self.weatherIcon = "❓"
            self.humidity = "_"
            self.windSpeed = "_"
            self.weatherCondition = nil
        }
    }

    // 🔹 天気アイコン取得
    private func getWeatherIcon(for condition: WeatherCondition) -> String {
        switch condition {
        case .sunny:
            return "☀️"
        case .cloudy:
            return "☁️"
        case .rainy:
            return "🌧️"
        }
    }

    // 🔹 WeatherKit → 自作 WeatherCondition に変換
    private func mapCondition(_ condition: WeatherKit.WeatherCondition) -> WeatherCondition {
        switch condition {
        case .clear, .mostlyClear, .partlyCloudy:
            return .sunny
        case .cloudy, .mostlyCloudy, .foggy:
            return .cloudy
        case .rain, .drizzle, .thunderstorms:
            return .rainy
        default:
            return .sunny
        }
    }
}
