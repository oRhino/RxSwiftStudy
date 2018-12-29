//
//  CombiningViewController.swift
//  RXSwiftDemo
//
//  Created by iMac on 2018/1/20.
//  Copyright © 2018年 iMac. All rights reserved.
//

import UIKit
import RxSwift


class CombiningViewController: BaseViewController {

    enum MyError:Error {
        case aError
    }
    
    let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //在Observable释放元素之前，发射指定的元素序列.
        //startWith 操作符会在 Observable 头部插入一些元素。(如果你想在尾部加入一些元素可以用concat）
        example(of: "startWith") {
            // 1
            let numbers = Observable.of(2, 3, 4)
            
            // 2 先进后出,后添加的startWith最先被发射
            _ = numbers.startWith(1,21,31).startWith(11).startWith(22).subscribe(onNext: { value in
                print(value)
            }).dispose()
//            22
//            11
//            1
//            21
//            31
//            2
//            3
//            4
        }

        
        //让两个或多个Observables按顺序串连起来
        //concat操作符将多个Observables按顺序串联起来，当前一个Observable元素发送完毕后，后一个 Observable 才可以开始发出元素。
        //concat将等待前一个Observable产生完成事件后，才对后一个Observable进行订阅。如果后一个是“热” Observable
        //在它前一个Observable产生完成事件前，所产生的元素将不会被发送出来。
        example(of: "Observable.concat") {
            // 1
            let first = Observable.of(1, 2, 3)
            let second = Observable.of(4, 5, 6)
            
            // 2
            let observable = Observable.concat([first, second])
            
            observable.debug().subscribe(onNext: { value in
                print(value)
            }).dispose()
            //1,2,3,4,5,6
        }
        
        example(of: "concat") {
            let germanCities = Observable.of("Berlin", "Munich", "Frankfurt")
            let spanishCities = Observable.of("Madrid", "Barcelona", "Valencia")
            
            let observable = germanCities.concat(spanishCities)
            observable.subscribe(onNext: { value in
                print(value)
            }).dispose()
//            Berlin
//            Munich
//            Frankfurt
//            Madrid
//            Barcelona
//            Valencia
        }
        
        example(of: "Concat~~~") {
            
            let subject1 = BehaviorSubject(value: "🐶")
            let subject2 = BehaviorSubject(value: "🍎")
            
            Observable.concat([subject1,subject2]).subscribe(onNext:{
                print($0)
            }).disposed(by: bag)
            print("1")
            subject1.onNext("🍑")
            print("2")
            subject2.onNext("👩")
            //直到subject1发送完成 才可以接收subject2发送的事件,之前发送的事件将会被忽略
            subject1.onCompleted()
            print("3")
            subject2.onNext("开始可以订阅到事件 ")
            subject2.onCompleted()
//            🐶
//            1
//            🍑
//            2
//            👩
//            3
//            开始可以订阅到事件
        }
        
        //将Observable的元素转换成其他的Observable，然后将这些Observables串连起来
        //concatMap操作符将源Observable的每一个元素应用一个转换方法，将他们转换成Observables。
        //然后让这些Observables按顺序的发出元素，当前一个Observable元素发送完毕后，后一个Observable才可以开始发出元素。
        //等待前一个Observable产生完成事件后,才对后一个 Observable 进行订阅。
        
        example(of: "concatMap") {
            // 1
            let sequences = [
                "Germany": Observable.of("Berlin", "Münich", "Frankfurt"),
                "Spain": Observable.of("Madrid", "Barcelona", "Valencia")
            ]
            
            // 2
            let observable = Observable.of("Germany", "Spain")
                .concatMap { country in
                    sequences[country] ?? .empty()
            }
            // 3
            _ = observable.subscribe(onNext: { string in
                print(string)
            })
            
        }
        
        example(of: "ConcatMap~~") {
            
            let subject1 = BehaviorSubject(value: "🍎")
            let subject2 = BehaviorSubject(value: "🚴")
            
            let variable = Variable(subject1)
            
            variable.asObservable().concatMap{$0}.subscribe(onNext:{
                print($0)
            }).disposed(by: bag)
            
            print("1")
            subject1.onNext("🌰")
            subject1.onNext("🍐")
            
            variable.value = subject2
            
            subject2.onNext("I would be ignored")
            
            subject2.onNext("🐱")
            
            subject1.onCompleted()
            
            subject2.onNext("🐀")
            
        }
        
