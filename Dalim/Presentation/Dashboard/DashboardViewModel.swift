//
//  DashboardViewModel.swift
//  Dalim
//
//  Created by Yejin Hong on 2/24/26.
//

import Foundation
import SwiftData
import SwiftUI
import Observation
import HealthKit

@Observable
final class DashboardViewModel {
    // MARK: - 프로필
    var userName: String = "러너"
    var profileImageData: Data?
    var isLinked: Bool = false

    // MARK: - 건강 데이터
    var todaySteps: String = "--"
    var todayKcal: String = "--"
    var currentBPM: String = "--"

    // MARK: - 주간 데이터
    var weeklyDistance: Double = 0.0
    var weeklyGoalKm: Double = 40.0
    var todayIndex: Int = 0
    var recordExistsFlags: [Bool] = Array(repeating: false, count: 7)
    var dailyDistances: [Double] = Array(repeating: 0, count: 7)

    // MARK: - 통계
    var averagePaceString: String = "--:--"
    var paceChangeText: String = ""
    var paceChangeColor: String = "lime"
    var totalRuns: Int = 0
    var consecutiveDays: Int = 0

    // MARK: - 날씨
    var weatherSummary: String = "날씨 정보 로딩 중..."
    var temperature: String = ""
    var humidity: String = ""
    var feelsLike: String = ""
    var wind: String = ""
    var airQuality: String = ""
    var suitability: Suitability = .none
    var isLocationDenied: Bool = false
    
    private let weatherService = WeatherService()
    private let healthStore = HKHealthStore()

    // MARK: - 데이터 로딩

    func loadData(modelContext: ModelContext) async {
        loadProfile(modelContext: modelContext)
        loadRunData(modelContext: modelContext)
        await loadHealthData()
        await loadWeather()
    }

    // MARK: - 프로필 로드

    private func loadProfile(modelContext: ModelContext) {
        let descriptor = FetchDescriptor<UserProfile>()
        if let profile = (try? modelContext.fetch(descriptor))?.first {
            // SwiftData에 프로필이 있지만 연동 정보가 없는 경우, UserDefaults 캐시에서 복원
            if !profile.isLinked, let cached = AuthService.cachedAuthResult() {
                profile.name = cached.name
                profile.isLinked = true
                profile.authProvider = cached.provider
                profile.authUserID = cached.userID
                try? modelContext.save()
            }
            userName = profile.name
            profileImageData = profile.profileImageData
            isLinked = profile.isLinked
        } else if let cached = AuthService.cachedAuthResult() {
            // SwiftData에 프로필이 없지만 UserDefaults에 캐시가 있는 경우 새 프로필 생성
            let profile = UserProfile(name: cached.name)
            profile.isLinked = true
            profile.authProvider = cached.provider
            profile.authUserID = cached.userID
            modelContext.insert(profile)
            try? modelContext.save()

            userName = cached.name
            isLinked = true
        }
    }

    // MARK: - HealthKit 데이터

    private func loadHealthData() async {
        guard HKHealthStore.isHealthDataAvailable() else { return }

        let stepType = HKQuantityType(.stepCount)
        let energyType = HKQuantityType(.activeEnergyBurned)
        let heartRateType = HKQuantityType(.heartRate)

        let typesToRead: Set<HKSampleType> = [stepType, energyType, heartRateType]

        do {
            try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
        } catch {
            print("HealthKit auth failed: \(error)")
            return
        }

        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)

        // 걸음수
        if let steps = try? await fetchSum(type: stepType, predicate: predicate, unit: .count()) {
            todaySteps = formatNumber(Int(steps))
        }

        // 칼로리
        if let kcal = try? await fetchSum(type: energyType, predicate: predicate, unit: .kilocalorie()) {
            todayKcal = formatNumber(Int(kcal))
        }

