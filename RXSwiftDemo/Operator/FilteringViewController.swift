//
//  FilteringViewController.swift
//  RXSwiftDemo
//
//  Created by iMac on 2018/1/20.
//  Copyright © 2018年 iMac. All rights reserved.
//

import UIKit
import RxSwift

class FilteringViewController: BaseViewController {

    enum myError:Error {
        case anError
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //ignoreElements 不会收到.next事件
        //用于:当你只关心事件的终止,即只会收到.completed或者.error事件
        //该操作会屏蔽所有的 next 事件，只会将注意力放在 error 和 completed 事件上
        example(of: "ignoreElements") {
            
            let strikes = PublishSubject<String>()
            
            let dispose = DisposeBag()
            
            //订阅所有的事件,但是忽略.next
            strikes.ignoreElements()
                .subscribe({ (event) in
                print(event)
                print("You're out!")
            }).disposed(by: dispose)
            
            strikes.on(.next("next"))
            strikes.onNext("next1")
            strikes.onCompleted()
    
        }
        
        //只会收到下标(index)发射的element 从0开始
        //若未到指定的index已经终止,则会收到error(Argument out of range.)
        //通过 elementAt 对特定索引号 next 进行过滤
        example(of: "elementAt") {
            let strikes = PublishSubject<String>()
            
            let disposeBag = DisposeBag()
            
            strikes.elementAt(1)
                .subscribe({ event in
                print(event)
            }).disposed(by: disposeBag)
            
            strikes.onNext("1")
            strikes.onNext("X")
            strikes.onNext("2")
            strikes.onNext("3")
            strikes.onCompleted()
            
        }
        
        //filter 通过一个控制条件来对element进行过滤
        //上面两个操作最后针对的 next 事件最多只会有一个，但是大多数时候我们其实需要筛选出一组符合条件的 next 事件。下图演示的就是使用 filter 筛选数据偶数的操作。
        example(of: "filter") {
            
            let disposeBag = DisposeBag()
            
            Observable.of(1,2,3,4,5,6)
                .filter({ (integer) -> Bool in
                integer % 2 == 0
            }).subscribe(onNext:{
                print($0)
            }).disposed(by: disposeBag)
        }
        
        //skip 跳过几个element
        //除了忽略操作外，另一个常见的过滤就是跳过操作了。在所有的跳过操作中，最简单的就属 skip 了。通过设定参数，我们就能和简单实现跳过指定个数的事件。例如，下图久演示跳过前两个事件的操作。
        

        example(of: "skip") {
            
            let disposeBag = DisposeBag()
            
            Observable.of("A","B","C","D","E","F")
                .skip(2)
                .subscribe(onNext:{
                print($0)
            }).disposed(by: disposeBag)
        }
        
        //skipWhile 通过控制条件,就相当于一个阀值,当控制条件返回false,就开始接收element
        //当然除了跳过指定索引号的事件之外，我们依旧通过 skipWhile 我们能够实现类似 filter 类似的操作。只不过 filter 会过滤整个生命周期内的符合条件的事件，而 skipWhile 在找到第一个不符合跳过操作的事件之后就不再工作。例如，下图 skipWhile 的条件是数据为奇数就跳过，但是当数据 2 执行之后 数据 3 虽然也是奇数但是不会在跳过。所以严格意义上来说 skipWhile 可能有点歧义，实际是它会跳过所有符合条件的事件，直到找到第一个能执行事件后就不再生效。
        example(of: "skipWhile") {
            let disposeBag = DisposeBag()
            
            //3 4 4
            Observable.of(2,2,3,4,4)
                .skipWhile({ (integer) -> Bool in
                return integer  % 2 == 0
            }).subscribe(onNext:{
                print($0)
            }).disposed(by: disposeBag)
        }
        
        //skipUntil 总是跳过直到另一个Observable发出.next(.completed,.error都不可以),即通过Observable动态的控制数据的接收
        //如果现在你需要根据其它可观察对象实例的行为进行过滤判断怎么办呢？所以接下来将会介绍涉及多实例的动态判断，其中最常见的就是 skipUntil 操作。该操作过程如下图，上面两行表示可观察对象的生命周期而最下面的表示观察者，直到第二行的可观察对象发送数据后第三行的观察者才能接受到第一行发送的数据。
        example(of: "skipUntil") {
            
            let disposeBag = DisposeBag()
            
            let subject = PublishSubject<String>()
            let trigger = PublishSubject<String>()
            
            subject.skipUntil(trigger)
                .subscribe(onNext:{
                print($0)
            }).disposed(by: disposeBag)
            
            subject.onNext("A")
            subject.on(.next("B"))
            
            //trigger.onCompleted()
            //trigger.onError(myError.anError)
            trigger.onNext("trigger:C") //开始接收
            
            subject.on(.next("D"))
            
            //并不代表终止
            trigger.onCompleted()
            
            subject.onNext("E")
            
        }
        
