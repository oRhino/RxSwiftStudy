//
//  SubjectViewController.swift
//  RXSwiftDemo
//
//  Created by iMac on 2018/1/17.
//  Copyright © 2018年 iMac. All rights reserved.
//

import UIKit
import RxSwift

//Subject:observable and as an observer
/*
• PublishSubject: Starts empty and only emits new elements to subscribers.
• BehaviorSubject: Starts with an initial value and replays it or the latest element to new subscribers.
• ReplaySubject: Initialized with a buffer size and will maintain a buffer of elements up to that size and replay it to new subscribers.
• Variable: Wraps a BehaviorSubject, preserves its current value as state, and replays only the latest/initial value to new subscribers.
*/
class SubjectViewController: BaseViewController {
    
    public let cards = [
        ("🂡", 11), ("🂢", 2), ("🂣", 3), ("🂤", 4), ("🂥", 5), ("🂦", 6), ("🂧", 7), ("🂨", 8), ("🂩", 9), ("🂪", 10), ("🂫", 10), ("🂭", 10), ("🂮", 10),
        ("🂱", 11), ("🂲", 2), ("🂳", 3), ("🂴", 4), ("🂵", 5), ("🂶", 6), ("🂷", 7), ("🂸", 8), ("🂹", 9), ("🂺", 10), ("🂻", 10), ("🂽", 10), ("🂾", 10),
        ("🃁", 11), ("🃂", 2), ("🃃", 3), ("🃄", 4), ("🃅", 5), ("🃆", 6), ("🃇", 7), ("🃈", 8), ("🃉", 9), ("🃊", 10), ("🃋", 10), ("🃍", 10), ("🃎", 10),
        ("🃑", 11), ("🃒", 2), ("🃓", 3), ("🃔", 4), ("🃕", 5), ("🃖", 6), ("🃗", 7), ("🃘", 8), ("🃙", 9), ("🃚", 10), ("🃛", 10), ("🃝", 10), ("🃞", 10)
    ]
    
    public func cardString(for hand: [(String, Int)]) -> String {
        return hand.map { $0.0 }.joined(separator: "")
    }
    
    public func points(for hand: [(String, Int)]) -> Int {
        return hand.map { $0.1 }.reduce(0, +)
    }
    
    public enum HandError: Error {
        case busted
    }
    
    
    // 1
    enum MyError:String,Error{
        case anError
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()

        //MARK:PublishSubject
        example(of: "PublishSubject") {
            
            
            let subject = PublishSubject<String>()
            subject.onNext("Is anyone listening?")
            
            //添加一个订阅者
            let subscriptionOne = subject
                .subscribe(onNext: { string in
                    print(string)
                })
            //发送数据
            subject.on(.next("1"))
            subject.onNext("2")
            
            //第二个订阅者
            let subscriptionTwo = subject
                .subscribe { event in
                    print("2)", event.element ?? event)
            }
            
            subject.onNext("3")
            //销毁第一个订阅者
            subscriptionOne.dispose()
            
            subject.onNext("4")
            
            // 1 发送完成将不能再发送任何数据了,表示终止
            subject.onCompleted()
            
            // 2
            subject.onNext("5")
            
            // 3
            subscriptionTwo.dispose()
            
            let disposeBag = DisposeBag()
            
            // 4
            subject
                .subscribe {
                    print("3)", $0.element ?? $0)
                }
                .disposed(by: disposeBag)
            
            subject.onNext("?")
            
        }
        
        
        
        
        
        // MARK:BehaviorSubject
        //Behavior subjects work similarly to publish subjects, except they will replay the latest .next event to new subscribers.
        //初始化根据一个实例化的值,可以订阅到订阅前最后一次(即上次)所发送的数据
        //新的订阅者总是会收到上一个.next
        //如果在订阅之前,没有发生.next,订阅者将会收到实例化对象的时候传入的值
        example(of: "BehaviorSubject") {

            // 4
            let subject = BehaviorSubject(value: "Initial value")

            let disposeBag = DisposeBag()
//            subject.onNext("X1")
//            subject.onNext("X2")
            
            subject
                .subscribe {[weak self] in
                    self?.prints(label: "1)", event: $0)
                }
                .disposed(by: disposeBag)

            subject.onNext("X3")
            
            // 1
            subject.onError(MyError.anError)

            // 2
            subject
                .subscribe {[weak self] in
                    self?.prints(label: "2)", event: $0)
                }
                .disposed(by: disposeBag)
        }

        //MARK:ReplaySubject
        //可以根据buffersize获取最近的相应的几条数据,订阅之前没有则不会有值传入
        example(of: "ReplaySubject") {

            // 1
            let subject = ReplaySubject<String>.create(bufferSize: 2)

            let disposeBag = DisposeBag()

            // 2
            subject.onNext("1")

            subject.onNext("2")

            subject.onNext("3")

            // 3
            subject
                .subscribe {[weak self] in
                    self?.prints(label: "1)", event: $0)
                }
                .disposed(by: disposeBag)

            subject
                .subscribe {[weak self] in
                    self?.prints(label: "2)", event: $0)
                }
                .disposed(by: disposeBag)

            subject.onNext("4")
            subject.onError(MyError.anError)
            subject.dispose()

            //已经被disposed
            subject
                .subscribe {[weak self] in
                    self?.prints(label: "3)", event: $0)
                }
                .disposed(by: disposeBag)
        }

        //MARK:Variable
        //no way to add an .error or .completed event onto a variable
        //其实就是对BehaviorSubject进行了一次包装,每次对value进行赋值,则根据这个value新建一个BehaviorSubject的实例对象
        //asObservable()  -> behavior subject ||| asObservable()就是获取这个BehaviorSubject对象
        
        example(of: "Variable") {

            // 1
            let variable = Variable("Initial value")

            let disposeBag = DisposeBag()

            // 2
            variable.value = "New initial value1"

            variable.value = "New initial value2"
            
            // 3
            variable.asObservable()
                .subscribe {[weak self] in
                    self?.prints(label: "1)", event: $0)
                }
                .disposed(by: disposeBag)

            // 1
            variable.value = "1"

            variable.value = MyError.anError.rawValue
            // 2
            variable.asObservable()
                .subscribe {[weak self] in
                    self?.prints(label: "2)", event: $0)
                }
                .disposed(by: disposeBag)

            // 3
            variable.value = "2"
            
        }
        
        
    }

    // 2
    func prints<T: CustomStringConvertible>(label: String, event: Event<T>) {
        print(label,event.element ?? event.error ?? event)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

