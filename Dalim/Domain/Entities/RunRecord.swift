//
//  RunRecord.swift
//  Dalim
//
//  Created by Yejin Hong on 2/24/26.
//

import Foundation
import SwiftData

@Model
final class RunRecord {
    var id: UUID
    var startDate: Date
    var endDate: Date
    var distance: Double
    var duration: TimeInterval
    var averagePace: Double
    var calories: Double
    var elevationGain: Double
    var averageHeartRate: Double?
    
    @Relationship(deleteRule: .cascade, inverse: \RoutePoint.runRecord)
    var routePoints: [RoutePoint]
    
    init(
        startDate: Date,
        endDate: Date,
        distance: Double,
        duration: TimeInterval,
        averagePace: Double,
        calories: Double,
        elevationGain: Double,
        averageHeartRate: Double? = nil,
        routePoints: [RoutePoint]
    ) {
        self.id = UUID()
        self.startDate = startDate
        self.endDate = endDate
        self.distance = distance
        self.duration = duration
        self.averagePace = averagePace
        self.calories = calories
        self.elevationGain = elevationGain
        self.averageHeartRate = averageHeartRate
        self.routePoints = routePoints
    }
}

extension RunRecord {
    // 거리(km)
    var distanceInKm: Double {
        distance / 1000.0
    }
    
    // 페이스
    var paceString: String {
        let minutes = Int(averagePace) / 60
        let seconds = Int(averagePace) % 60
        return "\(minutes):\(String(format: "%02d", seconds))"
    }
    
    // 시간 문자열
    var durationString: String {
        let totalSeconds = Int(duration)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
