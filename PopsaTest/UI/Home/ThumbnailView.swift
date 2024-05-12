//
//  ThumbnailView.swift
//  PopsaTest
//
//  Created by Dinesh Vijaykumar on 12/05/2024.
//

import SwiftUI

struct ThumbnailView: View {
    @State private var image: Image?
    
    var fetchImage: (() async -> Image?)
    
    var body: some View {
        ZStack {
            if let photo = image {
                GeometryReader { proxy in
                    photo
                        .resizable()
                        .scaledToFill()
                        .frame(width: proxy.size.width, height: proxy.size.width)
                        .clipped()
                }
                .aspectRatio(1, contentMode: .fit)
            } else {
                Rectangle()
                    .foregroundStyle(Color.gray)
                    .aspectRatio(1, contentMode: .fit)
                ProgressView()
            }
        }
        .task {
            let img = await fetchImage()
            self.image = img
        }
        .onDisappear {
            image = nil
        }
    }
}
