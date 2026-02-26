//
//  WeatherService.swift
//  Dalim
//
//  Created by Yejin Hong on 2/26/26.
//

import Foundation
import WeatherKit
import CoreLocation

// MARK: - WeatherInfo

struct WeatherInfo {
    let temperature: String
    let condition: String
    let icon: String
    let runningSuitability: String

    var summary: String {
        "\(condition) · 체감 \(temperature) · \(runningSuitability)"
    }

    static let defaultValue = WeatherInfo(
        temperature: "--°C",
        condition: "날씨 정보 없음",
        icon: "cloud.fill",
        runningSuitability: "정보 없음"
    )
}

// MARK: - WeatherService

final class WeatherService: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private let weatherService = WeatherKit.WeatherService.shared
    private var locationContinuation: CheckedContinuation<CLLocation, Error>?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    // MARK: - Public

    func fetchWeather() async -> WeatherInfo {
        do {
            let location = try await requestLocation()
            let weather = try await weatherService.weather(for: location)
            let current = weather.currentWeather

            let feelsLike = Int(current.apparentTemperature.value)
            let conditionText = current.condition.description
            let icon = current.symbolName
            let suitability = runningSuitability(for: current)

            return WeatherInfo(
                temperature: "\(feelsLike)°C",
                condition: conditionText,
                icon: icon,
                runningSuitability: suitability
            )
        } catch {
            return .defaultValue
        }
    }

    // MARK: - Private

    private func requestLocation() async throws -> CLLocation {
        locationManager.requestWhenInUseAuthorization()

        return try await withCheckedThrowingContinuation { continuation in
            self.locationContinuation = continuation
            locationManager.requestLocation()
        }
    }

    private func runningSuitability(for weather: CurrentWeather) -> String {
        let temp = weather.apparentTemperature.value
        switch temp {
        case 5...25:
            return "러닝 적합 🟢"
        case 0..<5, 25..<30:
            return "러닝 보통 🟡"
        default:
            return "러닝 주의 🔴"
        }
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        locationContinuation?.resume(returning: location)
        locationContinuation = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationContinuation?.resume(throwing: error)
        locationContinuation = nil
    }
}
