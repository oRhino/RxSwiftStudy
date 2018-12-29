//
//  PhotoCell.swift
//  RXSwiftDemo
//
//  Created by Rhino on 2018/1/17.
//  Copyright © 2018年 iMac. All rights reserved.
//

import UIKit
import SnapKit

class PhotoCell: UICollectionViewCell {
    
    lazy var imageView:UIImageView = UIImageView()
    
    var representedAssetIdentifier: String!
    
    override init(frame: CGRect) {
       super.init(frame: frame)
        self.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets.zero)
        }
    }
//    override func layoutSubviews() {
//
//        super.layoutSubviews()
//    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    func flash() {
        imageView.alpha = 0
        setNeedsDisplay()
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.imageView.alpha = 1
        }
    }
//    deinit {
//        
//    }
}
