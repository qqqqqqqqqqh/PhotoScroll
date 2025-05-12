//
//  PhotoViewModel.swift
//  PhotoScroll
//
//  Created by colin.qin on 2025/5/7.
//

import RxSwift
import RxCocoa
import Photos

class ViewModel {
    // MARK: - Outputs
    var photos: Driver<[Photo]> {
        return photosSubject.asDriver()
    }
    
    
    
    let photosSubject = BehaviorRelay<[Photo]>(value: [])
    let isLoading = BehaviorRelay<Bool>(value: false)
    let error = PublishSubject<Error>()
    
    // MARK: - Private Properties
    private let disposeBag = DisposeBag()
    let photoService = PhotoService()
    

    // MARK: - Public Methods
    func loadPhotos() {
        isLoading.accept(true)
        
        photosSubject.accept(photoService.fetchPhotos())
//            .subscribe(onNext: { [weak self] photos in
//                self?.photosSubject.accept(photos)
//                self?.isLoading.accept(false)
//            }, onError: { [weak self] error in
//                self?.error.onNext(error)
//                self?.isLoading.accept(false)
//            })
//            .disposed(by: disposeBag)
    }
    
//    func sharePhoto(at index: Int) -> Observable<Bool> {
//        guard index < photosSubject.value.count else {
//            return Observable.just(false)
//        }
//        return PhotoSharer.share(image: photosSubject.value[index].image)
//    }
}
