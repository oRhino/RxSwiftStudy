//
//  Bundle+Namespace.swift
//  RXSwiftDemo
//
//  Created by iMac on 2018/1/20.
//  Copyright © 2018年 iMac. All rights reserved.
//

import Foundation

extension Bundle{
    var namespace:String{
        return   infoDictionary?["CFBundleName"] as? String ?? ""
    }
}
