//
//  GoalEditSheet.swift
//  Dalim
//
//  Created by Yejin Hong on 2/27/26.
//

import SwiftUI

struct GoalEditSheet: View {
    let currentGoalKm: Double
    let onSave: (Double) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selectedKm: Double

    init(currentGoalKm: Double, onSave: @escaping (Double) -> Void) {
        self.currentGoalKm = currentGoalKm
        self.onSave = onSave
        self._selectedKm = State(initialValue: currentGoalKm)
    }

    private let distanceRange = Array(stride(from: 5.0, through: 100.0, by: 0.5))

    var body: some View {
        VStack(spacing: 24) {
            // MARK: - 타이틀
            Text("주간 목표 설정")
                .font(DianaTheme.subtitleFont())
                .foregroundStyle(DianaTheme.textPrimary)
                .padding(.top, 8)

            // MARK: - 현재 선택 값
            VStack(spacing: 4) {
                Text(String(format: "%.1f", selectedKm))
                    .font(DianaTheme.statFont(48))
                    .foregroundStyle(DianaTheme.neonLime)

                Text("km")
                    .font(DianaTheme.captionEngFont(16))
                    .foregroundStyle(DianaTheme.textPrimary)
            }

            // MARK: - Wheel Picker
            Picker("거리", selection: $selectedKm) {
                ForEach(distanceRange, id: \.self) { km in
                    Text(String(format: "%.1f km", km))
                        .foregroundStyle(DianaTheme.textPrimary)
                        .tag(km)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 120)

            // MARK: - 저장 버튼
            Button {
                onSave(selectedKm)
                dismiss()
            } label: {
                Text("저장하기")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(DianaPrimaryButtonStyle())
            .padding(.horizontal, 16)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DianaTheme.backgroundCard)
        .ignoresSafeArea()
    }
}

#Preview {
    Color.black
        .sheet(isPresented: .constant(true)) {
            GoalEditSheet(currentGoalKm: 30.0) { newGoal in
                print("New goal: \(newGoal)")
            }
            .presentationDetents([.height(400)])
            .presentationDragIndicator(.visible)
        }
}
