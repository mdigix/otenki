//
//  WeatherView.swift
//  Sample_Weatherapp
//
//  Created by mdigix on 2025/04/20.
//

import SwiftUI
import MapKit
import WeatherKit
import CoreLocation

// MARK: - ピン表示用モデル
struct MapPin: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

// MARK: - ViewModel
class WeatherViewModel: ObservableObject {
    private let weatherService = WeatherService()

    @Published var currentTemperature: String = "Loading..."
    @Published var weatherDescription: String = "Loading..."
    @Published var weatherIcon: String = "⏳"
    @Published var humidity: String = "_"
    @Published var windSpeed: String = "_"

    @MainActor
    func fetchWeather() async {
        let location = CLLocation(latitude: 35.6895, longitude: 139.6917)

        do {
            let weather = try await weatherService.weather(for: location)

            //self.currentTemperature = "\(weather.currentWeather.temperature.value)° \(weather.currentWeather.temperature.unit.symbol)"
            let temp = Int(weather.currentWeather.temperature.value)
            self.currentTemperature = "\(temp)°C"
            self.weatherDescription = weather.currentWeather.condition.description
            self.humidity = "\(Int(weather.currentWeather.humidity * 100))%"
            self.windSpeed = "\(Int(weather.currentWeather.wind.speed.value))m/s"
            
            //アイコン判定
            switch weather.currentWeather.condition {
            case .clear:
                self.weatherIcon = "☀️"
            case .cloudy, .mostlyCloudy, .partlyCloudy:
                self.weatherIcon = "☁️"
            case .rain:
                self.weatherIcon = "🌧️"
            case .thunderstorms:
                self .weatherIcon = "⚡️"
            case .snow:
                self.weatherIcon = "❄️"
            default:
                self.weatherIcon = "⏳"
            }

        } catch {
            print("❌ Error fetching weather:", error.localizedDescription)
            self.currentTemperature = "Error"
            self.weatherDescription = "Failed to load weather"
            self.weatherIcon = "❌"
            self.humidity = "_"
            self.windSpeed = "_"
        }
    }
}

// MARK: - View
struct WeatherView: View {
    @StateObject private var viewModel = WeatherViewModel()
    
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 35.6895, longitude: 139.6917),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
    )
    
    @State private var pins: [MapPin] = [
        MapPin(coordinate: CLLocationCoordinate2D(latitude: 35.6812, longitude: 139.7671)) // 東京駅
    ]
    
    var body: some View {
        ZStack {
            //地図を全面に表示
            Map(position: $cameraPosition) {
                ForEach(pins) { pin in
                    Annotation("", coordinate: pin.coordinate) {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(.red)
                            .imageScale(.large)
                    }
                }
            }
            .mapControls {
                MapUserLocationButton()
            }
            .ignoresSafeArea() //Safe Areaを無視
            
            //天気情報をオーバーレイで表示
            VStack(spacing: 16) {
                Spacer() //上からスペースを確保
                
                Text(viewModel.weatherIcon) //天気に応じたアイコン
                    .font(.system(size: 50))
                    .padding(.top)
                
                Text(viewModel.currentTemperature)
                    .font(.system(size: 32, weight: .medium))
                    .bold()
                
                Text(viewModel.weatherDescription)
                    .font(.title2)
                    .foregroundColor(.yellow)
                
                HStack(spacing: 20) {
                    HStack {
                        Image(systemName: "drop.fill")
                            .foregroundColor(.blue)
                        Text("\(viewModel.windSpeed)m/s")
                        
                    }
                }
                .font(.subheadline)
                
                Spacer().frame(height: 50) //下部スペース
            }
            .foregroundColor(.white)
            .shadow(radius: 10)
            .padding()
        }
        .task {
            await viewModel.fetchWeather()
        }
    }
    
    
    
    
    // MARK: - Preview
    struct WeatherView_Previews: PreviewProvider {
        static var previews: some View {
            WeatherView()
        }
    }
}
