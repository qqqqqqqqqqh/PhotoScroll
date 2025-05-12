//
//  ViewController.swift
//  PhotoScroll
//
//  Created by colin.qin on 2025/5/7.
//
import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Photos

class ViewController: UIViewController, UICollectionViewDelegate {
    private let viewModel = ViewModel()
    private let disposeBag = DisposeBag()
    
    private var photos: [Photo] = []
    
    private var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(PhotoCell.self, forCellWithReuseIdentifier: "PhotoCell")
        return cv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        bindViewModel()
        viewModel.loadPhotos()
    }
    
    private func setupViews() {

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .systemBlue
        
        navigationItem.title = "PhotoScroll"
        
        
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.right.bottom.equalToSuperview()
        }
        
        collectionView.dataSource = self
        collectionView.delegate = self  // 添加这行如果使用自定义布局
    }
    
    
    private func bindViewModel() {
        // Bind photos to collectionView
        viewModel.photos
            .drive(onNext: { [weak self] photos in
                self?.photos = photos
                self?.collectionView.reloadData()
            })
            .disposed(by: disposeBag)
        
        // Handle item selection
        collectionView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                self.showZoomViewController(indexPath.row)
            })
            .disposed(by: disposeBag)

    }
    
    private func showZoomViewController(_ index: Int) {
        let zoomVC = ZoomViewController(photos, index)
        navigationController?.pushViewController(zoomVC, animated: true)
    }
    
}


extension ViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing: CGFloat = 5
        let availableWidth = collectionView.bounds.width - (spacing * 4) // 两侧边距
        let width = availableWidth / 3  // 三列布局
        return CGSize(width: width, height: width) // 保持正方形
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        
        let photo = photos[indexPath.row]
        cell.imageView.image = photo.image
        
        return cell
    }
}
