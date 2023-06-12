//
//  WeatherViewModel.swift
//  Weather App
//
//  Created by Igor Kononov on 12.06.2023.
//

import SwiftUI
import MapKit

@MainActor
class WeatherViewModel: ObservableObject {
    
    @Published var showSearchBar = true
    @Published var searchText = ""
    @Published var matchingItems: [MKMapItem] = []
    @Published var responseBody: ResponseBody = ResponseBody(coord: ResponseBody.CoordinatesResponse(lon: 0.0, lat: 0.0), weather: [ResponseBody.WeatherResponse(id: 0.0, main: "", description: "", icon: "")], main: ResponseBody.MainResponse(temp: 0.0, feels_like: 0.0, temp_min: 0.0, temp_max: 0.0, pressure: 0.0, humidity: 0.0), name: "", wind: ResponseBody.WindResponse(speed: 0.0, deg: 0.0))
        
    func openSearchBar() {
        searchText = ""
        showSearchBar = true
        matchingItems = []
    }
    
    func selectedLocation(_ item: MKMapItem) async {
        showSearchBar = false
        guard let placemarkTitle = item.placemark.title else { return }
        let coordinate = item.placemark.coordinate
        searchText = placemarkTitle
        do {
            responseBody = try! await getCurrentWeather(latitude: coordinate.latitude, longitude: coordinate.longitude)!
        }
    }
    
    func searchPlaces() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let response = response else {
                return
            }
            
            self.matchingItems = response.mapItems
        }
    }
    
    private func getCurrentWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) async throws -> ResponseBody? {
        // Replace YOUR_API_KEY in the link below with your own
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=48532a5e16bd27acbb55cf0c9b778afc&units=metric") else { fatalError("Missing URL") }

        let urlRequest = URLRequest(url: url)
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        print("response \(response)")
                
        let decodedData = try JSONDecoder().decode(ResponseBody.self, from: data)
        
        return decodedData
    }
}
