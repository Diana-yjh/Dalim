//
//  RunningMode.swift
//  Dalim
//
//  Created by Yejin Hong on 2/26/26.
//

import Foundation

enum RunningMode: String, CaseIterable {
    case free
    case targetTime
    case targetDistance

    var displayName: String {
        switch self {
        case .free: "자유"
        case .targetTime: "시간"
        case .targetDistance: "거리"
        }
    }

    var iconName: String {
        switch self {
        case .free: "figure.run"
        case .targetTime: "timer"
        case .targetDistance: "point.bottomleft.forward.to.point.topright.scurvepath"
        }
    }
}
