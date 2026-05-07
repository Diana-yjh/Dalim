//
//  RunningSetupView.swift
//  Dalim
//
//  Created by Yejin Hong on 2/26/26.
//

import SwiftUI

struct RunningSetupView: View {
    @State private var isRunning = false
    
    @Bindable var viewModel: RunningSetupViewModel

    init(viewModel: RunningSetupViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    modePicker
                    modeSettingCard
                    startButton
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            .background(DianaTheme.backgroundPrimary)
            .navigationTitle("러닝")
            .toolbarBackground(DianaTheme.backgroundPrimary, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .fullScreenCover(isPresented: $isRunning) {
                ActiveRunView()
            }
        }
        .task {
            viewModel.checkLocationPermission()
            await viewModel.requestNoficiationPermission()
            await viewModel.requestWeather()
        }
        .fullScreenCover(isPresented: $viewModel.showLocationPermissionAlert) {
            LocationPermissionView(
                onOpenSettings: {
                    viewModel.openAppSettings()
                },
                onDismiss: {
                    viewModel.showLocationPermissionAlert = false
                }
            )
        }
    }

    // MARK: - 모드 선택 셀
    private var modePicker: some View {
        HStack(spacing: 10) {
            ForEach(RunningMode.allCases, id: \.self) { mode in
                let isSelected = viewModel.selectedMode == mode

                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.selectedMode = mode
                    }
                } label: {
                    VStack(spacing: 8) {
                        Image(systemName: mode.iconName)
                            .size(24)
                            .foregroundStyle(isSelected ? DianaTheme.neonLime : DianaTheme.textTertiary)

                        Text(mode.displayName)
                            .font(DianaTheme.bodyFont(14))
                            .foregroundStyle(isSelected ? DianaTheme.textPrimary : DianaTheme.textTertiary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: DianaTheme.cardCornerRadius)
                            .fill(isSelected ? DianaTheme.neonLime.opacity(0.1) : .clear)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: DianaTheme.cardCornerRadius)
                            .stroke(isSelected ? DianaTheme.neonLime : DianaTheme.textTertiary.opacity(0.4), lineWidth: isSelected ? 1.2 : 0.5)
                    )
                }
            }
        }
    }

    // MARK: - 모드별 설정 카드
    @ViewBuilder
    private var modeSettingCard: some View {
        switch viewModel.selectedMode {
        case .free:
            freeRunCard
        case .targetTime:
            targetTimeCard
        case .targetDistance:
            targetDistanceCard
        }
    }

    // MARK: - 자유 러닝 (날씨 카드)
    private var freeRunCard: some View {
        HStack(spacing: 16) {
            Image(systemName: viewModel.weatherIcon)
                .size(40)
                .foregroundStyle(DianaTheme.neonBlue)

            VStack(alignment: .leading, spacing: 6) {
                Text(viewModel.currentTemperature)
                    .font(DianaTheme.subtitleFont())
                    .foregroundStyle(DianaTheme.textPrimary)

                Text(viewModel.weatherCondition)
                    .font(DianaTheme.captionKorFont())
                    .foregroundStyle(DianaTheme.textPrimary)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .dianaCard()
    }

    // MARK: - 목표 시간 설정
    private var targetTimeCard: some View {
        VStack(spacing: 20) {
            HStack(spacing: 0) {
                Picker("시간", selection: $viewModel.targetHours) {
                    ForEach(0...5, id: \.self) { h in
                        Text("\(h)시간")
                            .foregroundStyle(DianaTheme.textPrimary)
                            .tag(h)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)

                Picker("분", selection: $viewModel.targetMinutes) {
                    ForEach(Array(stride(from: 0, through: 55, by: 5)), id: \.self) { m in
                        Text("\(m)분")
                            .foregroundStyle(DianaTheme.textPrimary)
                            .tag(m)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)
            }
            .frame(height: 120)
            .onChange(of: viewModel.isAlarmEnabled) { oldValue, newValue in
                viewModel.scheduleDaily()
            }

            Divider()
                .overlay(DianaTheme.textTertiary)

            Toggle(isOn: $viewModel.isAlarmEnabled) {
                HStack(spacing: 8) {
                    Image(systemName: "bell.fill")
                        .foregroundStyle(DianaTheme.neonOrange)
                    Text("목표 시간 알람")
                        .font(DianaTheme.bodyFont())
                        .foregroundStyle(DianaTheme.textPrimary)
                }
            }
            .tint(DianaTheme.neonLime)
        }
        .dianaCard()
    }

    // MARK: - 목표 거리 설정
    private var targetDistanceCard: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Text(String(format: "%.1f", viewModel.targetDistanceKm))
                    .font(DianaTheme.statFont(48))
                    .foregroundStyle(DianaTheme.neonLime)

                Text("km")
                    .font(DianaTheme.captionEngFont(16))
                    .foregroundStyle(DianaTheme.textPrimary)
            }

            Picker("거리", selection: $viewModel.targetDistanceKm) {
                ForEach(Array(stride(from: 1.0, through: 50.0, by: 0.5)), id: \.self) { km in
                    Text(String(format: "%.1f km", km))
                        .foregroundStyle(DianaTheme.textPrimary)
                        .tag(km)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 120)

            Divider()
                .overlay(DianaTheme.textTertiary)

            Toggle(isOn: $viewModel.isVoiceGuideEnabled) {
                HStack(spacing: 8) {
                    Image(systemName: "speaker.wave.2.fill")
                        .foregroundStyle(DianaTheme.neonBlue)
                    Text("1km마다 음성 안내")
                        .font(DianaTheme.bodyFont())
                        .foregroundStyle(DianaTheme.textPrimary)
                }
            }
            .tint(DianaTheme.neonLime)
        }
        .dianaCard()
    }

    // MARK: - 시작 버튼
    private var startButton: some View {
        Button {
            isRunning = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "play.fill")
                Text("러닝 시작하기")
                    .font(DianaTheme.headlineFont(18))
            }
            .foregroundStyle(DianaTheme.backgroundPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(DianaTheme.neonLime)
            .clipShape(RoundedRectangle(cornerRadius: DianaTheme.cardCornerRadius))
        }
        .shadow(color: DianaTheme.neonLime.opacity(0.4), radius: 10)
        .padding(.top, 16)
    }
}
