//
//  DashboardViewModel.swift
//  Dalim
//
//  Created by Yejin Hong on 2/24/26.
//

import Foundation
import SwiftData
import Observation

@Observable
final class DashboardViewModel {
    // MARK: - 주간 데이터
    var weeklyDistance: Double = 0.0
    var weeklyGoalKm: Double = 40.0
    var todayIndex: Int = 0
    var recordExistsFlags: [Bool] = Array(repeating: false, count: 7)

    // MARK: - 통계
    var averagePaceString: String = "--'--\""
    var paceChangeText: String = ""
    var paceChangeColor: String = "lime"
    var totalRuns: Int = 0
    var consecutiveDays: Int = 0

    // MARK: - 날씨
    var weatherSummary: String = "날씨 정보 로딩 중..."

    private let weatherService = WeatherService()

    // MARK: - 데이터 로딩

    func loadData(modelContext: ModelContext) async {
        loadRunData(modelContext: modelContext)
        await loadWeather()
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

        // 요일별 기록 존재 여부
        var flags = Array(repeating: false, count: 7)
        for record in thisWeekRecords {
            let day = cal.component(.weekday, from: record.startDate)
            let index = (day + 5) % 7
            flags[index] = true
        }
        recordExistsFlags = flags

        // 평균 페이스 (전체)
        if !records.isEmpty {
            let avgPace = records.reduce(0.0) { $0 + $1.averagePace } / Double(records.count)
            let minutes = Int(avgPace) / 60
            let seconds = Int(avgPace) % 60
            averagePaceString = "\(minutes)'\(String(format: "%02d", seconds))\""

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
                    paceChangeText = "▲ \(diffMin)'\(String(format: "%02d", diffSec))\" 상승"
                    paceChangeColor = "lime"
                } else if diff < 0 {
                    paceChangeText = "▼ \(diffMin)'\(String(format: "%02d", diffSec))\" 하락"
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
        let info = await weatherService.fetchWeather()
        weatherSummary = info.summary
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

import SwiftUI
