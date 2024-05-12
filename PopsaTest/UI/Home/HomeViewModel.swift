//
//  HomeViewModel.swift
//  PopsaTest
//
//  Created by Dinesh Vijaykumar on 12/05/2024.
//

import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Injected(\.photoService) var photoService: PhotoService
    @Published var authStatus: AuthorizationStatus = .notDetermined
    @Published var photoIds = [String]()
    
    func requestAuthorization() async {
        let status = await photoService.requestAuthorization()
        self.authStatus = status 
        
        if status == .granted {
            await loadImages()
        }
    }
    
    private func loadImages() async {
        let ids = await photoService.fetchAllPhotos()
        self.photoIds = ids
    }
}
