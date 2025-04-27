//
//  WeatherView.swift
//  Sample_Weatherapp
//
//  Created by mdigix on 2025/04/20.
//

import SwiftUI
import MapKit

struct WeatherView: View {
    @StateObject private var viewModel = WeatherViewModel()
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 35.6895, longitude: 139.6917),
            span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        )
    )
    @State private var animateIcon = false
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            // 🗺️ 地図を画面いっぱいに
            Map(position: $cameraPosition) {
                Annotation("Tokyo", coordinate: CLLocationCoordinate2D(latitude: 35.6812, longitude: 139.7671)) {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(.red)
                        .imageScale(.large)
                }
            }
            .ignoresSafeArea()
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    zoomInMap()
                }
            }

            // 🌤️ 天気情報をオーバーレイ
            VStack {
                Spacer()
                VStack(spacing: 8) {
                    Text(viewModel.weatherIcon)
                        .font(.system(size: 80))
                        .opacity(animateIcon ? 1 : 0)
                        .scaleEffect(animateIcon ? 1 : 0.8)
                        .animation(.easeInOut(duration: 1), value: animateIcon)

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
                .background(Color(UIColor.systemBackground).opacity(0.9))
                .cornerRadius(12)
                .padding()
            }
        }
        .background(backgroundColor)
        .task {
            await viewModel.fetchWeather()
            animateIcon = true
        }
    }

    var backgroundColor: Color {
        switch viewModel.weatherCondition {
        case .sunny:
            return colorScheme == .dark ? Color.blue.opacity(0.3) : Color.blue.opacity(0.1)
        case .cloudy:
            return colorScheme == .dark ? Color.gray.opacity(0.5) : Color.gray.opacity(0.2)
        case .rainy:
            return colorScheme == .dark ? Color.black.opacity(0.7) : Color.black.opacity(0.4)
        default:
            return colorScheme == .dark ? Color.black : Color.white
        }
    }

    func zoomInMap() {
        if let region = cameraPosition.region {
            var newRegion = region
            newRegion.span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            withAnimation(.easeInOut(duration: 2.0)) {
                cameraPosition = .region(newRegion)
            }
        }
    }
}

struct WeatherView_Previews: PreviewProvider {
    static var previews: some View {
        WeatherView()
    }
}

