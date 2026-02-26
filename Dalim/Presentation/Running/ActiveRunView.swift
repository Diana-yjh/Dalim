//
//  ActiveRunView.swift
//  Dalim
//
//  Created by Yejin Hong on 2/26/26.
//

import SwiftUI
import MapKit

struct ActiveRunView: View {
    @State private var viewModel = ActiveRunViewModel()
    @State private var showSummary = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            mapSection
            distanceSection
            statsRow
            Spacer()
            controlButtons
        }
        .background(DianaTheme.backgroundPrimary)
        .onAppear {
            viewModel.startRun()
        }
        .fullScreenCover(isPresented: $showSummary) {
            RunSummaryView(viewModel: viewModel) {
                dismiss()
            }
        }
    }

    // MARK: - 지도 영역
    private var mapSection: some View {
        Map {
            if !viewModel.routeCoordinates.isEmpty {
                MapPolyline(coordinates: viewModel.routeCoordinates)
                    .stroke(DianaTheme.neonLime, lineWidth: 4)
            }

            if let current = viewModel.currentLocation {
                Annotation("", coordinate: current) {
                    Circle()
                        .fill(DianaTheme.neonBlue)
                        .frame(width: 14, height: 14)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                        )
                        .shadow(color: DianaTheme.neonBlue.opacity(0.6), radius: 6)
                }
            }
        }
        .mapStyle(.standard(pointsOfInterest: .excludingAll))
        .mapControlVisibility(.hidden)
        .frame(maxWidth: .infinity)
        .frame(height: UIScreen.main.bounds.height * 2 / 3)
    }

    // MARK: - 타이머 (중앙 강조)
    private var distanceSection: some View {
        VStack(spacing: 4) {
            Text(viewModel.elapsedTimeString)
                .font(DianaTheme.statFont(56))
                .foregroundStyle(DianaTheme.textPrimary)

            Text("TIME")
                .font(DianaTheme.captionEngFont(13))
                .foregroundStyle(DianaTheme.textSecondary)
                .tracking(DianaTheme.uppercaseTracking)
        }
        .padding(.top, 16)
    }

    // MARK: - 거리/페이스/심박수 카드
    private var statsRow: some View {
        HStack(spacing: 0) {
            miniStat(label: "DISTANCE", value: viewModel.distanceString, unit: "km")
            miniDivider
            miniStat(label: "PACE", value: viewModel.paceString, unit: "/km")
            miniDivider
            miniStat(label: "BPM", value: viewModel.heartRateString, unit: "")
        }
        .dianaCard()
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private func miniStat(label: String, value: String, unit: String) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(DianaTheme.captionEngFont(11))
                .foregroundStyle(DianaTheme.textSecondary)
                .tracking(DianaTheme.uppercaseTracking)

            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value)
                    .font(DianaTheme.statFont(18))
                    .foregroundStyle(DianaTheme.textPrimary)

                if !unit.isEmpty {
                    Text(unit)
                        .font(DianaTheme.captionEngFont(10))
                        .foregroundStyle(DianaTheme.textSecondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var miniDivider: some View {
        Rectangle()
            .fill(DianaTheme.textTertiary.opacity(0.4))
            .frame(width: 0.5, height: 30)
    }

    // MARK: - 제어 버튼
    private var controlButtons: some View {
        Group {
            switch viewModel.runningStatus {
            case .running:
                runningControls
            case .paused:
                pausedControls
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 40)
    }

    private var runningControls: some View {
        Button {
            viewModel.pauseRun()
        } label: {
            Image(systemName: "pause.fill")
        }
        .buttonStyle(DianaCircleButtonStyle(color: DianaTheme.neonOrange, size: 72))
    }

    private var pausedControls: some View {
        HStack(spacing: 40) {
            Button {
                viewModel.stopRun()
                showSummary = true
            } label: {
                Image(systemName: "stop.fill")
            }
            .buttonStyle(DianaCircleButtonStyle(color: DianaTheme.neonPink, size: 72))

            Button {
                viewModel.resumeRun()
            } label: {
                Image(systemName: "play.fill")
            }
            .buttonStyle(DianaCircleButtonStyle(color: DianaTheme.neonLime, size: 72))
        }
    }
}

#Preview {
    ActiveRunView()
}
