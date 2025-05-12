//
//  PhotoService.swift
//  PhotoScroll
//
//  Created by colin.qin on 2025/5/7.
//

import RxSwift
import Photos

class PhotoService {
    func fetchPhotos() -> [Photo] {
        let status = PHPhotoLibrary.authorizationStatus()
        
        guard status == .authorized else {
            if status == .notDetermined {
                var resultPhotos = [Photo]()
//                let semaphore = DispatchSemaphore(value: 0)
                
                PHPhotoLibrary.requestAuthorization { newStatus in
                    if newStatus == .authorized {
                        resultPhotos = self.getPhotos()
                    }
//                    semaphore.signal()
                }
//                semaphore.wait()
                return resultPhotos
            }
            return []
        }
        return getPhotos()
    }
    
    private func getPhotos() -> [Photo] {
        let assets = fetchPHAssets()
        return convertToPhotos(assets: assets)
    }
    
    private func fetchPHAssets() -> [PHAsset] {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let result = PHAsset.fetchAssets(with: .image, options: options)
        return (0..<result.count).map { result.object(at: $0) }
    }
    
    private func convertToPhotos(assets: [PHAsset]) -> [Photo] {
        let manager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        
        return assets.compactMap { asset in
            var resultImage: UIImage?
            manager.requestImage(
                for: asset,
                targetSize: CGSize(width: 300, height: 300),
                contentMode: .aspectFill,
                options: requestOptions
            ) { image, _ in resultImage = image }
            
            guard let image = resultImage else { return nil }
            return Photo(
                assetId: asset.localIdentifier,
                image: image,
                creationDate: asset.creationDate ?? Date(),
                location: asset.location
            )
        }
    }
}
