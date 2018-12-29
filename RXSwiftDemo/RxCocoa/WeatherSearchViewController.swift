//
//  WeatherSearchViewController.swift
//  RXSwiftDemo
//
//  Created by iMac on 2018/1/24.
//  Copyright © 2018年 iMac. All rights reserved.
//

/*

 Driver unit
 官方给出了三个特点
 Can't error out
 Observe on main scheduler
 Sharing side effects (shareReplayLatestWhileConnected)
 简单的理解就是 Driver 增加了三个限制：
 
 不能调用 onError
 工作在主线程
 默认调用了 shareReplayLatestWhileConnected()，类似于调用了 shareReplay(1)
 官方在 GitHubSignup 对 Observable 和 Driver 各给出了一种例子。您可以去看其中的例子，对比使用上不同的感受。
 
 实际上二者还有一些其他区别：
 
 Observable 是 class ，Driver`` 是struct，Driver内部持有一个Observable`
 Driver 没有类似 create 的创建方法
 Driver 仅有 zip combineLatest empty never just deferred of interval timer map filter switchLatest flatMapLatest flatMapFirst distinctUntilChanged flatMap merge throttle debounce scan concat withLatestFrom skip startWith ，即没有 buffer window takeLast 等操作符，笔者认为没有实现的原因应该是考虑到这些操作符在主线程工作会存在一些性能问题。

*/
import UIKit
import RxSwift
import RxCocoa
import SnapKit
import CoreLocation
import MapKit


class WeatherSearchViewController: BaseViewController,UITextFieldDelegate {

    private var mapView: MKMapView = {
        let m = MKMapView()
        return m
    }()
    private var mapButton: UIButton = {
        let b = UIButton()
        b.setImage(UIImage(named:"map"), for: .normal)
        //        b.addTarget(self, action: #selector(geoClick), for: .touchUpInside)
        return b
    }()
    private var geoLocationButton: UIButton = {
        let b = UIButton()
        b.setImage(UIImage(named:"place-location"), for: .normal)
//        b.addTarget(self, action: #selector(geoClick), for: .touchUpInside)
        return b
    }()
    private var activityIndicator: UIActivityIndicatorView = {
        return UIActivityIndicatorView(activityIndicatorStyle:UIActivityIndicatorViewStyle.whiteLarge)
    }()
    
    
    private var searchCityName: UITextField = {
        let x = UITextField()
//        x.borderStyle = UITextBorderStyle.roundedRect
        x.font = UIFont.boldSystemFont(ofSize: 32)
        x.returnKeyType = UIReturnKeyType.search
        return x
    }()
    
    private var tempLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 24)
        l.text = "T"
        l.textAlignment = .center
        return l
    }()
    
    private var humidityLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 24)
        l.text = "H"
        l.textAlignment = .center
        return l
    }()
    
    private var iconLabel: UILabel = {
        let l = UILabel()
        l.text = "W"
        l.textAlignment = .center
        l.font = UIFont.systemFont(ofSize: 100)
        return l
    }()
    
    private var cityNameLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 32)
        l.text = "C"
        l.textAlignment = .center
        return l
    }()
    
    let bag = DisposeBag()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addUI()
        
        
        //MARK: - Part 1
