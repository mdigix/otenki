//
//  WeatherView.swift
//  Sample_Weatherapp
//
//  Created by mdigix on 2025/04/20.
//
import SwiftUI
import MapKit
import CoreLocation

struct WeatherView: View {
    @StateObject private var viewModel = WeatherViewModel()
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var animateIcon = false
    @Environment(\.colorScheme) var colorScheme
    
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
    
    func zoomInMap() {
        if let region = cameraPosition.region {
            var newRegion = region
            newRegion.span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            withAnimation(.easeInOut(duration: 2.0)) {
                cameraPosition = .region(newRegion)
            }
        }
    }
    
    
    
    var body: some View {
        ZStack {
            
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
            
            
            SwipeableWeatherView(viewModel: viewModel)
                .frame(height: UIScreen.main.bounds.height * 0.5)
                .offset(y: UIScreen.main.bounds.height * 0.25)
                .background(Color.primary.opacity(0.7))
                .cornerRadius(20)
                .padding(.horizontal)
                
        }
    }
}
                        
                    
                
                
struct CurrentWeatherView: View {
    @ObservedObject var viewModel: WeatherViewModel
    
    var body: some View {
        VStack {
            Text(viewModel.currentLocationName)
                .font(.title)
            Text(viewModel.currentTemperature)
                .font(.system(size: 60))
            Text(viewModel.weatherDescription)
        }
        .padding(.vertical, 20)
    }
}
                
struct HourlyWeatherView: View {
    @ObservedObject var viewModel: WeatherViewModel
                    
    var body: some View {
        VStack {
            Text("時間別予報")
                 .font(.headline)
            ScrollView(.horizontal, showsIndicators: false) {
               HStack(spacing: 15) {
                   ForEach(viewModel.hourlyForecasts) { forecast in
                       VStack {
                           Text(forecast.time)
                           Image(systemName: forecast.iconName)
                           Text(forecast.temperature)
                                            
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 20)
        }
        .padding()
                        
        }
    }
                
struct DailyForecastView: View {
    @ObservedObject var viewModel: WeatherViewModel
                    
    var body: some View {
        VStack {
            Text("週間予報")
                .font(.headline)
            List {
                ForEach(viewModel.dailyForecasts) { forecast in
                    HStack {
                        Text(forecast.date)
                        Spacer()
                        Image(systemName: forecast.iconName)
                        Text(forecast.temperatureRange)
                    }
                }
            }
        }
        .padding(.bottom, 20)
    }
}
                
struct SwipeableWeatherView: View {
    @ObservedObject var viewModel: WeatherViewModel

                    
    var body: some View {
        TabView {
            CurrentWeatherView(viewModel: viewModel)
                .tag(0)
            HourlyWeatherView(viewModel: viewModel)
                .tag(1)
            DailyForecastView(viewModel: viewModel)
                .tag(2)
        }
        .tabViewStyle(.page)
    }
}
struct WeatherView_Previews: PreviewProvider {
    static var previews: some View {
        WeatherView()
    }
}
