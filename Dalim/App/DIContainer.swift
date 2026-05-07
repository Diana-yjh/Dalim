//
//  DIContainer.swift
//  Dalim
//
//  Created by Yejin Hong on 4/23/26.
//

import HealthKit
import WeatherKit
import SwiftUI
import CoreLocation

@MainActor
final class DIContainer: Observable {
    private let weatherService: WeatherServiceProtocol
    private let healthService: HealthServiceProtocol
    private let locationManager = CLLocationManager()
    
    init(
        weatherService: WeatherServiceProtocol = WeatherService(),
        healthService: HealthServiceProtocol = HealthService()
    ) {
        self.weatherService = weatherService
        self.healthService = healthService
    }
    
    func makeDashboardViewModel() -> DashboardViewModel {
        DashboardViewModel(weatherService: weatherService, healthService: healthService)
    }
    
    func makeRunningSetupViewModel() -> RunningSetupViewModel {
        RunningSetupViewModel()
    }
}