        // 심박수 (최근)
        if let bpm = try? await fetchLatestHeartRate() {
            currentBPM = "\(Int(bpm))"
        }
    }
    
    private func fetchSum(type: HKQuantityType, predicate: NSPredicate, unit: HKUnit) async throws -> Double {
        try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: result?.sumQuantity()?.doubleValue(for: unit) ?? 0)
                }
            }
            healthStore.execute(query)
        }
    }
    
    private func fetchLatestHeartRate() async throws -> Double {
        let heartRateType = HKQuantityType(.heartRate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: heartRateType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { _, samples, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let sample = samples?.first as? HKQuantitySample {
                    let bpm = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                    continuation.resume(returning: bpm)
                } else {
                    continuation.resume(throwing: NSError(domain: "HealthKit", code: -1))
                }
            }
            self.healthStore.execute(query)
        }
    }

    private func formatNumber(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    // MARK: - RunRecord 기반 계산

    private func loadRunData(modelContext: ModelContext) {
        let descriptor = FetchDescriptor<RunRecord>(
            sortBy: [SortDescriptor(\.startDate, order: .reverse)]
        )
        let records = (try? modelContext.fetch(descriptor)) ?? []

        // UserSettings
        let settingsDescriptor = FetchDescriptor<UserSettings>()
        let settings = (try? modelContext.fetch(settingsDescriptor))?.first
        weeklyGoalKm = settings?.weeklyGoalKm ?? 40.0

        let calendar = Calendar.current

        // 이번 주 월~일 범위 계산
        var cal = Calendar(identifier: .gregorian)
        cal.firstWeekday = 2 // 월요일 시작
        let today = Date()
        guard let weekInterval = cal.dateInterval(of: .weekOfYear, for: today) else { return }

        // 오늘 요일 인덱스 (월=0 ~ 일=6)
        let weekday = cal.component(.weekday, from: today)
        todayIndex = (weekday + 5) % 7

        // 이번 주 기록 필터
        let thisWeekRecords = records.filter {
            $0.startDate >= weekInterval.start && $0.startDate < weekInterval.end
        }

        // 주간 거리
        weeklyDistance = thisWeekRecords.reduce(0) { $0 + $1.distanceInKm }

        // 요일별 기록 존재 여부 + 요일별 거리
        var flags = Array(repeating: false, count: 7)
        var distances = Array(repeating: 0.0, count: 7)
        for record in thisWeekRecords {
            let day = cal.component(.weekday, from: record.startDate)
            let index = (day + 5) % 7
            flags[index] = true
            distances[index] += record.distanceInKm
        }
        recordExistsFlags = flags
        dailyDistances = distances

        // 평균 페이스 (전체)
        if !records.isEmpty {
            let avgPace = records.reduce(0.0) { $0 + $1.averagePace } / Double(records.count)
            let minutes = Int(avgPace) / 60
            let seconds = Int(avgPace) % 60
            averagePaceString = "\(minutes):\(String(format: "%02d", seconds))"

            // 페이스 변화: 이번 주 vs 지난 주
            let lastWeekStart = calendar.date(byAdding: .weekOfYear, value: -1, to: weekInterval.start)!
            let lastWeekRecords = records.filter {
                $0.startDate >= lastWeekStart && $0.startDate < weekInterval.start
            }

            if !thisWeekRecords.isEmpty && !lastWeekRecords.isEmpty {
                let thisWeekAvg = thisWeekRecords.reduce(0.0) { $0 + $1.averagePace } / Double(thisWeekRecords.count)
                let lastWeekAvg = lastWeekRecords.reduce(0.0) { $0 + $1.averagePace } / Double(lastWeekRecords.count)
                let diff = lastWeekAvg - thisWeekAvg // 양수면 빨라짐
                let diffMin = Int(abs(diff)) / 60
                let diffSec = Int(abs(diff)) % 60

                if diff > 0 {
                    paceChangeText = "▲ \(diffMin):\(String(format: "%02d", diffSec)) 상승"
                    paceChangeColor = "lime"
                } else if diff < 0 {
                    paceChangeText = "▼ \(diffMin):\(String(format: "%02d", diffSec)) 하락"
                    paceChangeColor = "orange"
                } else {
                    paceChangeText = "변동 없음"
                    paceChangeColor = "lime"
                }
            } else {
                paceChangeText = "비교 데이터 없음"
                paceChangeColor = "lime"
            }
        }

        // 총 러닝 횟수
        totalRuns = records.count

        // 연속 러닝일 계산
        consecutiveDays = calculateConsecutiveDays(records: records, calendar: calendar)
    }

    private func calculateConsecutiveDays(records: [RunRecord], calendar: Calendar) -> Int {
        guard !records.isEmpty else { return 0 }

        let runDates = Set(records.map { calendar.startOfDay(for: $0.startDate) })
        var streak = 0
        var checkDate = calendar.startOfDay(for: Date())

        while runDates.contains(checkDate) {
            streak += 1
            guard let prev = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
            checkDate = prev
        }

        return streak
    }

    // MARK: - 날씨 로딩

    private func loadWeather() async {
        do {
            let info = try await weatherService.fetchWeather()
            temperature = info.temperature
            humidity = info.humidity
            feelsLike = info.feelsLike
            wind = info.wind
            airQuality = info.airQuality

            suitability = info.suitability
            weatherSummary = info.summary
            isLocationDenied = false
        } catch is LocationError {
            isLocationDenied = true
            weatherSummary = "위치 권한이 필요합니다"
        } catch {
            weatherSummary = "날씨 정보 없음"
        }
    }

    // MARK: - 주간 목표 변경

    func updateWeeklyGoal(km: Double, modelContext: ModelContext) {
        let descriptor = FetchDescriptor<UserSettings>()
        let settings = (try? modelContext.fetch(descriptor))?.first ?? {
            let s = UserSettings()
            modelContext.insert(s)
            return s
        }()
        settings.weeklyGoalKm = km
        try? modelContext.save()
        weeklyGoalKm = km
    }

    // MARK: - 달성률

    var achievementRate: Double {
        guard weeklyGoalKm > 0 else { return 0 }
        return weeklyDistance / weeklyGoalKm
    }

    var alertColor: Color {
        paceChangeColor == "lime" ? DianaTheme.neonLime : DianaTheme.neonOrange
    }
}