        //将多个Observable组合成单个Observable,并且按照时间顺序发射对应事件
        example(of: "merge") {
            // 1
            let left = PublishSubject<String>()
            let right = PublishSubject<String>()
            
            // 2
            let source = Observable.of(left.asObservable(), right.asObservable())
            
            // 3
            let observable = source.merge()
            let disposable = observable.subscribe(onNext: { value in
                print(value)
            })
            
            // 4
            var leftValues = ["Berlin", "Munich", "Frankfurt"]
            var rightValues = ["Madrid", "Barcelona", "Valencia"]
            
            repeat {
                if arc4random_uniform(2) == 0 {
                    if !leftValues.isEmpty {
                        left.onNext("Left:  " + leftValues.removeFirst())
                    }
                } else if !rightValues.isEmpty {
                    right.onNext("Right: " + rightValues.removeFirst())
                }
            } while !leftValues.isEmpty || !rightValues.isEmpty
            
            // 5
            disposable.dispose()
        }

        
        //combineLatest 操作符将多个 Observables 中最新的元素通过一个函数组合起来，然后将这个组合的结果发出来。
        //这些源 Observables 中任何一个发出一个元素，他都会发出一个元素（前提是:这些 Observables曾经发出过元素)
        example(of: "combineLatest") {
            let left = PublishSubject<String>()
            let right = PublishSubject<String>()
            
            // 1
            let observable = Observable
                .combineLatest(left, right, resultSelector: {
                lastLeft, lastRight in
                "\(lastLeft) \(lastRight)"
            })
            let disposable = observable.subscribe(onNext: { value in
                print(value)
            })
            
            // 2
            print("> Sending a value to Left")
            left.onNext("Hello,")
            print("> Sending a value to Right")
            right.onNext("world")
            print("> Sending another value to Right")
            right.onNext("RxSwift")
            print("> Sending another value to Left")
            left.onNext("Have a good day,")
//            > Sending a value to Left
//            > Sending a value to Right
//            Hello, world
//            > Sending another value to Right
//            Hello, RxSwift
//            > Sending another value to Left
//            Have a good day, RxSwift
            disposable.dispose()
        }
        
        example(of: "combine user choice and value") {
            //02/02/2018
            //2 February 2018
            let choice : Observable<DateFormatter.Style> = Observable.of(.short, .long)
            let dates = Observable.of(Date())
            
            let observable = Observable
                .combineLatest(choice, dates) {
                (format, when) -> String in
                let formatter = DateFormatter()
                formatter.dateStyle = format
                return formatter.string(from: when)
            }
            
            observable.subscribe(onNext: { value in
                print(value)
            }).dispose()
        }
        
        //将多个Observable(注意：必须是要成对)组合成单个Observable，当有事件到达时，会在每个序列中对应的索引上对应的元素发出
        example(of: "zip") {
            enum Weather {
                case cloudy
                case sunny
            }
            let left: Observable<Weather> = Observable.of(.sunny, .cloudy, .cloudy, .sunny)
            let pre = Observable.of(1,2,3,4)
            let right = Observable.of("Lisbon", "Copenhagen", "London", "Madrid", "Vienna")
            
            let observable = Observable.zip(pre,left, right) { pre, weather, city in
                return "\(pre) It's \(weather) in \(city)"
            }
            observable.subscribe(onNext: { value in
                print(value)
            }).dispose()
           // 1 It's sunny in Lisbon
           // 2 It's cloudy in Copenhagen
           // 3 It's cloudy in London
           // 4 It's sunny in Madrid
        }
        
        example(of: "withLatestFrom") {
            // 1
            let button = PublishSubject<Void>()
            let textField = PublishSubject<String>()
            
            // 2
            let observable = textField.sample(button)
            _ = observable.subscribe(onNext: { value in
                print(value)
            })
            
            // 3
            textField.onNext("Par")
            textField.onNext("Pari")
            textField.onNext("Paris")
            button.onNext(())
            button.onNext(())
        }
        
        example(of: "amb") {
            let left = PublishSubject<String>()
            let right = PublishSubject<String>()
            
            // 1
            let observable = left.amb(right)
            let disposable = observable.subscribe(onNext: { value in
                print(value)
            })
            
            // 2
            left.onNext("Lisbon")
            right.onNext("Copenhagen")
            left.onNext("London")
            left.onNext("Madrid")
            right.onNext("Vienna")
            
            disposable.dispose()
        }
        
        //切换序列
        example(of: "switchLatest") {
            // 1
            let one = PublishSubject<String>()
            let two = PublishSubject<String>()
            let three = PublishSubject<String>()
            
            let source = PublishSubject<Observable<String>>()
            
            // 2
            let observable = source.switchLatest()
            let disposable = observable.subscribe(onNext: { value in
                print(value)
            })
            
            // 3
            source.onNext(one)
            one.onNext("Some text from sequence one")
            //不会收到
            two.onNext("Some text from sequence two")
            
            source.onNext(two)
            two.onNext("More text from sequence two")
            one.onNext("and also from sequence one")
            
            source.onNext(three)
            //
            two.onNext("Why don't you seem me?")
            one.onNext("I'm alone, help me")
            //
            three.onNext("Hey it's three. I win.")
            
            source.onNext(one)
            one.onNext("Nope. It's me, one!")
            
            disposable.dispose()
        }
        
        example(of: "reduce") {
            let source = Observable.of(1, 3, 5, 7, 9)
            
            // 1
            let observable = source.reduce(0, accumulator: { summary, newValue in
                return summary + newValue
            })
            
            observable.subscribe(onNext: { value in
                print(value)
            }).dispose()
        }
        
        example(of: "scan") {
            let source = Observable.of(1, 3, 5, 7, 9)
            
            let observable = source.scan(0, accumulator: +)
            observable.subscribe(onNext: { value in
                print(value)
            }).dispose()
            
        }
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
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