        //take 取值 取最开始的几个element
        //最基础的操作为 take ，该操作的过程完全与 skip 相反
        example(of: "take") {
            
            let disposeBag = DisposeBag()
            
            // 1 2
            Observable.of(1,2,3,4,5,6)
                .take(2)
                .subscribe(onNext:{
                print($0)
            }).disposed(by:disposeBag)
            
        }
        
        //类似于skipWhile 表示的意思为取值直到控制条件不成立
        example(of: "takeWhile") {
            
            let disposeBag = DisposeBag()
            
            Observable.of(2,2,4,4,6,6)
                .enumerated()
                .takeWhile({ (index,value) -> Bool in
                    value % 2 == 0 && index < 3
                }).map({ $0.element
                }).subscribe(onNext:{
                    print($0)
                }).disposed(by: disposeBag)
        }
        
        //失效
        //函数名已经表明了该操作的主要功能，在 takeWhile 的基础上会加上索引 index 参数。因为有时候我们除了需要通过 value 进行过滤判断外，索引 index 也可能是一个判断维度。下图就展示了 takeWhileWithIndex 简单使用示例，对于 value 和 index 值小于 1 的事件全部跳过。
        example(of: "takeWhileIndex") {
            
            let disposeBag = DisposeBag()
            let strikes = PublishSubject<Int>()
            
            strikes.takeWhileWithIndex({ (value, index) -> Bool in
                
               return value > 1 && index > 1
            }).subscribe(onNext:{
                print($0)
            }).disposed(by: disposeBag)
            
            strikes.onNext(1)
            strikes.onNext(2)
            strikes.onNext(3)
            
            strikes.onCompleted()

        }
        
        
        //takeUntil 同skipUntil 即接收element直到observable发送.next或者.error (.completed,无效)
        //直到另一个实例对象触发后该实例对象的观察者才会停止响应。
        example(of: "takeUntil") {
            
            let disposeBag = DisposeBag()
            
            let subject = PublishSubject<String>()
            let trigger = PublishSubject<String>()
            
            subject.takeUntil(trigger)
                .subscribe(onNext:{
                    print($0)
                }).disposed(by:disposeBag)
            
            subject.onNext("A")
            subject.onNext("B")
            
            //trigger.onCompleted()
            //trigger.onError(myError.anError) //停止接收
            
            trigger.onNext("1") //停止接收
            subject.onNext("C")
            
            subject.onCompleted()
        }
        
        //只有当此次element和上次不一样订阅者才会收到通知
        //判断是否一样是根据Equable来辨别的
        
        //对于观察者来说，有时可观察对象可能在某段时间内连续发生相同的数据。假设这些数据与 UI 相关的话，那么这里就存在不必要的刷新操作了。所以我们有必要对过滤这些连续的相同数据，减少不必要的响应操作
        example(of: "distinctUntilChanged") {
            
            let disposeBag = DisposeBag()
            
            Observable.of("A","A","B","B","A")
                .distinctUntilChanged()
                .subscribe(onNext:{
                    print($0)
                }).disposed(by: disposeBag)
            
        }
        
        example(of: "distinctUntilChanged(_ :)") {
            let disposeBag = DisposeBag()
            
            let formatter = NumberFormatter()
            formatter.numberStyle = .spellOut
            
            Observable<NSNumber>.of(10,110,20,200,210,310)
                .distinctUntilChanged{ a,b in
                    guard let aWords = formatter.string(from: a)?.components(separatedBy: " "),
                        let bWords = formatter.string(from: b)?.components(separatedBy: " ")else{
                            return false
                    }
                    var containsMatch = false
                    for aWord in aWords{
                        for bWord in bWords{
                            if aWord == bWord{
                                containsMatch = true
                                break
                            }
                        }
                    }
                    return containsMatch
                }.subscribe(onNext:{
                    print($0)
                }).disposed(by:disposeBag)
            
        }
        
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
