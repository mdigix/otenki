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
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var animateIcon = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            // 🗺️ 地図
            Map(position: $cameraPosition) {
                if let location = viewModel.location {
                    Annotation(viewModel.currentLocationName, coordinate: location.coordinate) {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(.red)
                            .imageScale(.large)
                    }
                }
            }
            .ignoresSafeArea()
            .onChange(of: viewModel.location) {
                if let location = viewModel.location {
                    updateCamera(to: location)
                }
            }
            // ✅ CLLocation は Equatable ではないので custom onChange
            .task {
                if let location = viewModel.location {
                    updateCamera(to: location)
                }
            }

            // 🌤️ 天気情報オーバーレイ
            VStack {
                Spacer()
                VStack(spacing: 8) {
                    Text(viewModel.currentLocationName)
                        .font(.headline)
                        .padding(.bottom, 4)
                    
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
            animateIcon = true
        }
    }

    // 📍 カメラ更新用関数
    func updateCamera(to location: CLLocation) {
        withAnimation {
            cameraPosition = .region(
                MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                )
            )
        }
        zoomInMap()
    }

    // 🔍 ズームイン関数
    func zoomInMap() {
        if let region = cameraPosition.region {
            var newRegion = region
            newRegion.span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            withAnimation(.easeInOut(duration: 2.0)) {
                cameraPosition = .region(newRegion)
            }
        }
    }

    // 🎨 背景色切替
    var backgroundColor: Color {
        switch viewModel.weatherCondition {
        case .some(.sunny):
            return colorScheme == .dark ? Color.blue.opacity(0.3) : Color.blue.opacity(0.1)
        case .some(.cloudy):
            return colorScheme == .dark ? Color.gray.opacity(0.5) : Color.gray.opacity(0.2)
        case .some(.rainy):
            return colorScheme == .dark ? Color.black.opacity(0.7) : Color.black.opacity(0.4)
        default:
            return colorScheme == .dark ? Color.black : Color.white
        }
    }
}

// 🔍 プレビュー
struct WeatherView_Previews: PreviewProvider {
    static var previews: some View {
        WeatherView()
    }
}
