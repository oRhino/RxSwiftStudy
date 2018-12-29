//
//  BaseViewController.swift
//  RXSwift
//
//  Created by iMac on 2018/1/11.
//  Copyright © 2018年 iMac. All rights reserved.
//

import UIKit


class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)

    }

    deinit {
        
        //获取类型 type(of: self))
        
        //打印结果为对象的地址其实就是description方法 deinit:<RXSwiftDemo.ButtonViewController: 0x14d82ca0>
        print("deinit:" + String(describing: self))
//
//        //打印结果为对象的类型 BaseViewController
//        print(type(of: self))
//
//        //打印结果为对象的class 包含命名空间  RXSwiftDemo.ButtonViewController
//        print(NSStringFromClass(type(of: self)))
//
//        //objc获取class
//        print("deinit: \(String(describing: object_getClass(self)))")
        
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