//        part1()
//
//
//        //MARK: - Part 2
//        part2()
//
//
//        //MARK: - Part 3
//        part3()
//
//
//        //MARK: - Part 4
//        part4()
//
//        //MARK: - Part 5
//        part5()
//
//        //MARK: - Part 6
//        //点击事件
//        part6()
        
        //MARK: - Part 7
        let currentLocation = locationManager.rx.didUpdateLocations.map{locations in
            return locations[0]
            }.filter{location in
                return location.horizontalAccuracy < kCLLocationAccuracyHundredMeters
        }
        let geoInput = geoLocationButton.rx.tap
            .asObservable()
            .do(onNext: {
            self.locationManager.requestWhenInUseAuthorization()
            self.locationManager.startUpdatingLocation()
        })
        let geoLocation = geoInput.flatMap{
            return currentLocation.take(1)
        }
        let geoSearch = geoLocation.flatMap{ location in
            return WeatherApi.shared.currentWeather(lat: location.coordinate.latitude, lon: location.coordinate.longitude)
            .catchErrorJustReturn(WeatherApi.Weather.dummy)
        }
        let searchInput = searchCityName.rx.controlEvent(UIControlEvents.editingDidEndOnExit).asObservable()
                    .map{
                        self.searchCityName.text
                    }.filter { (text) -> Bool in
                        return (text ?? "").count > 0
                }
        let textSearch = searchInput.flatMap{ text in
                        return WeatherApi.shared.currentWeather(city: text ?? "Error")
                        .catchErrorJustReturn(WeatherApi.Weather.dummy)
                    }
        
        let mapInput = mapView.rx.regionDidChangeAnimated
            .skip(1)
            .map { _ in self.mapView.centerCoordinate }
        
        let mapSearch = mapInput.flatMap { coordinate in
            return WeatherApi.shared.currentWeather(lat: coordinate.latitude, lon: coordinate.longitude)
                .catchErrorJustReturn(WeatherApi.Weather.dummy)
        }
        
        let search = Observable
            .from([geoSearch,textSearch,mapSearch])
            .merge().asDriver(onErrorJustReturn: WeatherApi.Weather.dummy)
        
        let running = Observable.from([
            searchInput.map { _ in true },
            geoInput.map { _ in true },
            mapInput.map { _ in true},
            search.map { _ in false }.asObservable()
            ]).merge()
            .startWith(true)
            .asDriver(onErrorJustReturn: false)
        
        running
            .skip(1)
            .drive(activityIndicator.rx.isAnimating)
            .disposed(by: bag)

        running
            .drive(tempLabel.rx.isHidden)
            .disposed(by: bag)
        running
            .drive(iconLabel.rx.isHidden)
            .disposed(by: bag)
        running
            .drive(humidityLabel.rx.isHidden)
            .disposed(by: bag)
        running
            .drive(cityNameLabel.rx.isHidden)
            .disposed(by: bag)
        
        search.map { "\($0.temperature)° C" }
            .drive(tempLabel.rx.text)
            .disposed(by: bag)
        
        search.map { $0.icon }
            .drive(iconLabel.rx.text)
            .disposed(by: bag)
        
        search.map { "\($0.humidity)%" }
            .drive(humidityLabel.rx.text)
            .disposed(by: bag)
        
        search.map { $0.cityName }
            .drive(cityNameLabel.rx.text)
            .disposed(by: bag)
     
        //MARK:part7
        mapButton.rx.tap.subscribe(onNext:{
            self.mapView.isHidden = !self.mapView.isHidden
        }).disposed(by: bag)
        
        mapView.rx.setDelegate(self as! MKMapViewDelegate)
            .disposed(by: bag)
        
        search.map { [$0.overlay()] }
            .drive(mapView.rx.overlays)
            .disposed(by: bag)
    }

    func addUI() {
        
        view.addSubview(mapView)
        view.addSubview(searchCityName)
        view.addSubview(tempLabel)
        view.addSubview(humidityLabel)
        view.addSubview(iconLabel)
        view.addSubview(cityNameLabel)
        view.addSubview(activityIndicator)
        view.addSubview(geoLocationButton)
        view.addSubview(mapButton)
        
        
        
        searchCityName.snp.makeConstraints { (make) in
            make.top.equalTo(64+16)
            make.left.equalTo(16)
            make.right.equalTo(-16)
        }
        
        iconLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.left.equalTo(40)
            make.width.equalTo(iconLabel.snp.height).multipliedBy(1)
        }
        
        cityNameLabel.snp.makeConstraints { (make) in
            make.width.equalTo(iconLabel.snp.width)
            make.centerX.equalToSuperview()
            make.top.equalTo(iconLabel.snp.bottom).offset(8)
        }
        tempLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(iconLabel.snp.top).offset(-8)
            make.left.equalTo(iconLabel.snp.left)
        }
        humidityLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(iconLabel.snp.top).offset(-8)
            make.right.equalTo(iconLabel.snp.right)
        }
        activityIndicator.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        geoLocationButton.snp.makeConstraints { (make) in
            make.width.height.equalTo(44)
            make.bottom.equalTo(view.snp.bottom).offset(-20)
            make.left.equalTo(view.snp.left).offset(20)
        }
        mapButton.snp.makeConstraints { (make) in
            make.width.height.equalTo(44)
            make.bottom.equalTo(view.snp.bottom).offset(-20)
            make.right.equalTo(view.snp.right).offset(-20)
        }
        mapView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(searchCityName.snp.bottom).offset(20)
        }
        
        style()
    }
    func part1()  {
        searchCityName.rx.text
            .filter{ ($0 ?? "").count > 0}
            .flatMap { (text) in
                return WeatherApi.shared.currentWeather(city: text ?? "Error").catchErrorJustReturn(WeatherApi.Weather.empty)}
            .observeOn(MainScheduler.instance)
            .subscribe(onNext:{ (data) in
                self.tempLabel.text = "\(data.temperature) ° C"
                self.iconLabel.text = data.icon
                self.cityNameLabel.text = data.cityName
                self.humidityLabel.text = "\(data.humidity)%"
            }).disposed(by: bag)
    }
    
    
    func part2()  {
        let search = searchCityName.rx.text
          .filter { ($0 ?? "").count > 0 }
          .flatMapLatest { text in
            return WeatherApi.shared.currentWeather(city: text ?? "Error")
              .catchErrorJustReturn(WeatherApi.Weather.empty)
          }.observeOn(MainScheduler.instance)
    
    
        search.map { "\($0.temperature)° C" }
          .bind(to:tempLabel.rx.text)
          .disposed(by:bag)
    
        search.map { $0.icon }
          .bind(to:iconLabel.rx.text)
          .disposed(by:bag)
    
        search.map { "\($0.humidity)%" }
          .bind(to:humidityLabel.rx.text)
          .disposed(by:bag)
    
        search.map { $0.cityName }
          .bind(to:cityNameLabel.rx.text)
          .disposed(by:bag)
    }
    
    func part3()  {
        
        let search = searchCityName.rx.text
          .filter { ($0 ?? "").count > 0 }
          .flatMap { text in
            return WeatherApi.shared.currentWeather(city: text ?? "Error")
              .catchErrorJustReturn(WeatherApi.Weather.empty)
          }.asDriver(onErrorJustReturn: WeatherApi.Weather.empty)
    
        search.map { "\($0.temperature)° C" }
          .drive(tempLabel.rx.text)
          .disposed(by:bag)
    
        search.map { $0.icon }
          .drive(iconLabel.rx.text)
          .disposed(by:bag)
    
        search.map { "\($0.humidity)%" }
          .drive(humidityLabel.rx.text)
          .disposed(by:bag)
    
        search.map { $0.cityName }
          .drive(cityNameLabel.rx.text)
          .disposed(by:bag)
    }
    
    func part4()  {
        
        WeatherApi.shared.currentWeather(city: "RxSwift")
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { data in
                self.tempLabel.text = "\(data.temperature)° C"
                self.iconLabel.text = data.icon
                self.humidityLabel.text = "\(data.humidity)%"
                self.cityNameLabel.text = data.cityName
            })
            .disposed(by:bag)

        let search = searchCityName.rx.controlEvent(.editingDidEndOnExit).asObservable()
            .map { self.searchCityName.text }
            .filter { ($0 ?? "").count > 0 }
            .flatMapLatest { text in
                return WeatherApi.shared.currentWeather(city: text ?? "Error")
                    .catchErrorJustReturn(WeatherApi.Weather.empty)
            }
            .asDriver(onErrorJustReturn: WeatherApi.Weather.empty)

        search.map { "\($0.temperature)° C" }
            .drive(tempLabel.rx.text)
            .disposed(by:bag)

        search.map { $0.icon }
            .drive(iconLabel.rx.text)
            .disposed(by:bag)

        search.map { "\($0.humidity)%" }
            .drive(humidityLabel.rx.text)
            .disposed(by:bag)

        search.map { $0.cityName }
            .drive(cityNameLabel.rx.text)
            .disposed(by:bag)
    }
    
    
    func part5(){
        let searchInput = searchCityName.rx.controlEvent(UIControlEvents.editingDidEndOnExit).asObservable()
            .map{
                self.searchCityName.text
            }.filter { (text) -> Bool in
                return (text ?? "").count > 0
        }

        let search = searchInput.flatMap{ text in
            return WeatherApi.shared.currentWeather(city: text ?? "Error")
            .catchErrorJustReturn(WeatherApi.Weather.dummy)
        }.asDriver(onErrorJustReturn: WeatherApi.Weather.dummy)

        let running = Observable.from([searchInput.map{_ in true},
                                       search.map{_ in false}.asObservable()
        ]).merge()
        .startWith(true)
        .asDriver(onErrorJustReturn: false)

        running
            .skip(1)
            .drive(activityIndicator.rx.isAnimating)
            .disposed(by: bag)

        running
            .drive(tempLabel.rx.isHidden)
            .disposed(by: bag)
        running
            .drive(iconLabel.rx.isHidden)
            .disposed(by: bag)
        running
            .drive(humidityLabel.rx.isHidden)
            .disposed(by: bag)
        running
            .drive(cityNameLabel.rx.isHidden)
            .disposed(by: bag)

        search.map { "\($0.temperature)° C" }
            .drive(tempLabel.rx.text)
            .disposed(by: bag)

        search.map { $0.icon }
            .drive(iconLabel.rx.text)
            .disposed(by: bag)

        search.map { "\($0.humidity)%" }
            .drive(humidityLabel.rx.text)
            .disposed(by: bag)

        search.map { $0.cityName }
            .drive(cityNameLabel.rx.text)
            .disposed(by: bag)
    }
    func part6(){
        geoLocationButton.rx.tap.subscribe(onNext:{_ in
          self.locationManager.requestWhenInUseAuthorization()
          self.locationManager.startUpdatingLocation()
        }).disposed(by: bag)

        //订阅
        locationManager.rx.didUpdateLocations.subscribe(onNext:{ locations in
          print(locations)
        }).disposed(by: bag)
        
    }
    
    func part7(){
       
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        Appearance.applyBottomLine(to: searchCityName)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func style(){
        view.backgroundColor = UIColor.aztec
        searchCityName.textColor = UIColor.ufoGreen
        tempLabel.textColor = UIColor.cream
        humidityLabel.textColor = UIColor.cream
        iconLabel.textColor = UIColor.cream
        cityNameLabel.textColor = UIColor.cream
    }
    
    
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let overlay = overlay as? WeatherApi.Weather.Overlay {
            let overlayView = WeatherApi.Weather.OverlayView(overlay: overlay, overlayIcon: overlay.icon)
            return overlayView
        }
        return MKOverlayRenderer()
    }
}

