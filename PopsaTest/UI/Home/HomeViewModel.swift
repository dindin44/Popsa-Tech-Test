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
    
    func requestAuthorization() async {
        let status = await photoService.requestAuthorization()
        self.authStatus = status 
    }
}
