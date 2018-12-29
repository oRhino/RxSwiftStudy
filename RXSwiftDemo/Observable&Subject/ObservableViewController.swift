//
//  ObservableViewController.swift
//  RXSwiftDemo
//
//  Created by iMac on 2018/1/15.
//  Copyright © 2018年 iMac. All rights reserved.
//

import UIKit
import RxSwift


/****
 Observable(可被监听的序列) 负责产生事件
 在RX中,所有的事物都是序列
 
 创建Observable:
 1.自定义创建
 2.UI层
 
 <C>Observable
      |
 <P>ObservableType
 subscribe 订阅
      |
 <P>ObservableConvertibleType
 Observable -> Observer 可观察序列转换为观察者
 
 
 
 
 1.just 只产生一个Element
 2.from 将其它种类的对象和数据类型转换为Observable (将数组或sequence的数据取出然后逐个发射)
 3.of   根据序列Sequence进行发射
 4.never 
 5.empty
 6.range
 
 
 特征序列:
 Single
 Maybe
 Completable
 Driver
 ControlEvent
 */

class ObservableViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        //from 将其它种类的对象和数据类型转换为Observable (将数组或sequence的数据取出然后逐个发射)
        //just 创建一个发射指定值的Observable (只是简单的原样发射)
        //of
        example(of: "just, of, from") {
            // 1
            let one = 1
            let two = 2
            let three = 3
            
            // 2
            //可观察的实例对象
            let observable: Observable<Int> = Observable<Int>.just(one)
            //ObservableSequence
            let observable2 = Observable.of(one, two, three)
            let observable3 = Observable.of([one, two, three])
            let observable4 = Observable.from([one, two, three])
            
            print(observable)
            print(observable2)
            print(observable3)
            print(observable4)
        }
        
        example(of: "subscribe") {
            
            let one = 1
            let two = 2
            let three = 3
            
            let observable = Observable.of(one, two, three)
            // 1 2 3
            observable.subscribe(onNext: { element in
                print(element)
            }).dispose()
            
        }
        
        //创建一个不发射数据但是正常终止的Observable
        example(of: "empty") {
            //只会发送Completed
            let observable = Observable<Void>.empty()
            
            observable
                .subscribe(
                    // 1
                    onNext: { element in
                        print(element)
                },
                    // 2
                    onCompleted: {
                        print("Completed")
                }
            ).dispose()
        }
        
        //创建一个不发射数据也不终止的Observable
        example(of: "never") {
            //不会发出事件
            let observable = Observable<Any>.never()
            observable
                .subscribe(
                    onNext: { element in
                        print(element)
                },
                    onCompleted: {
                        print("Completed")
                }
            ).dispose()
        }
        
        //range 创建一个发射特定整数序列的Observable
        //发射一个范围内的有序整数序列,你可以指定范围的起始和长度
        example(of: "range") {
            // 1
            let observable = Observable<Int>.range(start: 2, count: 10)
            observable
                .subscribe(onNext: { i in
                    // 2
                    print(i)
//                    let n = Double(i)
//                    let fibonacci = Int(((pow(1.61803, n) - pow(0.61803, n)) /
//                        2.23606).rounded())
//                    print(fibonacci)
                }).dispose()
        }
        
        example(of: "dispose") {
            
            // 1
            let observable = Observable.of("A", "B", "C")
            
            // 2
            let subscription = observable.subscribe { event in
                
                // 3  next(A),next(B),next(C),completed
                print(event)
            }
            //回收资源 不是由ARC自动管理的
            subscription.dispose()
        }
        
        example(of: "DisposeBag") {
            // 1
            let disposeBag = DisposeBag()
            
            // 2 $0默认为第一个参数
            Observable.of("A", "B", "C")
                .subscribe { // 3
                    print($0)
                }
                .disposed(by: disposeBag) // 4
        }
        
        
        example(of: "create") {
            enum MyError: Error {
                case anError
            }
            //自定义观察序列
            //next
            //completed 导致序列终止
            //error     导致序列终止
            let disposeBag = DisposeBag()
            
            Observable<String>.create { observer in
                
                print(Thread.current)
                // 1
                observer.onNext("1")
                //observer.onError(MyError.anError)
                
                // 2
                //observer.onCompleted()
                
                // 3
                observer.onNext("?")
                
                // 4
                return Disposables.create()
                }
                .subscribe(
                    onNext: { print($0) },
                    onError: { print($0) },
                    onCompleted: { print("Completed") },
                    onDisposed: { print("Disposed") }
                )
                .disposed(by: disposeBag)
            
        }
        
        
        example(of: "deferred") {
            let disposeBag = DisposeBag()
            
            // 1
            var flip = false
            
            // 2 工厂
            //直到有订阅者才创建Observable,并且为每个观察者创建一个新的Observable
            let factory: Observable<Int> = Observable.deferred {
                // 3
                flip = !flip
                // Deferred会一直等待直到有订阅者订阅他,然后他使用Observable工厂方法生成一个Observable,它对每个观察者都这么做.因此尽管每个订阅者都以为自己订阅的
                //是同一个Observable,事实上每个订阅者获取的是他们自己的数据序列
                print("x")
                if flip {
                    return Observable.of(1, 2, 3)
                } else {
                    return Observable.of(4, 5, 6)
                }
            }
            
            
            for _ in 0...3 {
                factory.subscribe(onNext: {
                    print($0, terminator: "")
                }).disposed(by: disposeBag)
                print()
            }
         
            
        }
        
        
        //Traits:Single,Maybe,Completable
        //1.Single将会发射一个success(value) 或者error(Error)
        //success(value)实际上就是.next和.completed的组合
        //常用于单次操作的进程,成功发射.success(value),失败发射.error(Error),例如:下载数据,从磁盘读取文件内容
        //要么只能发出一个元素，要么产生一个 error 事件,发出一个元素，或一个 error 事件
        
        //2.Completable
        //只会发出一个.completed事件或者.error的事件,来表示事件的成功或者失败
        //例如:文件写入
        
        //3.Maybe是Completable和Single的mashup(混搭)
        //可以发出.completed,.error(Error),可选的发出.success(value)
        //适用于如果你需要实现一个成功或失败的操作，并且可选地返回成功的值.
        
        example(of: "Single") {
            // 1
            let disposeBag = DisposeBag()
            
            // 2
            enum FileReadError: Error {
                case fileNotFound, unreadable, encodingFailed
            }
            
            // 3
            func loadText(from filename: String) -> Single<String> {
                // 4
                return Single.create { single in
                    // 1
                    let disposable = Disposables.create()
                    
                    // 2 找不到文件路径
                    guard let path = Bundle.main.path(forResource: filename, ofType: "txt") else {
                        single(.error(FileReadError.fileNotFound))
                        return disposable
                    }
                    
                    // 3 读取内容失败
                    guard let data = FileManager.default.contents(atPath: path) else {
                        single(.error(FileReadError.unreadable))
                        return disposable
                    }
                    
                    // 4 编码失败
                    guard let contents = String(data: data, encoding: .utf8) else {
                        single(.error(FileReadError.encodingFailed))
                        return disposable
                    }
                    
                    // 5 成功
                    single(.success(contents))
                    
                    // 6
                    return disposable
                }
            }
            
            // 1
            loadText(from: "Copyright")
                // 2
                .subscribe {
                    // 3
                    switch $0 {
                        //成功
                    case .success(let string):
                        print(string)
                        //失败
                    case .error(let error):
                        print(error)
                    }
                }
                .disposed(by: disposeBag)
        }
    
        
        example(of: "JSON") {

            
            typealias JSON = Any
            
            let json:Observable<JSON> = Observable.create({ (observer) -> Disposable in
                
                let task = URLSession.shared.dataTask(with: URL(string: "https://www.showapi.com/api/testPageNew?apiCode=341&pointCode=1")!, completionHandler: { (data, response, error) in
                    
                    guard error == nil else{
                        observer.onError(error!)
                        return
                    }
                    
                    guard let data = data,
                    let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                        else{
                            observer.onError(DataError.cantParseJSON)
                            return;
                    }
                    
                    observer.onNext(jsonObject)
                    observer.onCompleted()
                })
                
                task.resume()
                return Disposables.create {
                    task.cancel()
                }
            })
            json.subscribe({ (event) in
              print(event)
            }).dispose()
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
enum DataError:Error {
    case cantParseJSON
}
