//
//  UserProfile.swift
//  Dalim
//
//  Created by Yejin Hong on 2/26/26.
//

import Foundation
import SwiftData

@Model
final class UserProfile {
    var name: String
    var profileImageData: Data?
    var joinDate: Date
    var isLinked: Bool = false
    var authProvider: String = ""    // "apple" | "google" | ""
    var authUserID: String = ""

    init(name: String = "러너", profileImageData: Data? = nil, joinDate: Date = Date()) {
        self.name = name
        self.profileImageData = profileImageData
        self.joinDate = joinDate
    }
}
