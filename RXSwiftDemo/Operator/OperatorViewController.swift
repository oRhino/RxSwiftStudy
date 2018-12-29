//
//  OperatorViewController.swift
//  RXSwiftDemo
//
//  Created by iMac on 2018/1/20.
//  Copyright © 2018年 iMac. All rights reserved.
//

import UIKit

/// 操作符列表控制器
class OperatorViewController: ViewController {

    override var dataSource:[[String:String]]{
        return [["title":"Filtering","viewcontroller":"FilteringViewController"],
                ["title":"Transforming","viewcontroller":"TransformingViewController"],
                ["title":"Combining","viewcontroller":"CombiningViewController"],
                ["title":"TimeBased","viewcontroller":"TimeBasedViewController"]
        ]
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

