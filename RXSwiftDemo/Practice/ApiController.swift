//
//  ApiController.swift
//  RXSwiftDemo
//
//  Created by iMac on 2018/5/23.
//  Copyright © 2018年 iMac. All rights reserved.
//

import Foundation
import RxSwift
import SwiftyJSON

class ApiController {
    
    static let shared = ApiController()
    
    private let apiKey = "4z8LwVlrs3TvY2kmbuvEL0FcDYGQWcab"
    
    func search(text:String) -> Observable<[JSON]> {
        
        let url = URL(string: "http://api.giphy.com/v1/gifs/search")!
        var request = URLRequest(url: url)
        let keyQueryItem = URLQueryItem(name: "api_key", value: apiKey)
        let searchQueryItem = URLQueryItem(name: "q", value: text)
        let urlComponents = NSURLComponents(url: url, resolvingAgainstBaseURL: true)!
        
        urlComponents.queryItems = [searchQueryItem,keyQueryItem]
        
        request.url = urlComponents.url!
        request.httpMethod = "GET"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return URLSession.shared.rx.json(request: request).map() { json in
            return json["data"].array ?? []
        }
    }
}





















