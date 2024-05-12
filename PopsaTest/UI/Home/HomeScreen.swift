//
//  HomeScreen.swift
//  PopsaTest
//
//  Created by Dinesh Vijaykumar on 12/05/2024.
//

import SwiftUI

struct HomeScreen: View {
    @Environment(\.openURL) var openURL
    @StateObject var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.authStatus == .granted {
                    grid
                } else if viewModel.authStatus != .notDetermined {
                    noPermissionsView
                }
            }
            .navigationTitle("Recents")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: String.self) { value in
                DetailsScreen(value)
            }
        }
        .tint(.white)
        .onAppear {
            Task {
                await viewModel.requestAuthorization()
            }
        }
    }
}

extension HomeScreen {
    var grid: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: .init(.adaptive(minimum: 100), spacing: 5), count: 4), spacing: 5) {
                ForEach(viewModel.photoIds, id: \.self) { asset in
                    NavigationLink(value: asset) {
                        ThumbnailView(assetID: asset)
                    }
                }
            }
        }
    }
}

extension HomeScreen {
    var noPermissionsView: some View {
        VStack(spacing: 20) {
            Text("In order to view your recent photos, you need to enable the photo permissions in settings")
                .multilineTextAlignment(.center)
                
            Button {
                openURL(URL(string: UIApplication.openSettingsURLString)!)
            } label: {
                Label("App Settings", systemImage: "gear")
            }
        }
        .padding(.horizontal, 16)
    }
}
