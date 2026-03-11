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

enum LocationError: Error {
    case permissionDenied
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "위치 권한이 필요합니다. 설정에서 허용해주세요."
        }
    }
}

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
    private var authContinuation: CheckedContinuation<Void, Error>?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
    }
    
    // MARK: - Public
    
    func fetchWeather() async throws -> WeatherInfo {
        let location = try await requestLocationAuthorization()
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
    }
    
    // MARK: - Private
    
    private func requestLocationAuthorization() async throws -> CLLocation {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            try await requestAuthorizationIfNeeded()
        case .denied, .restricted:
            throw LocationError.permissionDenied
        default:
            break
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            self.locationContinuation = continuation
            locationManager.requestLocation()
        }
    }
    
    private func requestAuthorizationIfNeeded() async throws {
        try await withCheckedThrowingContinuation { continuation in
            self.authContinuation = continuation
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard let continuation = authContinuation else { return }
        authContinuation = nil
        
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            continuation.resume(returning: ())
        default:
            continuation.resume(throwing: LocationError.permissionDenied)
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
