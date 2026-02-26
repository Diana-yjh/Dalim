//
//  HistoryListView.swift
//  Dalim
//
//  Created by Yejin Hong on 2/26/26.
//

import SwiftUI

struct HistoryListView: View {
    let records: [RunRecord]

    var body: some View {
        if records.isEmpty {
            emptyStateView
        } else {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(records) { record in
                        NavigationLink(value: record) {
                            runRecordCard(record)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            .navigationDestination(for: RunRecord.self) { record in
                RunDetailView(record: record)
            }
        }
    }

    // MARK: - 기록 카드
    private func runRecordCard(_ record: RunRecord) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(record.startDate.formatted(date: .abbreviated, time: .shortened))
                .font(DianaTheme.captionKorFont(12))
                .foregroundStyle(DianaTheme.textSecondary)

            HStack(alignment: .lastTextBaseline) {
                Text(String(format: "%.2f", record.distanceInKm))
                    .font(DianaTheme.statFont(28))
                    .foregroundStyle(DianaTheme.textPrimary)

                Text("km")
                    .font(DianaTheme.captionEngFont(14))
                    .foregroundStyle(DianaTheme.textSecondary)

                Spacer()

                HStack(spacing: 16) {
                    Label(record.durationString, systemImage: "clock")
                    Label(record.paceString, systemImage: "speedometer")
                }
                .font(DianaTheme.captionEngFont(13))
                .foregroundStyle(DianaTheme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .dianaCard()
    }

    // MARK: - 빈 상태
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "figure.run")
                .font(.system(size: 48))
                .foregroundStyle(DianaTheme.textTertiary)

            Text("아직 러닝 기록이 없어요")
                .font(DianaTheme.bodyFont())
                .foregroundStyle(DianaTheme.textSecondary)

            Text("첫 러닝을 시작해보세요!")
                .font(DianaTheme.captionKorFont(14))
                .foregroundStyle(DianaTheme.textTertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
