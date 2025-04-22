//
//  WeatherViewModel.swift
//  Sample_Weatherapp
//
//  Created by mdigix on 2025/04/20.
//

/*import Foundation
@preconcurrency import WeatherKit
import CoreLocation

class WeatherViewModel: ObservableObject {
    private let weatherService = WeatherService()
    
    @Published var currentTemperature: String = "Loading ..."
    @Published var weatherDescription: String = "Loading ..."
    
    @MainActor
    func fetchWeather() async {
        let location = CLLocation(latitude: 35.6895, longitude: 139.6917)
        
        do {
            let weather = try await weatherService.weather(for: location)
            
            await MainActor.run {
            self.currentTemperature = "\(weather.currentWeather.temperature.value)° \(weather.currentWeather.temperature.unit.symbol)"
            self.weatherDescription = weather.currentWeather.condition.description
            }
        } catch {
            print("Error fetching weather: \(error)")
            DispatchQueue.main.async {
                Task { @MainActor in
                    self.currentTemperature = "Error"
                    self.weatherDescription = "Faild to load weather"
                }
            }
        }
    }
    
}*/
    


