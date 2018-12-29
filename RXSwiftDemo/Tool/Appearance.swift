//
//  Appearance.swift
//  RXSwiftDemo
//
//  Created by iMac on 2018/1/25.
//  Copyright © 2018年 iMac. All rights reserved.
//

import Foundation
import UIKit

public struct Appearance {
    
    // MARK: Component Theming
    //底部划线
    static func applyBottomLine(to view: UIView, color: UIColor = UIColor.ufoGreen) {
        let line = UIView(frame: CGRect(x: 0, y: view.frame.height - 1, width: view.frame.width, height: 1))
        line.backgroundColor = color
        view.addSubview(line)
    }
    
    static func urlTest(){
        guard let urlComponents = URLComponents.init(string: "http://mobile.hktsc.cc:8071/services/list?appPage=serviceList&brandId=1") else {
            return
        }
        // http
        if let scheme = urlComponents.scheme {
            print("scheme: \(scheme)")
        }
        
        if let user = urlComponents.user {
            print("user: \(user)")
        }
        
        if let password = urlComponents.password {
            print("password: \(password)")
        }
        // mobile.hktsc.cc
        if let host = urlComponents.host {
            print("host: \(host)")
        }
        // 8071
        if let port = urlComponents.port {
            print("port: \(port)")
        }
        // /services/list
        print("path: \(urlComponents.path)")
        
        // appPage=serviceList&brandId=1
        if let query = urlComponents.query {
            print("query: \(query)")
        }
        
        // [appPage=serviceList, brandId=1]
        if let queryItems = urlComponents.queryItems {
            print("queryItems: \(queryItems)")
            
            for (index, queryItem) in queryItems.enumerated() {
                print("第\(index)个queryItem name:\(queryItem.name)")
                if let value = queryItem.value {
                    print("第\(index)个queryItem value:\(value)")
                }
            }
        }
        //        第0个queryItem name:appPage
        //        第0个queryItem value:serviceList
        //        第1个queryItem name:brandId
        //        第1个queryItem value:1
        
        
    }
}

