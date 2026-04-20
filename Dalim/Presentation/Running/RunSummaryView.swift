//
//  RunSummaryView.swift
//  Dalim
//
//  Created by Yejin Hong on 2/26/26.
//

import SwiftUI
import SwiftData
import MapKit
import Charts

struct RunSummaryView: View {
    var viewModel: ActiveRunViewModel
    var onDismiss: () -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                mapSection
                statsGrid
                paceChartSection
                actionButtons
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 24)
        }
        .background(DianaTheme.backgroundPrimary)
    }

    // MARK: - 상단 안내 + 거리 + 날짜
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("러닝 완료!")
                .font(DianaTheme.subtitleFont(20))
                .foregroundStyle(DianaTheme.neonLime)
                .padding(.bottom, 4)

            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(viewModel.distanceString)
                    .font(DianaTheme.statFont(52))
                    .foregroundStyle(DianaTheme.textPrimary)

                Text("km")
                    .font(DianaTheme.captionEngFont(18))
                    .foregroundStyle(DianaTheme.textSecondary)
            }

            Text(formattedDate)
                .font(DianaTheme.captionKorFont(14))
                .foregroundStyle(DianaTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 16)
    }

    // MARK: - 지도 경로
    private var mapSection: some View {
        Map {
            if !viewModel.routeCoordinates.isEmpty {
                MapPolyline(coordinates: viewModel.routeCoordinates)
                    .stroke(DianaTheme.neonLime, lineWidth: 4)
            }
        }
        .mapStyle(.standard(pointsOfInterest: .excludingAll))
        .mapControlVisibility(.hidden)
        .frame(height: 250)
        .clipShape(RoundedRectangle(cornerRadius: DianaTheme.cardCornerRadius))
    }

    // MARK: - 3x2 스탯 그리드
    private var statsGrid: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)

        return LazyVGrid(columns: columns, spacing: 12) {
            statCell(label: "페이스", value: viewModel.paceString, unit: "/km")
            statCell(label: "총 시간", value: viewModel.elapsedTimeString, unit: "")
            statCell(label: "심박수", value: viewModel.heartRateString, unit: "bpm")
            statCell(label: "칼로리", value: viewModel.caloriesString, unit: "kcal")
            statCell(label: "총 고도", value: viewModel.elevationGainString, unit: "m")
            statCell(label: "케이던스", value: viewModel.cadenceString, unit: "spm")
        }
    }

    private func statCell(label: String, value: String, unit: String) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(DianaTheme.captionKorFont(11))
                .foregroundStyle(DianaTheme.textSecondary)

            Text(value)
                .font(DianaTheme.statFont(16))
                .foregroundStyle(DianaTheme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            if !unit.isEmpty {
                Text(unit)
                    .font(DianaTheme.captionEngFont(10))
                    .foregroundStyle(DianaTheme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 60)
        .dianaCard()
    }

    // MARK: - 페이스 차트
    private var paceChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("km별 페이스")
                .font(DianaTheme.captionKorFont(13))
                .foregroundStyle(DianaTheme.textSecondary)

            if viewModel.pacePerKm.isEmpty {
                Text("1km 이상 달려야 표시됩니다")
                    .font(DianaTheme.captionKorFont(12))
                    .foregroundStyle(DianaTheme.textTertiary)
                    .frame(maxWidth: .infinity, minHeight: 150)
            } else {
                Chart {
                    ForEach(Array(viewModel.pacePerKm.enumerated()), id: \.offset) { index, pace in
                        LineMark(
                            x: .value("km", index + 1),
                            y: .value("페이스", pace / 60.0)
                        )
                        .foregroundStyle(DianaTheme.neonLime)
                        .lineStyle(StrokeStyle(lineWidth: 2))

                        PointMark(
                            x: .value("km", index + 1),
                            y: .value("페이스", pace / 60.0)
                        )
                        .foregroundStyle(DianaTheme.neonLime)
                        .symbolSize(30)
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisValueLabel {
                            if let mins = value.as(Double.self) {
                                Text(String(format: "%d:%02d", Int(mins), Int(mins.truncatingRemainder(dividingBy: 1) * 60)))
                                    .font(DianaTheme.captionEngFont(10))
                                    .foregroundStyle(DianaTheme.textSecondary)
                            }
                        }
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.3))
                            .foregroundStyle(DianaTheme.textTertiary)
                    }
                }
                .chartXAxis {
                    AxisMarks { value in
                        AxisValueLabel {
                            if let km = value.as(Int.self) {
                                Text("\(km)km")
                                    .font(DianaTheme.captionEngFont(10))
                                    .foregroundStyle(DianaTheme.textSecondary)
                            }
                        }
                    }
                }
                .chartYScale(domain: .automatic(includesZero: false))
                .frame(height: 180)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .dianaCard()
    }

    // MARK: - 하단 버튼
    private var actionButtons: some View {
        HStack(spacing: 16) {
            ShareLink(
                item: shareText,
                preview: SharePreview("러닝 기록")
            ) {
                Text("공유하기")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(DianaSecondaryButtonStyle())

            Button {
                saveRunRecord()
                dismiss()
                onDismiss()
            } label: {
                Text("확인")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(DianaPrimaryButtonStyle())
        }
        .padding(.top, 8)
    }

    // MARK: - Helpers
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월 d일  HH:mm"
        return formatter.string(from: Date())
    }

    private var shareText: String {
        "🏃 러닝 완료!\n거리: \(viewModel.distanceString) km\n시간: \(viewModel.elapsedTimeString)\n페이스: \(viewModel.paceString)"
    }

    // MARK: - 기록 저장
    private func saveRunRecord() {
        let now = Date()
        let startDate = now.addingTimeInterval(-viewModel.elapsedTime)

        let routePoints = viewModel.routeCoordinates.enumerated().map { index, coord in
            RoutePoint(
                latitude: coord.latitude,
                longitude: coord.longitude,
                altitude: 0,
                timestamp: startDate.addingTimeInterval(Double(index) * (viewModel.elapsedTime / max(Double(viewModel.routeCoordinates.count), 1)))
            )
        }

        let record = RunRecord(
            startDate: startDate,
            endDate: now,
            distance: viewModel.distance,
            duration: viewModel.elapsedTime,
            averagePace: viewModel.currentPace,
            calories: viewModel.calories,
            elevationGain: viewModel.elevationGain,
            averageHeartRate: viewModel.heartRate > 0 ? viewModel.heartRate : nil,
            routePoints: routePoints
        )

        modelContext.insert(record)
    }
}
