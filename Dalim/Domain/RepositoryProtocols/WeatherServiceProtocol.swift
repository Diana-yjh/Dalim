//
//  WeatherServiceProtocol.swift
//  Dalim
//
//  Created by Yejin Hong on 4/24/26.
//

import CoreLocation

protocol WeatherServiceProtocol {
    func fetchWeather() async throws -> WeatherInfo
    func fetchAirQualityRaw(lat: Double, lon: Double) async throws -> (pm10: Double, pm25: Double)
    func calculateSuitability(temperature: Int, humidity: Int, windSpeed: Int, aqi: Int) -> Suitability
    func temperatureScore(_ temp: Int) -> Int
    func humidityScore(_ humidity: Int) -> Int
    func windScore(_ windSpeed: Int) -> Int
    func aqiScore(_ aqi: Int) -> Int
    func fetchAirQuality(lat: Double, lon: Double) async throws -> String
    func convertAirQuality(pm10: Double, pm25: Double) -> String
    func pm10Grade(_ pm10: Double) -> Int
    func pm25Grade(_ pm25: Double) -> Int
    func requestLocationAuthorization() async throws -> CLLocation
    func requestAuthorizationIfNeeded() async throws
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager)
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
}
