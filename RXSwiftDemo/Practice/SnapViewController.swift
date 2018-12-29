//
//  SnapViewController.swift
//  RXSwiftDemo
//
//  Created by Rhino on 2018/1/13.
//  Copyright © 2018年 iMac. All rights reserved.
//

import UIKit
import SnapKit

class SnapViewController: BaseViewController {
    
    var didSetupConstaints = false
    
    let blackView:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black
        return view
    }()
    
    let blueView:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.blue
        return view
    }()
    
    let greenView:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.green
        return view
    }()
    
    let redView:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.red
        return view
    }()
    
    let yellowView:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.yellow
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(blackView)
        view.addSubview(blueView)
        view.addSubview(yellowView)
        view.addSubview(greenView)
        view.addSubview(redView)
        
        view.setNeedsUpdateConstraints()
        
        //上下左右 宽高 中心 基线
        
        //约束
        //lessThanOrEqualTo
        //equalTo
        //greaterThanOrEqualTo
        
        
        //优先级
        //priority(999)
        
        //更新约束
        //makeConstraints是制作约束，在原来的基础上再添加另外的约束
        //updateConstraints是更新约束，改变原有约束，约束不会增加，没经过updateConstraints处理的保持原有约束，经过处理就更新约束，约束不会减少
        //remakeConstraints去掉已有的所有约束， 重新做约束
        
    }
    
    override func updateViewConstraints() {
        if !didSetupConstaints {
            
            //添加约束
            blackView.snp.makeConstraints({ (make) in
                make.size.equalTo(CGSize(width: 100, height: 100))
                make.center.equalToSuperview()
                //等同于
//                make.center.equalTo(view.center)
//                make.center.equalTo(view.snp.center)
            })
            
            greenView.snp.makeConstraints({ (make) in
                make.width.equalTo(100)
                //比例
                make.height.equalTo(greenView.snp.width).multipliedBy(0.8)
                make.bottom.equalTo(blackView.snp.top).offset(-20)
                make.right.equalTo(blackView.snp.left).offset(-20)
            })
            
            redView.snp.makeConstraints({ (make) in
                make.size.equalTo(blackView.snp.size)
                make.centerX.lessThanOrEqualTo(blackView.snp.right)
//                make.left.equalTo(blackView.snp.right).offset(20)
                make.bottom.equalTo(blackView.snp.top).offset(-20)
            })
            
            yellowView.snp.makeConstraints({ (make) in
                make.size.equalTo(blackView.snp.size)
                make.top.equalTo(blackView.snp.bottom).offset(20)
                make.left.equalTo(greenView.snp.left)
            })
            blueView.snp.makeConstraints({ (make) in
                make.size.equalTo(blackView.snp.size)
                make.top.equalTo(yellowView.snp.top)
                make.left.equalTo(redView.snp.left)
            })
            
            

            didSetupConstaints = true
        }
        
        super.updateViewConstraints()
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
