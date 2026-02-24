//
//  RoutePoint.swift
//  Dalim
//
//  Created by Yejin Hong on 2/24/26.
//

import Foundation
import SwiftData
import CoreLocation

// MARK: - GPS 좌표 포인트
@Model
final class RoutePoint {
    var latitude: Double
    var longitude: Double
    var altitude: Double
    var timestamp: Date
    var runRecord: RunRecord?
    
    init(latitude: Double, longitude: Double, altitude: Double, timestamp: Date, runRecord: RunRecord? = nil) {
        self.latitude = latitude
        self.longitude = longitude
        self.altitude = altitude
        self.timestamp = timestamp
        self.runRecord = runRecord
    }
}
