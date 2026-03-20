//
//  Temp.swift
//  Dalim
//
//  Created by Yejin Hong on 3/20/26.
//

import Foundation

struct AirPollutionResponse: Codable {
    let list: [AirPollutionItem]
}

struct AirPollutionItem: Codable {
    let main: AirPollutionMain
    let components: AirPollutionComponents
}

struct AirPollutionMain: Codable {
    let aqi: Int // 1~5
}

struct AirPollutionComponents: Codable {
    let pm2_5: Double
    let pm10: Double

    enum CodingKeys: String, CodingKey {
        case pm2_5 = "pm2_5"
        case pm10
    }
}
