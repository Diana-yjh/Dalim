//
//  HealthService.swift
//  Dalim
//
//  Created by Yejin Hong on 4/24/26.
//

import HealthKit

enum HealthError: Error {
    case notAvailable
    case authorizationDenied
}

final class HealthService: HealthServiceProtocol {
    private let store = HKHealthStore()
    
    private let stepType = HKQuantityType(.stepCount)
    private let energyType = HKQuantityType(.activeEnergyBurned)
    private let heartRateType = HKQuantityType(.heartRate)
    
    private var typesToRead: Set<HKSampleType> {
        [stepType, energyType, heartRateType]
    }
    
    // MARK: - Authorization
    
    func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthError.notAvailable
        }
        try await store.requestAuthorization(toShare: [], read: typesToRead)
    }
    
    // MARK: - Fetch
    func fetchTodaySteps() async throws -> Int {
        let sum = try await fetchTodayCumulativeSum(for: stepType, unit: .count())
        return Int(sum)
    }
    
    func fetchTodayActiveEnergy() async throws -> Int {
        let sum = try await fetchTodayCumulativeSum(for: energyType, unit: .kilocalorie())
        return Int(sum)
    }
    
    func fetchLatestHeartRate() async throws -> Int? {
        try await withCheckedThrowingContinuation { continuation in
            let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            let query = HKSampleQuery(
                sampleType: heartRateType,
                predicate: nil,
                limit: 1,
                sortDescriptors: [sort]
            ) { _, samples, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let sample = samples?.first as? HKQuantitySample else {
                    continuation.resume(returning: nil)
                    return
                }
                let bpm = sample.quantity.doubleValue(
                    for: HKUnit.count().unitDivided(by: .minute())
                )
                continuation.resume(returning: Int(bpm))
            }
            store.execute(query)
        }
    }
    
    // MARK: - Private Helper
    
    private func fetchTodayCumulativeSum(
        for type: HKQuantityType,
        unit: HKUnit
    ) async throws -> Double {
        try await withCheckedThrowingContinuation { continuation in
            let now = Date()
            let startOfDay = Calendar.current.startOfDay(for: now)
            let predicate = HKQuery.predicateForSamples(
                withStart: startOfDay,
                end: now,
                options: .strictStartDate
            )
            
            let query = HKStatisticsQuery(
                quantityType: type,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, statistics, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                let value = statistics?.sumQuantity()?.doubleValue(for: unit) ?? 0
                continuation.resume(returning: value)
            }
            store.execute(query)
        }
    }
}
