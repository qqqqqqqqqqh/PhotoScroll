//
//  Untitled.swift
//  PhotoScroll
//
//  Created by colin.qin on 2025/5/7.
//

import RxSwift
import RxCocoa

class ZoomViewModel {
    var image: Driver<UIImage?> {
        return imageSubject.asDriver()
    }
    
    let imageSubject = BehaviorRelay<UIImage?>(value: nil)
    private let disposeBag = DisposeBag()
    private var currentIndex: Int

    private let photos: [Photo]
    
    
    init(_ photos: [Photo], _ index: Int) {
        self.photos = photos
        self.currentIndex = index
        imageSubject.accept(photos[index].image)
    }
    
    func switchToNext() -> Bool {
        guard currentIndex + 1 < photos.count else { return false }
        currentIndex += 1
        imageSubject.accept(photos[currentIndex].image)
        return true
    }
    
    func switchToPrevious() -> Bool {
        guard currentIndex - 1 >= 0 else { return false }
        currentIndex -= 1
        imageSubject.accept(photos[currentIndex].image)
        return true
    }
    
    func shareCurrentImage() -> UIActivityViewController {
        return UIActivityViewController(
            activityItems: [imageSubject.value!],
            applicationActivities: nil
        )
    }
}
