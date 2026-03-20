//
//  RunningSuitability.swift
//  Dalim
//
//  Created by Yejin Hong on 3/19/26.
//

import SwiftUI

enum Suitability {
    case perfect
    case good
    case fair
    case bad
    case worst
    case none
    
    var color: Color {
        switch self {
        case .perfect: return DianaTheme.neonLime
        case .good:    return DianaTheme.neonBlue
        case .fair:    return DianaTheme.neonYellow
        case .bad:     return DianaTheme.neonOrange
        case .worst:   return DianaTheme.neonPink
        case .none:    return DianaTheme.textSecondary
        }
    }
    
    var label: String {
        switch self {
        case .perfect: return "PERFECT"
        case .good:    return "GOOD"
        case .fair:    return "FAIR"
        case .bad:     return "BAD"
        case .worst:   return "WORST"
        case .none:    return "N/A"
        }
    }
    
    var description: String {
        switch self {
        case .perfect: return "신나게 달려볼까요?"
        case .good:    return "가볍게 뛰어볼까요?"
        case .fair:    return "천천히 달려볼까요?"
        case .bad:     return "오늘은 스트레칭을 추천해요."
        case .worst:   return "오늘 달리기는 쉬어가는게 어때요?"
        case .none:    return "날씨 정보 로딩에 실패하였습니다"
        }
    }
}
