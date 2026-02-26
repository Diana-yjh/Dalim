//
//  Image+Extension.swift
//  Dalim
//
//  Created by Yejin Hong on 2/25/26.
//

import SwiftUI

extension Image {
    func size(_ size: CGFloat) -> some View {
        self
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
    }
}
