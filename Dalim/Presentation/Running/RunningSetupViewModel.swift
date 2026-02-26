//
//  RunningSetupViewModel.swift
//  Dalim
//
//  Created by Yejin Hong on 2/26/26.
//

import Foundation
import CoreLocation

@Observable
final class RunningSetupViewModel: NSObject, CLLocationManagerDelegate {
    // MARK: - 모드 설정
    var selectedMode: RunningMode = .free

    // MARK: - 목표 시간 설정
    var targetHours: Int = 0
    var targetMinutes: Int = 30
    var isAlarmEnabled: Bool = true

    // MARK: - 목표 거리 설정
    var targetDistanceKm: Double = 5.0
    var isVoiceGuideEnabled: Bool = true

    // MARK: - 날씨 정보
    var currentTemperature: String = "--°C"
    var weatherCondition: String = "날씨 정보 로딩 중"
    var weatherIcon: String = "cloud.fill"

    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    // MARK: - 위치/날씨 관련
    func requestWeather() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // TODO: WeatherKit API 연동 후 실제 데이터로 교체
        currentTemperature = "체감 3°C"
        weatherCondition = "맑음 · 러닝 적합"
        weatherIcon = "sun.max.fill"
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        currentTemperature = "체감 --°C"
        weatherCondition = "날씨 정보를 가져올 수 없습니다"
        weatherIcon = "exclamationmark.triangle.fill"
    }
}
