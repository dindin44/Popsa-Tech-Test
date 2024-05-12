//
//  ThumbnailView.swift
//  PopsaTest
//
//  Created by Dinesh Vijaykumar on 12/05/2024.
//

import SwiftUI

struct ThumbnailView: View {
    @Injected(\.photoService) var photoService: PhotoService
    @State private var image: Image?
    
    private var assetID: String
    
    init(assetID: String) {
        self.assetID = assetID
    }
        
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
            await loadImage()
        }
        .onDisappear {
            image = nil
        }
    }
}

extension ThumbnailView {
    func loadImage() async {
        guard let image = try? await photoService.fetchImage(id: assetID, targetSize: .init(width: 100, height: 100)) else {
            image = nil
            return
        }
        self.image = Image(uiImage: image)
    }
}
