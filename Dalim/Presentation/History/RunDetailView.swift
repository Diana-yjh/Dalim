//
//  RunDetailView.swift
//  Dalim
//
//  Created by Yejin Hong on 2/26/26.
//

import SwiftUI
import SwiftData
import MapKit

struct RunDetailView: View {
    let record: RunRecord

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteAlert = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                mapSection
                statsGrid
                deleteButton
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 24)
        }
        .background(DianaTheme.backgroundPrimary)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(DianaTheme.backgroundPrimary, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarVisibility(.hidden, for: .tabBar)
        .overlay {
            if showDeleteAlert {
                DeleteConfirmDialog(
                    onDelete: {
                        modelContext.delete(record)
                        
                        do {
                            try modelContext.save()
                        } catch {
                            print("삭제 실패: \(error.localizedDescription)")
                        }
                        
                        dismiss()
                    },
                    onCancel: {
                        showDeleteAlert = false
                    }
                )
            }
        }
    }

    // MARK: - 상단 거리 + 날짜
    private var headerSection: some View {
        VStack(spacing: 8) {
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(String(format: "%.2f", record.distanceInKm))
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
        Group {
            if coordinates.isEmpty {
                Text("경로 데이터 없음")
                    .font(DianaTheme.captionKorFont(14))
                    .foregroundStyle(DianaTheme.textTertiary)
                    .frame(maxWidth: .infinity, minHeight: 200)
                    .dianaCard()
            } else {
                Map {
                    MapPolyline(coordinates: coordinates)
                        .stroke(DianaTheme.neonOrange, lineWidth: 4)
                }
                .mapStyle(.standard(pointsOfInterest: .excludingAll))
                .mapControlVisibility(.hidden)
                .frame(height: 250)
                .clipShape(RoundedRectangle(cornerRadius: DianaTheme.cardCornerRadius))
            }
        }
    }

    // MARK: - 3x2 스탯 그리드
    private var statsGrid: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)

        return LazyVGrid(columns: columns, spacing: 12) {
            statCell(label: "페이스", value: record.paceString, unit: "/km")
            statCell(label: "총 시간", value: record.durationString, unit: "")
            statCell(label: "심박수", value: heartRateString, unit: "bpm")
            statCell(label: "칼로리", value: "\(Int(record.calories))", unit: "kcal")
            statCell(label: "총 고도", value: "\(Int(record.elevationGain))", unit: "m")
            statCell(label: "케이던스", value: "\(Int(record.elevationGain))", unit: "m")
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

    // MARK: - 삭제 버튼
    private var deleteButton: some View {
        Button {
            showDeleteAlert = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "trash")
                Text("기록 삭제")
            }
            .font(DianaTheme.headlineFont(16))
            .foregroundStyle(DianaTheme.error)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                Capsule()
                    .stroke(DianaTheme.error.opacity(0.5), lineWidth: 1)
            )
        }
        .padding(.top, 8)
    }

    // MARK: - Helpers
    private var coordinates: [CLLocationCoordinate2D] {
        record.routePoints
            .sorted { $0.timestamp < $1.timestamp }
            .map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
    }

    private var heartRateString: String {
        guard let hr = record.averageHeartRate, hr > 0 else { return "--" }
        return "\(Int(hr))"
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월 d일  HH:mm"
        return formatter.string(from: record.startDate)
    }
}
