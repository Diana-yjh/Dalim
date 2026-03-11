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
        .overlay {
            if viewModel.showHealthKitAlert {
                healthKitAlertOverlay
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
            Text("TIME")
                .font(DianaTheme.captionEngFont(13))
                .foregroundStyle(DianaTheme.textSecondary)
                .tracking(DianaTheme.uppercaseTracking)
            
            Text(viewModel.elapsedTimeString)
                .font(DianaTheme.statFont(56))
                .foregroundStyle(DianaTheme.textPrimary)
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

    // MARK: - HealthKit 권한 알림

    @State private var neverAskChecked = false

    private var healthKitAlertOverlay: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissHealthKitAlert()
                }

            VStack(spacing: 16) {
                // 아이콘 + 타이틀
                Image(systemName: "heart.text.clipboard")
                    .font(.system(size: 36))
                    .foregroundStyle(DianaTheme.neonPink)

                Text("건강 데이터 접근 필요")
                    .font(DianaTheme.subtitleFont(18))
                    .foregroundStyle(DianaTheme.textPrimary)

                Text("심박수 등 건강 데이터를 사용하려면\n설정에서 건강 데이터 접근을 허용해주세요.\n\n설정 > 건강 > 데이터 접근 및 기기에서\nDalim 앱의 접근 권한을 변경할 수 있습니다.")
                    .font(DianaTheme.captionKorFont(13))
                    .foregroundStyle(DianaTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)

                // 다시 묻지 않기 체크박스
                Button {
                    neverAskChecked.toggle()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: neverAskChecked ? "checkmark.square.fill" : "square")
                            .font(.system(size: 18))
                            .foregroundStyle(neverAskChecked ? DianaTheme.neonLime : DianaTheme.textTertiary)

                        Text("다시 묻지 않기")
                            .font(DianaTheme.captionKorFont(13))
                            .foregroundStyle(DianaTheme.textTertiary)
                    }
                }

                // 확인 / 취소 버튼
                HStack(spacing: 10) {
                    Button {
                        dismissHealthKitAlert()
                    } label: {
                        Text("취소")
                            .font(DianaTheme.bodyFont())
                            .foregroundStyle(DianaTheme.textSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(DianaTheme.textTertiary.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }

                    Button {
                        dismissHealthKitAlert()
                        viewModel.openAppSettings()
                    } label: {
                        Text("설정으로 이동")
                            .font(DianaTheme.bodyFont())
                            .foregroundStyle(DianaTheme.backgroundPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(DianaTheme.neonLime)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
            .padding(24)
            .background(DianaTheme.backgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 36)
        }
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.25), value: viewModel.showHealthKitAlert)
    }

    private func dismissHealthKitAlert() {
        if neverAskChecked {
            viewModel.setNeverAskHealthKit()
        }
        viewModel.showHealthKitAlert = false
        neverAskChecked = false
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
