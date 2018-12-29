//
//  MainViewController.swift
//  RXSwiftDemo
//
//  Created by iMac on 2018/1/17.
//  Copyright © 2018年 iMac. All rights reserved.
//

import UIKit
import RxSwift
import SnapKit

class MainViewController: BaseViewController {

    let imagePreview:UIImageView = {
       let image = UIImageView()
        image.backgroundColor = UIColor.orange
        return image
    }()
    let buttonClear:UIButton = {
       let b = UIButton()
        b.backgroundColor = UIColor.brown
        b.setTitle("Clear", for: UIControlState.normal)
        b.addTarget(self, action: #selector(actionClear), for: .touchUpInside)
        print(self)
        return b
    }()
    let buttonSave:UIButton = {
        let b = UIButton()
        b.backgroundColor = UIColor.brown
        b.setTitle("Save", for: UIControlState.normal)
        b.addTarget(self, action: #selector(actionSave), for: .touchUpInside)
        print(self)
        return b
    }()
    //self 打印为Function 且下面这个事件点击没反应,上面两个可以,为什么呢?
//    let itemAdd:UIBarButtonItem = {
//        let item =  UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(actionAdd))
//        print(self)
//        return item
//    }()
    lazy var itemAdd:UIBarButtonItem = {
        let item =  UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(actionAdd))
        print(self)//使用懒加载打印的是控制器对象
        return item
    }()
    private let bag = DisposeBag()
    private let images = Variable<[UIImage]>([])
    private var imageCache = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addUI()
        
        //throttle  //在主线程中操作，如果0.3秒内值发生多次改变，取最后一次的值
        images.asObservable()
            .throttle(0.5, scheduler: MainScheduler.instance)
            .subscribe(onNext:{ [weak self] photos in
            guard let preview  = self?.imagePreview else{
                return
            }
            preview.image = UIImage.collage(images: photos, size: preview.frame.size)
        }).disposed(by: bag)
        
        
        images.asObservable().subscribe(onNext: { [weak self] (photos) in
            self?.updateUI(photos: photos)
            
        }).disposed(by: bag)
        
    }
    
    func addUI(){
    
        view.addSubview(imagePreview)
        view.addSubview(buttonClear)
        view.addSubview(buttonSave)
        
        navigationItem.rightBarButtonItem = itemAdd
    
        
        imagePreview.snp.makeConstraints { (make) in
            make.height.equalTo(210)
            make.centerY.equalToSuperview()
            make.leftMargin.rightMargin.equalToSuperview()
        }
        buttonClear.snp.makeConstraints { (make) in
            make.height.equalTo(40)
            make.width.equalTo(120)
            make.centerX.equalToSuperview().multipliedBy(0.5)
            make.top.equalTo(imagePreview.snp.bottom).offset(20)
        }
        buttonSave.snp.makeConstraints { (make) in
            make.height.equalTo(40)
            make.width.equalTo(120)
            make.centerY.equalTo(buttonClear)
            make.centerX.equalToSuperview().multipliedBy(1.5)
        }
    }

    
    //MARK:Event
    @objc func actionClear() {
        images.value = []
        imageCache = []
        
    }
    
    @objc func actionSave() {
        guard let image = imagePreview.image else {
            return
        }
        
        PhotoWriter.save(image).asSingle().subscribe(onSuccess: { [weak self] (id) in
            self?.showMessage("Saved with id: \(id)")
//            self?.alert(title: "保存成功", text:"Saved with id: \(id)").subscribe(onCompleted: {
//
//            }, onError: { _ in
//
//            }).dispose()
            
            self?.actionClear()
            },onError: { [weak self] (error) in
           self?.showMessage("Error", description: error.localizedDescription)
//                self?.alert(title: "保存失败", text: error.localizedDescription).subscribe(onCompleted: {
//                    
//                }, onError: { _ in
//                    
//                }).dispose()
                
        }).disposed(by: bag)
        
    }
    
    @objc func actionAdd() {
        
        //实例化UICollectionViewController必须传入layout
        let photosViewController = PhotosViewController(collectionViewLayout: UICollectionViewFlowLayout())
        
       let newPhotos =  photosViewController.selectedPhotos.share()
        
        newPhotos.takeWhile { [weak self] (newImage) -> Bool in
            return (self?.images.value.count ?? 0) < 6
            }.filter { (newImage) -> Bool in
                return newImage.size.width > newImage.size.height
            }.filter { [weak self] (newImage) -> Bool in
                //相同的图片只能添加一次
                let len = UIImagePNGRepresentation(newImage)?.count ?? 0
                guard self?.imageCache.contains(len)  == false else{
                    return false
                }
                self?.imageCache.append(len)
                return true
            }.subscribe(onNext: { [weak self] (newImage) in
                guard let images = self?.images else{
                    return
                }
                images.value.append(newImage)
                
                }, onDisposed: {
                    print("completed photo selection")
            }).disposed(by: bag)
        
        
        newPhotos.ignoreElements()
            .subscribe(onCompleted: { [weak self] in
            self?.updateNavigationIcon()
        }).disposed(by: bag)
        
        
//        photosViewController.selectedPhotos.subscribe(onNext: { [weak self] (newImage) in
//            guard let images = self?.images else{
//                return
//            }
//            images.value.append(newImage)
//
//        }, onDisposed: {
//            print("completed photo selection")
//        }).disposed(by: bag)
        
        navigationController?.pushViewController(photosViewController, animated: true)
        
       // images.value.append(UIImage(named: "IMG_1907")!)
    }
    
    private func updateUI(photos:[UIImage]){
        
        buttonSave.isEnabled = photos.count > 0 && photos.count % 2 == 0
        buttonClear.isEnabled = photos.count > 0
        itemAdd.isEnabled = photos.count < 6
        title = photos.count > 0 ? "\(photos.count) photos" : "Collage"
    }
    
    private func updateNavigationIcon(){
        
        let icon = imagePreview.image?
            .scaled(CGSize(width: 22, height: 22))
        .withRenderingMode(.alwaysOriginal)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: icon, style: .done, target: nil, action: nil)
    }
    
    func showMessage(_ title:String,description:String? = nil) {
        let alertController = UIAlertController(title: title, message: description, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Close", style: .default, handler: { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
