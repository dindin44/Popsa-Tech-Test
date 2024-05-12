//
//  InjectionKey.swift
//  PopsaTest
//
//  Created by Dinesh Vijaykumar on 12/05/2024.
//

import Foundation

public protocol InjectionKey {

    /// The associated type representing the type of the dependency injection key's value.
    associatedtype Value

    /// The default value for the dependency injection key.
    static var currentValue: Self.Value { get set }
}

private struct PhotoServiceKey: InjectionKey {
    static var currentValue: PhotoService = PhotoKitService()
}

private struct SaliencyServiceKey: InjectionKey {
    static var currentValue: SaliencyService = VisionService()
}

extension InjectedValues {
    var photoService: PhotoService {
        get { Self[PhotoServiceKey.self] }
        set { Self[PhotoServiceKey.self] = newValue }
    }
    
    var saliencyService: SaliencyService {
        get { Self[SaliencyServiceKey.self] }
        set { Self[SaliencyServiceKey.self] = newValue }
    }
}
