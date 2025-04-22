//
//  WeatherView.swift
//  Sample_Weatherapp
//
//  Created by mdigix on 2025/04/20.
//

//
//  WeatherView.swift
//  otenki
//

import SwiftUI
import MapKit

// MARK: - ピン表示用モデル
struct MapPin: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

// MARK: - View
struct WeatherView: View {
    @StateObject private var viewModel = WeatherViewModel() // 正しく StateObject で保持

    @State private var pins: [MapPin] = [
        MapPin(coordinate: CLLocationCoordinate2D(latitude: 35.6812, longitude: 139.7671)) // 東京駅
    ]

    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 35.6895, longitude: 139.6917),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
    )

    var body: some View {
        VStack(spacing: 16) {
            // 地図
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
            
            // 天気情報オーバーレイ
            VStack(spacing: 8) {
                Text(viewModel.weatherIcon)
                    .font(.system(size: 80))
                    .padding(.top, 50)

                Text(viewModel.currentTemperature)
                    .font(.system(size: 36, weight: .bold))

                Text(viewModel.weatherDescription)
                    .font(.title2)
                    .foregroundColor(.gray)

                HStack {
                    Text("💧 \(viewModel.humidity)")
                    Text("🌬️ \(viewModel.windSpeed)")
                }
                .font(.subheadline)
                .padding(.top, 8)
            }
            .frame(maxWidth: .infinity)
            .background(Color.black.opacity(0.3))
            .cornerRadius(12)
            .padding()
        }
        .task {
            await viewModel.fetchWeather() // ここが Binding エラーにならない形
        }
    }
}

// MARK: - Preview
struct WeatherView_Previews: PreviewProvider {
    static var previews: some View {
        WeatherView()
    }
}

