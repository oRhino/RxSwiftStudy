
//
//  PhotosViewController.swift
//  RXSwiftDemo
//
//  Created by iMac on 2018/1/17.
//  Copyright © 2018年 iMac. All rights reserved.
//

import UIKit
import Photos
import RxSwift

class PhotosViewController: UICollectionViewController {

    
    // MARK:public property
    var selectedPhotos:Observable<UIImage>{
        return selectedPhotosSubject.asObservable()
    }
    
    // MARK:Private property
    private let selectedPhotosSubject = PublishSubject<UIImage>()
    private let bag = DisposeBag()
    private lazy var photos = PhotosViewController.loadPhotos()
    //PHImageManager:用于处理资源的加载，加载图片的过程带有缓存处理，可以通过传入一个 PHImageRequestOptions 控制资源的输出尺寸等规格。
    private lazy var imageManager = PHCachingImageManager()
    
    private lazy var thumbnailSize:CGSize = {
        let cellSize = (self.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        return CGSize(width: cellSize.width * UIConst.ScreenScale, height: cellSize.height * UIConst.ScreenScale)
    }()
    
    //PHAsset : 代表照片库中的一个资源，跟 ALAsset 类似，通过 PHAsset 可以获取和保存资源。每个PHAsset就是一张图片的详细信息，包括图片、位置、时间等。
    //PHFetchResult: 表示一系列的资源集合，也可以是相册的集合。

    static func loadPhotos() -> PHFetchResult<PHAsset>{
        //获取资源时的配置
        let allPhotosOptions = PHFetchOptions()
        //根据创建时间排序
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        //获取所有的资源
        return PHAsset.fetchAssets(with: allPhotosOptions)
    }
    
    
    override init(collectionViewLayout layout: UICollectionViewLayout) {
        let flow:UICollectionViewFlowLayout = layout as! UICollectionViewFlowLayout
        flow.itemSize = CGSize(width: 80, height: 80)
        flow.minimumLineSpacing = 10
        flow.sectionInset = UIEdgeInsets(top: 16, left: 0, bottom: 8, right: 8)
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View Controller
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.register(PhotoCell.self, forCellWithReuseIdentifier: "Cell")
        
        let authorized = PHPhotoLibrary.authorized.share()
            
            authorized
            .skipWhile{$0 == false}
            .take(1)
            .subscribe(onNext:{ [weak self] _ in
                self?.photos = PhotosViewController.loadPhotos()
                DispatchQueue.main.async {
                    self?.collectionView?.reloadData()
                 }
            }).disposed(by: bag)
        
        authorized
            .skip(1)
            .takeLast(1)
            .filter { $0 == false }
            .subscribe(onNext: { [weak self] _ in
                guard let errorMessage = self?.errorMessage else { return }
                DispatchQueue.main.async(execute: errorMessage)
            })
            .disposed(by: bag)
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        selectedPhotosSubject.onCompleted()
    }
    
    private func errorMessage() {
        alert(title: "No access to camera roll", text: "You can grant acess to RXSwiftDemo from the settings app")
        .asObservable()
        .take(5.0, scheduler: MainScheduler.instance)
            .subscribe(onNext:{ [weak self] _ in
                self?.dismiss(animated: true, completion: nil)
                self?.navigationController?.popViewController(animated: true)
            })
        .disposed(by: bag)
        
    }
    
    // MARK: UICollectionView
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let asset = photos.object(at:indexPath.item)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PhotoCell
        cell.representedAssetIdentifier = asset.localIdentifier
        
        imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil) { (image, _) in
            if cell.representedAssetIdentifier == asset.localIdentifier{
                cell.imageView.image = image
            }
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = photos.object(at: indexPath.item)
        
        if let cell = collectionView.cellForItem(at: indexPath) as? PhotoCell {
            cell.flash()
        }
        
        imageManager.requestImage(for: asset, targetSize: view.frame.size, contentMode: .aspectFill, options: nil, resultHandler: { [weak self] image, info in
            guard let image = image, let info = info else { return }
            if let isThumbnail = info[PHImageResultIsDegradedKey as NSString] as? Bool,!isThumbnail{
                self?.selectedPhotosSubject.onNext(image)
            }
        })
    }
    deinit {
        print("deinit:" + String(describing: self))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
