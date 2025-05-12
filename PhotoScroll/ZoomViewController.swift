//
//  ZoomViewController.swift
//  PhotoScroll
//
//  Created by colin.qin on 2025/5/7.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class ZoomViewController: UIViewController {
    private var viewModel: ZoomViewModel
    private let disposeBag = DisposeBag()
    var shareButton: UIBarButtonItem!
    
    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.delegate = self
        sv.maximumZoomScale = 5.0
        sv.minimumZoomScale = 1.0
        sv.showsVerticalScrollIndicator = false
        sv.showsHorizontalScrollIndicator = false
        return sv
    }()
    
    private lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    init(_ photos: [Photo], _ index: Int) {
        viewModel = ZoomViewModel(photos, index)
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()

        bindViewModel()
        setupGestures()
    }
    
    private func setupViews() {
        
        shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: nil, action: nil)
        navigationItem.rightBarButtonItem = shareButton
        
        view.backgroundColor = .white
        view.addSubview(scrollView)
        scrollView.backgroundColor = .black

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.right.bottom.equalToSuperview()
        }
        
        scrollView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.lessThanOrEqualToSuperview()
        }
    }
    
    
    
    private func bindViewModel() {
        viewModel.image
            .drive(imageView.rx.image)
            .disposed(by: disposeBag)
        
        shareButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                let ac = self?.viewModel.shareCurrentImage()
                self?.present(ac!, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer()
        imageView.addGestureRecognizer(tapGesture)
        
        tapGesture.rx.event
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                if self.scrollView.zoomScale > self.scrollView.minimumZoomScale {
                    self.scrollView.setZoomScale(self.scrollView.minimumZoomScale, animated: true)
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
            })
            .disposed(by: disposeBag)
        
        let leftSwipe = UISwipeGestureRecognizer()
        leftSwipe.direction = .left
        view.addGestureRecognizer(leftSwipe)

        let rightSwipe = UISwipeGestureRecognizer()
        rightSwipe.direction = .right
        view.addGestureRecognizer(rightSwipe)

        Observable.merge(
            leftSwipe.rx.event.map { _ in true },
            rightSwipe.rx.event.map { _ in false }
        )
        .subscribe(onNext: { [weak self] isLeft in
            guard let self = self else { return }
            let switched = isLeft ?
                self.viewModel.switchToNext() :
                self.viewModel.switchToPrevious()
                
            if switched {
                self.scrollView.setZoomScale(self.scrollView.minimumZoomScale, animated: false)
            }
        })
        .disposed(by: disposeBag)
    }
    
}

extension ZoomViewController: UIScrollViewDelegate {
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        imageView.snp.remakeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.lessThanOrEqualToSuperview()
        }
        self.scrollView.contentInset = UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: 0,
            right: 0
        )
        scrollView.contentSize = CGSizeZero
    }
    
    // 指定哪个子视图可以缩放
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        // 1. 计算当前缩放后的图片尺寸
        let imageWidth = imageView.frame.width
        let imageHeight = imageView.frame.height
        // 2. 获取 scrollView 的可见区域尺寸
        let scrollWidth = scrollView.bounds.width
        let scrollHeight = scrollView.bounds.height
        
        if imageWidth <= scrollWidth && imageHeight <= scrollHeight {
            imageView.snp.remakeConstraints { make in
                make.center.equalToSuperview()
                make.width.height.lessThanOrEqualToSuperview()
            }
            scrollView.contentInset = UIEdgeInsets(
                top: 0,
                left: 0,
                bottom: 0,
                right: 0
            )
            scrollView.contentSize = CGSizeZero
        } else {
            imageView.snp.remakeConstraints { make in
                make.center.equalTo(scrollView.contentLayoutGuide)
                make.width.height.lessThanOrEqualTo(scrollView.contentLayoutGuide)
            }
            // 3. 计算水平和垂直方向的偏移量
            let horizontalInset = max((scrollWidth - imageWidth) / 2, 0)
            let verticalInset = max((scrollHeight - imageHeight) / 2, 0)
            
            // 4. 更新 contentInset 以居中图片
            scrollView.contentInset = UIEdgeInsets(
                top: verticalInset,
                left: horizontalInset,
                bottom: verticalInset,
                right: horizontalInset
            )
        }

        // 5. 强制更新布局（可选）
        scrollView.layoutIfNeeded()
    }
    
}
