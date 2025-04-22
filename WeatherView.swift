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
    
    @State private var cameraPosition: MKMapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 35.6895, longitude: 139,6917),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
    )
    
    @State private var pins: [MapPin] = [
        MapPin(coordinate: CLLocationCoordinate2D(latitude: 35.6895, longitude: 139.6917))
    ]
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: 0) {
                //地図全面
                Map(position: $cameraPosition) {
                    ForEach(pins) { pin in
                        Annotation("", coordinate: pin.cooridinate) {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(.red)
                                .imageScale(.large)
                        }
                    }
                }
                .mapcontrols {
                    MapUserLocationButton()
                }
                .ignoreSafeArea() //全面表示
            }
            
            // 天気情報オーバーレイ
            
    }
    
}

// MARK: - ピン表示用モデル
struct MapPin: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}


    
    // MARK: - Preview
    struct WeatherView_Previews: PreviewProvider {
        static var previews: some View {
            WeatherView()
        }
    }
}
