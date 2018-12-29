//
//  WeatherApi.swift
//  RXSwiftDemo
//
//  Created by iMac on 2018/1/25.
//  Copyright © 2018年 iMac. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import SwiftyJSON
import CoreLocation
import MapKit



class WeatherApi {
    
    /// The shared instance
    static var shared = WeatherApi()
    
    /// The api key to communicate with
    /// Create you own on https://www.heweather.com/
    private let apiKey = "68c8184038f0440fa6a15c45b5b39e36"
    
    /// API base URL
    let baseURL = URL(string: "https://free-api.heweather.com/v5/now")!
    
    init() {
        Logging.URLRequests = { request in
            return true
        }
    }
    
    //MARK: - Api Calls
    
    func currentWeather(city: String) -> Observable<Weather> {
        
        return request(method: "GET", city: city).map{ json in
            
            return Weather(cityName: city,
                           temperature: json["HeWeather5"][0]["now"]["tmp"].intValue ,
                           humidity: json["HeWeather5"][0]["now"]["hum"].intValue ,
                           icon: json["HeWeather5"][0]["now"]["cond"]["txt"].stringValue,
                           lat: json["HeWeather5"][0]["basic"]["lat"].doubleValue,
                           lon: json["HeWeather5"][0]["basic"]["lon"].doubleValue)
        }
        
    }
    
    func currentWeather(lat:Double,lon:Double) -> Observable<Weather> {
        
        let city = "\(lat),\(lon)"
        return request(method: "GET", city:city).map{ json in
            return Weather(cityName: json["HeWeather5"][0]["basic"]["city"].stringValue,
                           temperature: json["HeWeather5"][0]["now"]["tmp"].intValue ,
                           humidity: json["HeWeather5"][0]["now"]["hum"].intValue ,
                           icon: json["HeWeather5"][0]["now"]["cond"]["txt"].stringValue,
                           lat: json["HeWeather5"][0]["basic"]["lat"].doubleValue,
                           lon: json["HeWeather5"][0]["basic"]["lon"].doubleValue)
        }
        
    }
    
    private func request(method:String = "GET",city:String = "深圳") -> Observable<JSON>{
        
        var request = URLRequest(url: baseURL)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)!
        let keyQueryItem = URLQueryItem(name: "key", value: apiKey)
        let unitsQueryItem = URLQueryItem(name: "city", value: city)
        components.queryItems = [keyQueryItem,unitsQueryItem]
        request.url = components.url
        
        let session = URLSession.shared
       return session.rx.data(request: request).map { try! JSON(data: $0) }
    }
    
    
    
    //MARK: - Private Methods
    
    /**
     * Private method to build a request with RxCocoa
     */
    private func buildRequest(method: String = "GET", pathComponent: String, params: [(String, String)]) -> Observable<JSON> {
        
        let url = baseURL.appendingPathComponent(pathComponent)
        var request = URLRequest(url: url)
        let keyQueryItem = URLQueryItem(name: "key", value: apiKey)
        let unitsQueryItem = URLQueryItem(name: "city", value: "metric")
        let urlComponents = NSURLComponents(url: url, resolvingAgainstBaseURL: true)!
        
        if method == "GET" {
            var queryItems = params.map { URLQueryItem(name: $0.0, value: $0.1) }
            queryItems.append(keyQueryItem)
            queryItems.append(unitsQueryItem)
            urlComponents.queryItems = queryItems
        } else {
            urlComponents.queryItems = [keyQueryItem, unitsQueryItem]
            
            let jsonData = try! JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            request.httpBody = jsonData
        }
        
        request.url = urlComponents.url!
        request.httpMethod = method
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        
        return session.rx.data(request: request).map { try! JSON(data: $0) }
    }
    
    
    
    struct Weather {
        
        let cityName:String
        let temperature:Int
        let humidity:Int
        let icon:String
        let lat:Double
        let lon:Double
        
        
        static let empty  = Weather(
            cityName: "Unknown",
            temperature: -1000,
            humidity: 0,
            icon: "NUll",
            lat:0,
            lon:0
        )
        
        static let dummy = Weather(
            cityName: "RxCity",
            temperature: 20,
            humidity: 90,
            icon: "x",
            lat: 0,
            lon: 0
        )
        
        var coordinate:CLLocationCoordinate2D{
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
        
        func overlay() ->  Overlay{

            
            let coordinates:[CLLocationCoordinate2D] = [
                CLLocationCoordinate2D(latitude: lat - 0.25, longitude: lon - 0.25),
                CLLocationCoordinate2D(latitude: lat + 0.25, longitude: lon + 0.25)
            ]
            
            let points = coordinates.map{MKMapPointForCoordinate($0)}
            
            let rects = points.map{ MKMapRect(origin: $0, size: MKMapSize(width: 0, height: 0)) }
            let fittingRect = rects.reduce(MKMapRectNull, MKMapRectUnion)
            
            return Overlay(icon: icon, coordinate: coordinate, boundingMapRect: fittingRect)
        }
        
        
        public class Overlay:NSObject,MKOverlay{
            
            var coordinate: CLLocationCoordinate2D
            var boundingMapRect: MKMapRect
            var icon:String
            
            init(icon:String,coordinate:CLLocationCoordinate2D,boundingMapRect:MKMapRect) {
                self.icon = icon
                self.coordinate = coordinate
                self.boundingMapRect = boundingMapRect
            }
        }
    
        public class OverlayView:MKOverlayRenderer{
            var overlayIcon:String
            init(overlay: MKOverlay,overlayIcon:String) {
                self.overlayIcon = overlayIcon
                super.init(overlay: overlay)
            }
            
            public override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
                let imageReference = imageFromText(text: overlayIcon  as NSString, font: UIFont(name: "Flaticon", size: 32.0)!).cgImage
                let theMapRect = overlay.boundingMapRect
                let theRect = rect(for: theMapRect)
                context.scaleBy(x: 1.0, y: -1.0)
                context.translateBy(x: 0.0, y: -theRect.size.height)
                context.draw(imageReference!, in: theRect)
            }
        }
    
    
    }
    
    
}


fileprivate func imageFromText(text:NSString,font:UIFont) -> UIImage{
    
    let size = text.size(withAttributes: [NSAttributedStringKey.font : font])
    
    UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
    text.draw(at: CGPoint(x:0,y:0), withAttributes: [NSAttributedStringKey.font : font])
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image ?? UIImage()
}
