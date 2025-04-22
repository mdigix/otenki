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
    @Published var humidity: String = "-"
    @Published var windSpeed: String = "-"
    @Published var isLoading: Bool = true
    @Published var weatherIcon: String = "⏳"

    @MainActor
    func fetchWeather() async {
        let location = CLLocation(latitude: 35.6895, longitude: 139.6917)

        do {
            let weather = try await weatherService.weather(for: location)

            let temp = Int(weather.currentWeather.temperature.value)
            self.currentTemperature = "\(temp)°C"
            self.weatherDescription = weather.currentWeather.condition.description
            self.humidity = "\(Int(weather.currentWeather.humidity * 100))%"
            self.windSpeed = String(format: "%.1f m/s", weather.currentWeather.wind.speed.value)
            self.weatherIcon = getWeatherIcon(for: weather.currentWeather.condition)
            self.isLoading = false

        } catch {
            print("❌ Error fetching weather:", error.localizedDescription)
            self.currentTemperature = "Error"
            self.weatherDescription = "Failed to load weather"
            self.humidity = "-"
            self.windSpeed = "-"
            self.weatherIcon = "❌"
            self.isLoading = false
        }
    }

    func getWeatherIcon(for condition: WeatherCondition) -> String {
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
            return "🌩️"
        case .snow:
            return "❄️"
        case .foggy:
            return "🌫️"
        default:
            return "❓"
        }
    }
}

// MARK: - View
struct WeatherView: View {
    @StateObject private var viewModel = WeatherViewModel()
    @State private var isMenuOpen = false
    
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
        NavigationView {
            ZStack {
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
                .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    
                    VStack(spacing: 12) {
                        if viewModel.isLoading {
                            ProgressView("Loading...")
                                .progressViewStyle(CircularProgressViewStyle())
                                .padding()
                        } else {
                            Text(viewModel.weatherIcon)
                                .font(.system(size: 60))
                            
                            Text(viewModel.currentTemperature)
                                .font(.system(size: 40, weight: .bold))
                                .padding(.top)
                            
                            Text(viewModel.weatherDescription)
                                .font(.title2)
                                .foregroundColor(.green)
                            
                            HStack {
                                Text("💧 湿度: \(viewModel.humidity)")
                                Spacer()
                                Text("🌬️ 風速: \(viewModel.windSpeed)")
                            }
                            .font(.subheadline)
                            .padding(.horizontal)
                        }
                        
                        Spacer()
                    }
                    .padding()
                }
                .navigationTitle("Weather")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            isMenuOpen.toggle()
                        }) {
                            Image(systemName: "line.horizontal.3")
                                .imageScale(.large)
                        }
                    }
                }
                .sheet(isPresented: $isMenuOpen) {
                    MenuView()
                }
                .task {
                    print("fetchWeather 開始")
                    await viewModel.fetchWeather()
                }
            }
        }
    }
    
    // MARK: - Preview
    struct WeatherView_Previews: PreviewProvider {
        static var previews: some View {
            WeatherView()
        }
    }
}
