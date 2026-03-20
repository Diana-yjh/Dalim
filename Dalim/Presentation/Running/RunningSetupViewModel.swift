//
//  RunningSetupViewModel.swift
//  Dalim
//
//  Created by Yejin Hong on 2/26/26.
//

import Foundation
import CoreLocation
import UserNotifications
import UIKit

enum NotificationError: Error {
    case permissionDenied
}

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

    private let weatherService = WeatherService()

    // MARK: - 위치 권한
    var showLocationPermissionAlert: Bool = false
    var showAlarmPermissionAlert: Bool = false
    
    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.delegate = self
    }

    /// 위치 권한 상태 확인 — 거부/제한 시 커스텀 알럿 표시
    func checkLocationPermission() {
        switch locationManager.authorizationStatus {
        case .denied, .restricted:
            showLocationPermissionAlert = true
        default:
            break
        }
    }

    /// 설정 앱으로 이동
    func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            showLocationPermissionAlert = false
            Task { await requestWeather() }
        case .denied, .restricted:
            showLocationPermissionAlert = true
        default:
            break
        }
    }

    // MARK: - 날씨 요청
    func requestWeather() async {
        do {
            let info = try await weatherService.fetchWeather()
            currentTemperature = "체감 \(info.temperature)°C"
            weatherCondition = "\(info.condition)"
            weatherIcon = info.icon
        } catch {
            weatherCondition = "날씨 정보 없음"
        }
    }
    
    // MARK: - 알림 권한 설정
    func requestNoficiationPermission() async {
        var granted: Bool = false
        
        do {
            granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            showAlarmPermissionAlert = true
        }
        
        if !granted {
            showAlarmPermissionAlert = true
        }
    }
    
    func scheduleDaily() {
        let content = UNMutableNotificationContent()
        content.title = "달림"
        content.body = "오늘도 달려볼까요?"
        content.sound = .default
        
        var dateComponent = DateComponents()
        dateComponent.hour = targetHours
        dateComponent.minute = targetMinutes
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyRun", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func cancelNotification(id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
        
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
