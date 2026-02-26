//
//  ProfileHeaderView.swift
//  Dalim
//
//  Created by Yejin Hong on 2/26/26.
//

import SwiftUI

struct ProfileHeaderView: View {
    let userName: String
    let profileImageData: Data?

    var body: some View {
        HStack(spacing: 14) {
            profileImage

            VStack(alignment: .leading, spacing: 4) {
                Text("WELCOME BACK")
                    .font(DianaTheme.captionEngFont(11))
                    .foregroundStyle(DianaTheme.textSecondary)
                    .tracking(DianaTheme.uppercaseTracking)

                Text(userName)
                    .font(DianaTheme.subtitleFont(20))
                    .foregroundStyle(DianaTheme.textPrimary)
            }

            Spacer()
        }
    }

    // MARK: - 프로필 이미지

    private var profileImage: some View {
        Group {
            if let data = profileImageData,
               let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .foregroundStyle(DianaTheme.textTertiary)
            }
        }
        .frame(width: 48, height: 48)
        .clipShape(Circle())
    }
}

#Preview {
    ProfileHeaderView(userName: "러너", profileImageData: nil)
        .padding()
        .background(DianaTheme.backgroundPrimary)
}
