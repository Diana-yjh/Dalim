//
//  HealthServiceProtocol.swift
//  Dalim
//
//  Created by Yejin Hong on 4/24/26.
//

protocol HealthServiceProtocol {
    func requestAuthorization() async throws
    func fetchTodaySteps() async throws -> Int
    func fetchTodayActiveEnergy() async throws -> Int
    func fetchLatestHeartRate() async throws -> Int?
}

