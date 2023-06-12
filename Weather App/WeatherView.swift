//
//  ContentView.swift
//  Weather App
//
//  Created by Igor Kononov on 12.06.2023.
//

import SwiftUI

struct WeatherView: View {
    @StateObject var viewModel = WeatherViewModel()
    var body: some View {
        ZStack {
            ZStack(alignment: .leading) {
                VStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(viewModel.responseBody.name)
                            .bold()
                            .font(.title)
                        
                        Text("Today, \(Date().formatted(.dateTime.month().day().hour().minute()))")
                            .fontWeight(.light)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 50)
                    
                    Spacer()
                    
                    VStack {
                        HStack {
                            VStack(spacing: 20) {
                                Image(systemName: "cloud")
                                    .font(.system(size: 40))
                                
                                Text("\(viewModel.responseBody.weather[0].main)")
                            }
                            .frame(width: 150, alignment: .leading)
                            
                            Spacer()
                            
                            Text(viewModel.responseBody.main.feelsLike.roundDouble() + "°")
                                .font(.system(size: 100))
                                .fontWeight(.bold)
                                .padding()
                        }
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack {
                    Spacer()
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Weather now")
                            .bold()
                            .padding(.bottom)
                        
                        HStack {
                            WeatherRow(logo: "thermometer", name: "Min temp", value: (viewModel.responseBody.main.tempMin.roundDouble() + ("°")))
                            Spacer()
                            WeatherRow(logo: "thermometer", name: "Max temp", value: (viewModel.responseBody.main.tempMax.roundDouble() + "°"))
                        }
                        
                        HStack {
                            WeatherRow(logo: "wind", name: "Wind speed", value: (viewModel.responseBody.wind.speed.roundDouble() + " m/s"))
                            Spacer()
                            WeatherRow(logo: "humidity", name: "Humidity", value: "\(viewModel.responseBody.main.humidity.roundDouble())%")
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .padding(.bottom, 20)
                    .foregroundColor(Color(hue: 0.656, saturation: 0.787, brightness: 0.354))
                    .background(.white)
                    .cornerRadius(20, corners: [.topLeft, .topRight])
                }
            }
            .edgesIgnoringSafeArea(.bottom)
            .background(Color(hue: 0.656, saturation: 0.787, brightness: 0.354))
            .preferredColorScheme(.dark)
            
            if viewModel.showSearchBar {
                VStack {
                    TextField("Enter city name", text: $viewModel.searchText)
                        .onChange(of: viewModel.searchText, perform: { _ in
                            viewModel.searchPlaces()
                        })
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    ScrollView {
                        ForEach(viewModel.matchingItems, id: \.self) { item in
                            ZStack {
                                Text(item.placemark.title ?? "")
                                    .frame(width: UIScreen.main.bounds.size.width - 40, height: 45)
                                    .background {
                                        Rectangle()
                                            .foregroundColor(.purple)
                                            .frame(width: UIScreen.main.bounds.size.width - 20, height: 50)
                                            .cornerRadius(30)
                                            .padding(.horizontal)
                                    }
                            }
                            .onTapGesture {
                                Task {
                                    await viewModel.selectedLocation(item)
                                }
                            }
                        }
                    }
                }
            } else {
                VStack {
                    HStack {
                        Spacer()
                        Button {
                            viewModel.openSearchBar()
                        } label: {
                            VStack {
                                Image(systemName: "mappin.and.ellipse")
                                Text("Search City")
                            }
                            .foregroundColor(.white)
                        }
                    }
                    Spacer()
                }
                .padding(20)
            }
        }
    }
}


struct WeatherView_Previews: PreviewProvider {
    static var previews: some View {
        WeatherView()
    }
}
