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

    init(
        isHealthKitEnabled: Bool = false,
        isNotificationEnabled: Bool = false,
        isVoiceAlertEnabled: Bool = true,
        distanceUnit: String = "km"
    ) {
        self.isHealthKitEnabled = isHealthKitEnabled
        self.isNotificationEnabled = isNotificationEnabled
        self.isVoiceAlertEnabled = isVoiceAlertEnabled
        self.distanceUnit = distanceUnit
    }
}
