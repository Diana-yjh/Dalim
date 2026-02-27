//
//  UserSettings.swift
//  Dalim
//
//  Created by Yejin Hong on 2/26/26.
//

import Foundation
import SwiftData

@Model
final class UserSettings {
    var isHealthKitEnabled: Bool
    var isNotificationEnabled: Bool
    var isVoiceAlertEnabled: Bool
    var distanceUnit: String
    var weeklyGoalKm: Double = 40.0

    init(
        isHealthKitEnabled: Bool = false,
        isNotificationEnabled: Bool = false,
        isVoiceAlertEnabled: Bool = true,
        distanceUnit: String = "km",
        weeklyGoalKm: Double = 40.0
    ) {
        self.isHealthKitEnabled = isHealthKitEnabled
        self.isNotificationEnabled = isNotificationEnabled
        self.isVoiceAlertEnabled = isVoiceAlertEnabled
        self.distanceUnit = distanceUnit
        self.weeklyGoalKm = weeklyGoalKm
    }
}
