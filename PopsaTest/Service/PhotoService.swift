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
    /// Request authorization to access the photo library
    /// - Returns: The permission status granted by the user
    func requestAuthorization() async -> AuthorizationStatus
    /// Fetch all references for the photos in the user's photo library
    /// - Returns: A list of unique identifiers for photos in library
    func fetchAllPhotos() async -> [String]
    /// Fetch the actual photo for the given identifier
    /// - Parameters:
    ///   - id: The id for the image to be loaded.
    ///   - targetSize: The target size of image to be returned.
    /// - Returns: The actual image for the given identifier if it exists
    func fetchImage(id: String, targetSize: CGSize) async throws -> UIImage?
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
                case .authorized, .limited:
                    continuation.resume(returning: .granted)
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
    
    func fetchImage(id: String, targetSize: CGSize) async throws -> UIImage? {
        let results = PHAsset.fetchAssets(
            withLocalIdentifiers: [id],
            options: nil
        )
        guard let asset = results.firstObject else {
            throw PhotoServiceError.assetNotFound
        }
        
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.isNetworkAccessAllowed = true
        options.isSynchronous = true
                
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            self?.cachingManager.requestImage(
                for: asset,
                targetSize: targetSize,
                contentMode: .default,
                options: options,
                resultHandler: { image, info in
                    /// image is of type UIImage
                    if let error = info?[PHImageErrorKey] as? Error {
                        continuation.resume(throwing: error)
                        return
                    }
                    continuation.resume(returning: image)
                }
            )
        }
    }
    
    enum PhotoServiceError: Error {
        case assetNotFound
    }
}

enum AuthorizationStatus {
    case notDetermined, granted, denied, restricted, unknown
}
