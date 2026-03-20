//
//  WeatherCardView.swift
//  Dalim
//
//  Created by Yejin Hong on 3/19/26.
//

import SwiftUI

struct WeatherCardView: View {
    let headerCaption: String
    let temperature: String
    let weatherSummary: String
    let humidity: String
    let feelsLike: String
    let wind: String
    let airQuality: String
    let suitability: Suitability
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .lastTextBaseline) {
                Text(headerCaption)
                    .font(DianaTheme.captionEngFont())
                    .foregroundStyle(DianaTheme.textSecondary)
                    .tracking(DianaTheme.uppercaseTracking)
                
                Spacer()
                
                ConditionTag()
            }
            
            VStack(alignment: .leading, spacing: -4) {
                Text("\(temperature)°C")
                    .font(DianaTheme.statFont())
                    .foregroundStyle(DianaTheme.textPrimary)
                    .tracking(DianaTheme.uppercaseTracking)
                Text(weatherSummary)
                    .font(DianaTheme.captionKorFont())
                    .foregroundStyle(suitability.color)
            }
            
            HStack(spacing: 5) {
                weatherStatItemView(caption: "습도", stat: humidity, unit: "%")
                divider
                weatherStatItemView(caption: "바람", stat: wind, unit: "km/h")
                divider
                weatherStatItemView(caption: "미세먼지", stat: airQuality, unit: "")
            }
            .background {
                RoundedRectangle(cornerRadius: 15)
                    .foregroundStyle(DianaTheme.backgroundPrimary)
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .dianaCard()
    }
    
    private func weatherStatItemView(caption: String, stat: String, unit: String) -> some View {
        VStack(alignment: .center, spacing: 10) {
            Text(caption)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .font(DianaTheme.captionKorFont())
                .foregroundStyle(DianaTheme.textSecondary)
                .tracking(DianaTheme.uppercaseTracking)
            
            HStack(alignment: .lastTextBaseline, spacing: 5) {
                Text(stat)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .font(DianaTheme.statFont(18))
                    .foregroundStyle(DianaTheme.textPrimary)
                    .tracking(DianaTheme.uppercaseTracking)
                
                Text(unit)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .font(DianaTheme.captionEngFont())
                    .foregroundStyle(DianaTheme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
    
    private var divider: some View {
        Rectangle()
            .foregroundStyle(DianaTheme.backgroundSecondary)
            .frame(width: 1)
            .frame(maxHeight: .infinity)
        
    }
    
    private func ConditionTag() -> some View {
        HStack(spacing: 6) {
            Circle()
                .frame(width: 10, height: 10)
                .foregroundStyle(suitability.color)
            Text(suitability.label)
                .font(DianaTheme.captionEngFont())
                .foregroundStyle(suitability.color)
        }
    }
}

#Preview {
    WeatherCardView(headerCaption: "RUNNING CONDITIONS", temperature: "14", weatherSummary: "맑음. 지금 달리기 딱 좋아요", humidity: "44", feelsLike: "1", wind: "3.2", airQuality: "좋음", suitability: .perfect)
}
