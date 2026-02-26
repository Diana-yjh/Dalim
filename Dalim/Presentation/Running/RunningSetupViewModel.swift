//
//  RunningSetupViewModel.swift
//  Dalim
//
//  Created by Yejin Hong on 2/26/26.
//

import Foundation

@Observable
final class RunningSetupViewModel {
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

    private let weatherService = WeatherService()

    // MARK: - 날씨 요청
    func requestWeather() async {
        let info = await weatherService.fetchWeather()
        currentTemperature = "체감 \(info.temperature)"
        weatherCondition = "\(info.condition) · \(info.runningSuitability)"
        weatherIcon = info.icon
    }
}
