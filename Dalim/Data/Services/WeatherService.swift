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
    let humidity: String
    let feelsLike: String
    let wind: String
    let airQuality: String
    let suitability: Suitability
    let icon: String

    var summary: String {
        "\(condition) · 체감 \(feelsLike)°C"
    }
    
    static let defaultValue = WeatherInfo(
        temperature: "--°C",
        condition: "--",
        humidity: "--",
        feelsLike: "--°C",
        wind: "--",
        airQuality: "--",
        suitability: .none,
        icon: "cloud.fill"
    )
}

// MARK: - WeatherService

final class WeatherService: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private let weatherService = WeatherKit.WeatherService.shared
    private var locationContinuation: CheckedContinuation<CLLocation, Error>?
    private var authContinuation: CheckedContinuation<Void, Error>?
    
    // MARK: - OpenWeather API
    private let urlPrefix = "https://api.openweathermap.org/data/2.5/air_pollution?"
    private let urlLatitude = "lat="
    private let urlLongitude = "&lon="
    private let apiKey: String = {
        guard let key = Bundle.main.infoDictionary?["OPENWEATHER_API_KEY"] as? String, !key.isEmpty else {
            fatalError("OPENWEATHER_API_KEY가 Info.plist에 설정되지 않았습니다. Secrets.xcconfig를 확인하세요.")
        }
        return key
    }()
    
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

        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude

        // 원시 수치 가져오기
        let (pm10, pm25) = try await fetchAirQualityRaw(lat: lat, lon: lon)

        // 수치 계산
        let temperature = Int(current.temperature.converted(to: .celsius).value.rounded())
        let humidity = Int(current.humidity * 100)
        let feelsLike = Int(current.apparentTemperature.converted(to: .celsius).value.rounded())
        let wind = Int(current.wind.speed.converted(to: .metersPerSecond).value.rounded())

        // 대기질 문자열
        let airQualityText = convertAirQuality(pm10: pm10, pm25: pm25)

        // 러닝 적합도 (pm2.5 기준으로 aqi 점수 계산)
        let suitability = calculateSuitability(
            temperature: temperature,
            humidity: humidity,
            windSpeed: wind,
            aqi: Int(pm25)
        )

        return WeatherInfo(
            temperature: "\(temperature)",
            condition: current.condition.koreanDescription,
            humidity: "\(humidity)",
            feelsLike: "\(feelsLike)",
            wind: "\(wind)",
            airQuality: airQualityText,
            suitability: suitability,
            icon: current.symbolName
        )
    }
    
    // 원시 수치 반환 (pm10, pm25)
    func fetchAirQualityRaw(lat: Double, lon: Double) async throws -> (pm10: Double, pm25: Double) {
        let urlString = "\(urlPrefix)\(urlLatitude)\(lat)\(urlLongitude)\(lon)&appid=\(apiKey)"
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }

        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(AirPollutionResponse.self, from: data)

        let components = response.list.first?.components
        return (pm10: components?.pm10 ?? 0, pm25: components?.pm2_5 ?? 0)
    }
    
    // MARK: - 러닝 적합도 계산
    func calculateSuitability(
        temperature: Int,  // 섭씨
        humidity: Int,     // %
        windSpeed: Int,    // m/s
        aqi: Int
    ) -> Suitability {
        let score = temperatureScore(temperature) + humidityScore(humidity) + windScore(windSpeed) + aqiScore(aqi)
        
        switch score {
        case 85...100: return .perfect
        case 65..<85:  return .good
        case 45..<65:  return .fair
        case 25..<45:  return .bad
        default:       return .worst
        }
    }
    
    // 온도 (40점)
    private func temperatureScore(_ temp: Int) -> Int {
        switch temp {
        case 10...18: return 40  // 최적
        case 8..<10, 18..<22: return 30
        case 5..<8, 22..<26:  return 20
        case 0..<5, 26..<30:  return 10
        default: return 0        // 0도 이하 or 30도 이상
        }
    }

    // 습도 (20점)
    private func humidityScore(_ humidity: Int) -> Int {
        switch humidity {
        case 30...60: return 20  // 최적
        case 20..<30, 60..<70: return 15
        case 10..<20, 70..<80: return 10
        case 80...: return 5
        default: return 0
        }
    }

    // 바람 (20점)
    private func windScore(_ windSpeed: Int) -> Int {
        switch windSpeed {
        case 0...3: return 20    // 잔잔
        case 3..<5: return 15
        case 5..<8: return 10
        case 8..<12: return 5
        default: return 0        // 12m/s 이상 강풍
        }
    }

    // 미세먼지 PM2.5 (20점)
    private func aqiScore(_ aqi: Int) -> Int {
        switch aqi {
        case 0...15:  return 20  // 좋음
        case 15...35: return 15  // 보통
        case 35...75: return 5   // 나쁨
        default: return 0        // 매우 나쁨
        }
    }
    
    
    func fetchAirQuality(lat: Double, lon: Double) async throws -> String {
        let urlString = "https://api.openweathermap.org/data/2.5/air_pollution?lat=\(lat)&lon=\(lon)&appid=\(apiKey)"
        print(urlString)
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }

        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(AirPollutionResponse.self, from: data)

        let components = response.list.first?.components
        let pm2_5 = components?.pm2_5 ?? 0 // 초미세먼지
        let pm10 = components?.pm10 ?? 0
        
        return convertAirQuality(pm10: pm10, pm25: pm2_5)
    }

    private func convertAirQuality(pm10: Double, pm25: Double) -> String {
        // 각각 등급 계산
        let pm10Grade = pm10Grade(pm10)
        let pm25Grade = pm25Grade(pm25)
        
        // 둘 중 더 나쁜 쪽을 채택
        let worst = max(pm10Grade, pm25Grade)
        
        switch worst {
        case 1: return "좋음"
        case 2: return "보통"
        case 3: return "나쁨"
        default: return "매우나쁨"
        }
    }

    // 미세먼지 PM10 (한국 기준)
    private func pm10Grade(_ pm10: Double) -> Int {
        switch pm10 {
        case 0..<30:  return 1 // 좋음
        case 30..<80: return 2 // 보통
        case 80..<150: return 3 // 나쁨
        default:      return 4 // 매우나쁨
        }
    }

    // 초미세먼지 PM2.5 (한국 기준)
    private func pm25Grade(_ pm25: Double) -> Int {
        switch pm25 {
        case 0..<15:  return 1 // 좋음
        case 15..<35: return 2 // 보통
        case 35..<75: return 3 // 나쁨
        default:      return 4 // 매우나쁨
        }
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
    
//    private func runningSuitability(for weather: CurrentWeather) -> String {
//        let temp = weather.apparentTemperature.value
//        switch temp {
//        case 5...25:
//            return "러닝 적합 🟢"
//        case 0..<5, 25..<30:
//            return "러닝 보통 🟡"
//        default:
//            return "러닝 주의 🔴"
//        }
//    }

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

extension WeatherCondition {
    var koreanDescription: String {
        switch self {
        case .clear:            return "맑음"
        case .mostlyClear:      return "대체로 맑음"
        case .partlyCloudy:     return "구름 조금"
        case .mostlyCloudy:     return "대체로 흐림"
        case .cloudy:           return "흐림"
        case .rain:             return "비"
        case .heavyRain:        return "폭우"
        case .drizzle:          return "이슬비"
        case .snow:             return "눈"
        case .heavySnow:        return "폭설"
        case .foggy:            return "안개"
        case .thunderstorms:    return "뇌우"
        case .haze:             return "연무"
        case .windy:            return "바람"
        case .breezy:           return "산들바람"
        case .blowingDust:      return "황사"
        case .smoky:            return "연기"
        case .sleet:            return "진눈깨비"
        default:                return description
        }
    }
}
