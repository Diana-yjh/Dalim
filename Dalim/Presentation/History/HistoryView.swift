//
//  HistoryView.swift
//  Dalim
//
//  Created by Yejin Hong on 2/26/26.
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: \RunRecord.startDate, order: .reverse)
    private var records: [RunRecord]

    @State private var selectedMode = 0

    var body: some View {
        NavigationStack {
            Group {
                if selectedMode == 0 {
                    HistoryListView(records: records)
                } else {
                    HistoryCalendarView(records: records)
                }
            }
            .background(DianaTheme.backgroundPrimary)
            .navigationTitle("기록")
            .toolbarBackground(DianaTheme.backgroundPrimary, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Picker("보기 모드", selection: $selectedMode) {
                        Image(systemName: "list.bullet").tag(0)
                        Image(systemName: "calendar").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 120)
                }
            }
        }
    }
}
