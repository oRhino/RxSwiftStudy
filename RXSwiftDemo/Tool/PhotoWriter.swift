//
//  File.swift
//  RXSwiftDemo
//
//  Created by iMac on 2018/1/19.
//  Copyright © 2018年 iMac. All rights reserved.
//

import Foundation
import UIKit
import Photos
import RxSwift

class PhotoWriter {
    
    enum Errors:Error{
        case couldNotSavePhoto
    }
    
    /// Single
    ///
    /// - Parameter image: 图片
    /// - Returns: Single<assetID>
    static func save(_ image:UIImage) -> Single<String>{

        return Single.create(subscribe: { (observer) -> Disposable in
            
            var saveAssetId:String?
            //保存图片到相册
            PHPhotoLibrary.shared().performChanges({
                let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
                saveAssetId = request.placeholderForCreatedAsset?.localIdentifier
                
            }, completionHandler: { (success, error) in
                
                DispatchQueue.main.async {
                    if success,let id = saveAssetId{
                        observer(.success(id))
                    }else{
                        observer(.error(error ?? Errors.couldNotSavePhoto))
                    }
                }
            })
            
            return Disposables.create()
        })
    }
    
    
    static func save(_ image:UIImage) -> Observable<String>{
        
        return Observable.create({ (observer) in
            
            var saveAssetId:String?
            PHPhotoLibrary.shared().performChanges({
                let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
                saveAssetId = request.placeholderForCreatedAsset?.localIdentifier
            }, completionHandler: { (success, error) in
                
                DispatchQueue.main.async {
                    if success,let id = saveAssetId{
                        observer.onNext(id)
                        observer.onCompleted()
                    }else{
                        observer.onError(error ?? Errors.couldNotSavePhoto)
                    }
                }
                
            })
            
            return Disposables.create()
        })
    }
    
    
}
