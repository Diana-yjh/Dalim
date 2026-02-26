//
//  MyPageView.swift
//  Dalim
//
//  Created by Yejin Hong on 2/26/26.
//

import SwiftUI
import SwiftData

struct MyPageView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var runRecords: [RunRecord]
    @Query private var profiles: [UserProfile]
    @Query private var settingsList: [UserSettings]

    @State private var isEditingName = false
    @State private var editedName = ""
    @State private var gpxFileURL: URL?
    @State private var showShareSheet = false
    @State private var showLinkSheet = false

    // MARK: - Computed Properties

    private var profile: UserProfile {
        if let existing = profiles.first { return existing }
        let newProfile = UserProfile()
        modelContext.insert(newProfile)
        return newProfile
    }

    private var settings: UserSettings {
        if let existing = settingsList.first { return existing }
        let newSettings = UserSettings()
        modelContext.insert(newSettings)
        return newSettings
    }

    private var totalDistanceKm: Double {
        runRecords.reduce(0) { $0 + $1.distanceInKm }
    }

    private var totalRuns: Int {
        runRecords.count
    }

    private var longestDistanceKm: Double {
        runRecords.map(\.distanceInKm).max() ?? 0
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    profileCard
                    statsRow
                    settingsCard
                    exportButton
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
            .background(DianaTheme.backgroundPrimary)
            .navigationTitle("마이페이지")
            .toolbarBackground(DianaTheme.backgroundPrimary, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .alert("이름 변경", isPresented: $isEditingName) {
            TextField("이름", text: $editedName)
            Button("저장") {
                profile.name = editedName
            }
            Button("취소", role: .cancel) {}
        } message: {
            Text("새 이름을 입력하세요")
        }
    }

    // MARK: - Profile Card

    private var profileCard: some View {
        VStack(spacing: 12) {
            if let imageData = profile.profileImageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundStyle(DianaTheme.textTertiary)
            }

            Text(profile.name)
                .font(DianaTheme.subtitleFont())
                .foregroundStyle(DianaTheme.textPrimary)

            let dateString = profile.joinDate.formatted(
                .dateTime.year().month().day()
            )
            Text("\(dateString) 시작")
                .font(DianaTheme.captionKorFont())
                .foregroundStyle(DianaTheme.textSecondary)

            if profile.isLinked {
                HStack(spacing: 6) {
                    Image(systemName: profile.authProvider == "apple" ? "apple.logo" : "globe")
                        .font(.system(size: 12))
                    Text(profile.authProvider == "apple" ? "Apple 연동됨" : "Google 연동됨")
                        .font(DianaTheme.captionKorFont(12))
                }
                .foregroundStyle(DianaTheme.neonLime)
            } else {
                Button {
                    showLinkSheet = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "link")
                            .font(.system(size: 12))
                        Text("계정 연동하기")
                            .font(DianaTheme.captionKorFont(13))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10))
                    }
                    .foregroundStyle(DianaTheme.neonLime)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .dianaCard(DianaTheme.neonLime)
        .onTapGesture {
            editedName = profile.name
            isEditingName = true
        }
        .sheet(isPresented: $showLinkSheet) {
            AccountLinkSheet { result in
                profile.name = result.name
                profile.isLinked = true
                profile.authProvider = result.provider
                profile.authUserID = result.userID
            }
        }
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        HStack(spacing: 0) {
            statItem(caption: "총 거리", value: String(format: "%.1f", totalDistanceKm), unit: "km")
            statItem(caption: "총 러닝", value: "\(totalRuns)", unit: "회")
            statItem(caption: "최장 거리", value: String(format: "%.1f", longestDistanceKm), unit: "km")
        }
        .dianaCard(DianaTheme.neonLime)
    }

    private func statItem(caption: String, value: String, unit: String) -> some View {
        VStack(spacing: 4) {
            Text(caption)
                .font(DianaTheme.captionKorFont())
                .foregroundStyle(DianaTheme.textSecondary)
            Text(value)
                .font(DianaTheme.statFont(24))
                .foregroundStyle(DianaTheme.textPrimary)
            Text(unit)
                .font(DianaTheme.captionEngFont(11))
                .foregroundStyle(DianaTheme.textTertiary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Settings Card

    private var settingsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("설정")
                .font(DianaTheme.subtitleFont(18))
                .foregroundStyle(DianaTheme.textPrimary)
                .padding(.bottom, 4)

            VStack(spacing: 0) {
                settingsToggleRow(title: "Apple Health 연동", isOn: Binding(
                    get: { settings.isHealthKitEnabled },
                    set: { settings.isHealthKitEnabled = $0 }
                ))
                Divider().background(DianaTheme.textTertiary)
                settingsToggleRow(title: "알림", isOn: Binding(
                    get: { settings.isNotificationEnabled },
                    set: { settings.isNotificationEnabled = $0 }
                ))
                Divider().background(DianaTheme.textTertiary)
                settingsToggleRow(title: "음성 알림", isOn: Binding(
                    get: { settings.isVoiceAlertEnabled },
                    set: { settings.isVoiceAlertEnabled = $0 }
                ))
                Divider().background(DianaTheme.textTertiary)
                distanceUnitRow
            }
        }
        .dianaCard(DianaTheme.neonLime)
    }

    private func settingsToggleRow(title: String, isOn: Binding<Bool>) -> some View {
        Toggle(title, isOn: isOn)
            .font(DianaTheme.bodyFont())
            .foregroundStyle(DianaTheme.textPrimary)
            .tint(DianaTheme.neonLime)
            .padding(.vertical, 8)
    }

    private var distanceUnitRow: some View {
        HStack {
            Text("거리 단위")
                .font(DianaTheme.bodyFont())
                .foregroundStyle(DianaTheme.textPrimary)

            Spacer()

            Picker("", selection: Binding(
                get: { settings.distanceUnit },
                set: { settings.distanceUnit = $0 }
            )) {
                Text("km").tag("km")
                Text("mi").tag("mi")
            }
            .pickerStyle(.segmented)
            .frame(width: 120)
        }
        .padding(.vertical, 8)
    }

    // MARK: - GPX Export

    private var exportButton: some View {
        Button {
            exportGPX()
        } label: {
            Label("GPX 내보내기", systemImage: "square.and.arrow.up")
        }
        .buttonStyle(DianaSecondaryButtonStyle())
        .frame(maxWidth: .infinity)
        .disabled(runRecords.isEmpty)
        .sheet(isPresented: $showShareSheet) {
            if let url = gpxFileURL {
                ShareSheet(activityItems: [url])
            }
        }
    }

    private func exportGPX() {
        let gpxString = generateGPX(from: runRecords)
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("dalim_records.gpx")
        do {
            try gpxString.write(to: tempURL, atomically: true, encoding: .utf8)
            gpxFileURL = tempURL
            showShareSheet = true
        } catch {
            print("GPX 내보내기 실패: \(error)")
        }
    }

    private func generateGPX(from records: [RunRecord]) -> String {
        var gpx = """
        <?xml version="1.0" encoding="UTF-8"?>
        <gpx version="1.1" creator="Dalim">
        """

        for record in records {
            let sortedPoints = record.routePoints.sorted { $0.timestamp < $1.timestamp }
            guard !sortedPoints.isEmpty else { continue }

            gpx += "\n  <trk>"
            gpx += "\n    <name>\(iso8601(record.startDate))</name>"
            gpx += "\n    <trkseg>"

            for point in sortedPoints {
                gpx += "\n      <trkpt lat=\"\(point.latitude)\" lon=\"\(point.longitude)\">"
                gpx += "\n        <ele>\(point.altitude)</ele>"
                gpx += "\n        <time>\(iso8601(point.timestamp))</time>"
                gpx += "\n      </trkpt>"
            }

            gpx += "\n    </trkseg>"
            gpx += "\n  </trk>"
        }

        gpx += "\n</gpx>"
        return gpx
    }

    private func iso8601(_ date: Date) -> String {
        ISO8601DateFormatter().string(from: date)
    }
}

// MARK: - ShareSheet

private struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    MyPageView()
        .modelContainer(for: [RunRecord.self, UserProfile.self, UserSettings.self], inMemory: true)
}
