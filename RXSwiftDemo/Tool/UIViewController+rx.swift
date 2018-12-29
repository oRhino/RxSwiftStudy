//
//  UIViewController+rx.swift
//  RXSwiftDemo
//
//  Created by iMac on 2018/1/20.
//  Copyright © 2018年 iMac. All rights reserved.
//

import Foundation
import UIKit
import RxSwift


extension UIViewController{
    
    //Completable
    //只会发出completed,error
    func alert(title:String,text:String?) -> Completable {
    
        return Completable.create(subscribe: { [weak self] (completable) -> Disposable in
            
            let alertVC = UIAlertController(title: title, message: text, preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "Close", style: .default, handler: { _ in
                completable(.completed)
            }))
            
            self?.present(alertVC, animated: true, completion: nil)
            
            
            return Disposables.create {
                self?.dismiss(animated: true, completion: nil)
            }
            
        })
    }
    
}

extension UIViewController{
    //测试
    public func example(of descriptions:String,action:()->()){
        print("\n ---Example of:",descriptions,"---")
        action()
    }
}
