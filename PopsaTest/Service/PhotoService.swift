//
//  PhotoService.swift
//  PopsaTest
//
//  Created by Dinesh Vijaykumar on 12/05/2024.
//

import Foundation
import Photos
import UIKit

protocol PhotoService {
    func requestAuthorization() async -> AuthorizationStatus
    func fetchAllPhotos() async -> [String]
    func fetchImage(id: String, targetSize: CGSize, contentMode: PhotoContentMode) async throws -> UIImage?
}

final class PhotoKitService: PhotoService {
    private let cachingManager = PHCachingImageManager()
    
    init() {
        cachingManager.allowsCachingHighQualityImages = false
    }
    
    func requestAuthorization() async -> AuthorizationStatus {
        return await withCheckedContinuation { continuation in
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                switch status {
                case .notDetermined:
                    continuation.resume(returning: .notDetermined)
                case .restricted:
                    continuation.resume(returning: .restricted)
                case .denied:
                    continuation.resume(returning: .denied)
                case .authorized:
                    continuation.resume(returning: .granted)
                case .limited:
                    continuation.resume(returning: .limited)
                @unknown default:
                    continuation.resume(returning: .unknown)
                }
            }
        }
    }
    
    func fetchAllPhotos() async -> [String] {
        return await withCheckedContinuation { continuation in
            let fetchOptions = PHFetchOptions()
            fetchOptions.includeHiddenAssets = false
            fetchOptions.sortDescriptors = [
                NSSortDescriptor(key: "creationDate", ascending: false)
            ]
            fetchOptions.fetchLimit = 1000
            
            let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
            var ids = [String]()
            fetchResult.enumerateObjects { asset, _, _ in
                ids.append(asset.localIdentifier)
            }
            
            continuation.resume(returning: ids)
        }
    }
    
    func fetchImage(id: String, targetSize: CGSize, contentMode: PhotoContentMode) async throws -> UIImage? {
        let results = PHAsset.fetchAssets(withLocalIdentifiers: [id], options: nil)
        guard let asset = results.firstObject else { throw PhotoServiceError.assetNotFound }
        
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.resizeMode = .fast
        options.isNetworkAccessAllowed = true
        options.isSynchronous = true
        
        let aspect:PHImageContentMode = contentMode == .aspectFill ? .aspectFill : .aspectFit
        
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            self?.cachingManager.requestImage(for: asset, targetSize: targetSize, contentMode: aspect, options: nil, resultHandler: { image, info in
                if let error = info?[PHImageErrorKey] as? Error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume(returning: image)
            })
        }
    }
    
    enum PhotoServiceError: Error {
        case assetNotFound
    }
}

enum AuthorizationStatus {
    case notDetermined, granted, denied, restricted, limited, unknown
}

enum PhotoContentMode {
    case aspectFit, aspectFill
}
