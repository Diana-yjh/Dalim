//
//  ActiveRunViewModel.swift
//  Dalim
//
//  Created by Yejin Hong on 2/26/26.
//

import Foundation
import CoreLocation
import HealthKit
import MapKit

@Observable
final class ActiveRunViewModel: NSObject, CLLocationManagerDelegate {
    // MARK: - 러닝 상태
    var runningStatus: RunningStatus = .running
    var elapsedTime: TimeInterval = 0
    var distance: Double = 0
    var currentPace: Double = 0
    var heartRate: Double = 0
    var routeCoordinates: [CLLocationCoordinate2D] = []
    var currentLocation: CLLocationCoordinate2D?

    // MARK: - Private
    private let locationManager = CLLocationManager()
    private let healthStore = HKHealthStore()
    private var timer: Timer?
    private var lastLocation: CLLocation?
    private var heartRateQuery: HKAnchoredObjectQuery?
    private var startDate = Date()

    // MARK: - Computed
    var elapsedTimeString: String {
        let total = Int(elapsedTime)
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var distanceString: String {
        String(format: "%.2f", distance / 1000.0)
    }

    var paceString: String {
        guard currentPace > 0 else { return "--'--\"" }
        let minutes = Int(currentPace) / 60
        let seconds = Int(currentPace) % 60
        return "\(minutes)'\(String(format: "%02d", seconds))\""
    }

    var heartRateString: String {
        guard heartRate > 0 else { return "--" }
        return "\(Int(heartRate))"
    }

    // MARK: - Init
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 5
        locationManager.activityType = .fitness
        locationManager.allowsBackgroundLocationUpdates = false
    }

    // MARK: - 러닝 제어
    func startRun() {
        startDate = Date()
        runningStatus = .running
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        startTimer()
        startHeartRateQuery()
    }

    func pauseRun() {
        runningStatus = .paused
        timer?.invalidate()
        timer = nil
        locationManager.stopUpdatingLocation()
    }

    func resumeRun() {
        runningStatus = .running
        locationManager.startUpdatingLocation()
        startTimer()
    }

    func stopRun() {
        timer?.invalidate()
        timer = nil
        locationManager.stopUpdatingLocation()
        stopHeartRateQuery()
    }

    // MARK: - Timer
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.elapsedTime += 1
        }
    }

    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }

        let coordinate = newLocation.coordinate
        currentLocation = coordinate
        routeCoordinates.append(coordinate)

        if let last = lastLocation {
            let delta = newLocation.distance(from: last)
            distance += delta

            if delta > 0 {
                currentPace = elapsedTime / (distance / 1000.0)
            }
        }

        lastLocation = newLocation
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // 위치 오류 무시 — 다음 업데이트 대기
    }

    // MARK: - HealthKit 심박수
    private func startHeartRateQuery() {
        guard HKHealthStore.isHealthDataAvailable() else { return }

        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let readTypes: Set<HKObjectType> = [heartRateType]

        healthStore.requestAuthorization(toShare: nil, read: readTypes) { [weak self] success, _ in
            guard success, let self else { return }

            let predicate = HKQuery.predicateForSamples(
                withStart: self.startDate,
                end: nil,
                options: .strictStartDate
            )

            let query = HKAnchoredObjectQuery(
                type: heartRateType,
                predicate: predicate,
                anchor: nil,
                limit: HKObjectQueryNoLimit
            ) { [weak self] _, samples, _, _, _ in
                self?.processHeartRateSamples(samples)
            }

            query.updateHandler = { [weak self] _, samples, _, _, _ in
                self?.processHeartRateSamples(samples)
            }

            self.heartRateQuery = query
            self.healthStore.execute(query)
        }
    }

    private func processHeartRateSamples(_ samples: [HKSample]?) {
        guard let samples = samples as? [HKQuantitySample],
              let latest = samples.last else { return }

        let unit = HKUnit.count().unitDivided(by: .minute())
        let value = latest.quantity.doubleValue(for: unit)

        DispatchQueue.main.async { [weak self] in
            self?.heartRate = value
        }
    }

    private func stopHeartRateQuery() {
        if let query = heartRateQuery {
            healthStore.stop(query)
            heartRateQuery = nil
        }
    }
}
