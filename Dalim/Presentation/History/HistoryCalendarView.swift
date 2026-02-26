//
//  HistoryCalendarView.swift
//  Dalim
//
//  Created by Yejin Hong on 2/26/26.
//

import SwiftUI

struct HistoryCalendarView: View {
    let records: [RunRecord]

    @State private var displayedMonth = Date()
    @State private var selectedDate: Date?

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    private let weekdaySymbols = ["월", "화", "수", "목", "금", "토", "일"]

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                calendarCard
                selectedDateRecords
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
        .navigationDestination(for: RunRecord.self) { record in
            RunDetailView(record: record)
        }
    }

    // MARK: - 캘린더 카드
    private var calendarCard: some View {
        VStack(spacing: 16) {
            monthHeader
            weekdayHeader
            daysGrid
        }
        .dianaCard(DianaTheme.textTertiary)
    }

    // MARK: - 월 이동 헤더
    private var monthHeader: some View {
        HStack {
            Button {
                displayedMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth) ?? displayedMonth
            } label: {
                Image(systemName: "chevron.left")
                    .foregroundStyle(DianaTheme.textSecondary)
            }

            Spacer()

            Text(monthYearString)
                .font(DianaTheme.subtitleFont(18))
                .foregroundStyle(DianaTheme.textPrimary)

            Spacer()

            Button {
                displayedMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth) ?? displayedMonth
            } label: {
                Image(systemName: "chevron.right")
                    .foregroundStyle(DianaTheme.textSecondary)
            }
        }
    }

    // MARK: - 요일 헤더
    private var weekdayHeader: some View {
        HStack(spacing: 4) {
            ForEach(weekdaySymbols, id: \.self) { day in
                Text(day)
                    .font(DianaTheme.captionKorFont(12))
                    .foregroundStyle(DianaTheme.textTertiary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - 날짜 그리드
    private var daysGrid: some View {
        let days = daysInMonth()

        return LazyVGrid(columns: columns, spacing: 8) {
            ForEach(days, id: \.self) { date in
                if let date {
                    let hasRecord = recordsFor(date).isEmpty == false
                    let isToday = calendar.isDateInToday(date)
                    let isSelected = selectedDate.map { calendar.isDate($0, inSameDayAs: date) } ?? false

                    dayCell(date: date, isToday: isToday, hasRecord: hasRecord, isSelected: isSelected)
                        .onTapGesture {
                            selectedDate = date
                        }
                } else {
                    Color.clear
                        .frame(height: 40)
                }
            }
        }
    }

    private func dayCell(date: Date, isToday: Bool, hasRecord: Bool, isSelected: Bool) -> some View {
        let glowColor: Color? = isToday ? DianaTheme.neonBlue : (hasRecord ? DianaTheme.neonLime : nil)

        return VStack(spacing: 4) {
            Text("\(calendar.component(.day, from: date))")
                .font(DianaTheme.captionEngFont(14))
                .foregroundStyle(isToday ? DianaTheme.neonBlue : DianaTheme.textPrimary)

            Circle()
                .frame(width: 6, height: 6)
                .foregroundStyle(hasRecord ? DianaTheme.neonLime : .clear)
        }
        .frame(maxWidth: .infinity, minHeight: 40)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(glowColor?.opacity(0.15) ?? .clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? (glowColor ?? DianaTheme.textSecondary) : .clear, lineWidth: 1)
                )
                .shadow(color: isSelected ? (glowColor?.opacity(0.6) ?? .clear) : .clear, radius: 4)
        )
    }

    // MARK: - 선택 날짜 기록 목록
    private var selectedDateRecords: some View {
        Group {
            if let selectedDate {
                let dayRecords = recordsFor(selectedDate)
                if dayRecords.isEmpty {
                    Text("이 날의 러닝 기록이 없습니다")
                        .font(DianaTheme.captionKorFont(14))
                        .foregroundStyle(DianaTheme.textTertiary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                } else {
                    ForEach(dayRecords) { record in
                        NavigationLink(value: record) {
                            selectedDateCard(record)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func selectedDateCard(_ record: RunRecord) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(record.startDate.formatted(date: .omitted, time: .shortened))
                    .font(DianaTheme.captionKorFont(12))
                    .foregroundStyle(DianaTheme.textSecondary)

                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text(String(format: "%.2f", record.distanceInKm))
                        .font(DianaTheme.statFont(24))
                        .foregroundStyle(DianaTheme.textPrimary)
                    Text("km")
                        .font(DianaTheme.captionEngFont(12))
                        .foregroundStyle(DianaTheme.textSecondary)
                }
            }

            Spacer()

            HStack(spacing: 16) {
                Label(record.durationString, systemImage: "clock")
                Label(record.paceString, systemImage: "speedometer")
            }
            .font(DianaTheme.captionEngFont(12))
            .foregroundStyle(DianaTheme.textSecondary)
        }
        .dianaCard(DianaTheme.textTertiary)
    }

    // MARK: - Helpers
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월"
        return formatter.string(from: displayedMonth)
    }

    private func daysInMonth() -> [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: displayedMonth),
              let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth))
        else { return [] }

        // 월요일 기준 오프셋 (일요일=1 → 6, 월요일=2 → 0, ...)
        let weekday = calendar.component(.weekday, from: firstDay)
        let offset = (weekday + 5) % 7

        var days: [Date?] = Array(repeating: nil, count: offset)
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay) {
                days.append(date)
            }
        }
        return days
    }

    private func recordsFor(_ date: Date) -> [RunRecord] {
        records.filter { calendar.isDate($0.startDate, inSameDayAs: date) }
    }
}
