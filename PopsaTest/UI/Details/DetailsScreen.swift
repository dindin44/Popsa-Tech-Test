//
//  DetailsScreen.swift
//  PopsaTest
//
//  Created by Dinesh Vijaykumar on 12/05/2024.
//

import SwiftUI

struct DetailsScreen: View {
    @StateObject var viewModel: DetailsViewModel
    @State private var isAspectFit = true
    
    var body: some View {
        GeometryReader { proxy in
            let size = CGSize(width: proxy.size.width, height: proxy.size.height)
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                if viewModel.image != nil {
                    photoView(targetSize: size)
                } else {
                    ProgressView()
                }
            }
            .animation(.easeInOut, value: isAspectFit)
            .task {
                await viewModel.loadImage(targetSize: size)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isAspectFit.toggle()
                    } label: {
                        Image(systemName: "arrow.up.left.and.down.right.magnifyingglass")
                    }
                }
            }
            .toolbarRole(.editor)
           
        }
    }
    
    init(_ assetID: String) {
        self._viewModel = .init(wrappedValue: DetailsViewModel(assetID: assetID))
    }
}

extension DetailsScreen {
    @ViewBuilder
    func photoView(targetSize: CGSize) -> some View {
        viewModel.image?
            .resizable()
            .aspectRatio(contentMode: isAspectFit ? .fit : .fill)
            .frame(width: targetSize.width)
            .overlay(content: {
                if let rect = viewModel.salientRect {
                    Rectangle()
                        .stroke(Color.red, lineWidth: 2)
                        .frame(width: rect.size.width, height: rect.size.height)
                        .position(x: rect.midX, y: rect.midY)
                }
            })
    }
}
