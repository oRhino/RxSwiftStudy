//
//  TransformingViewController.swift
//  RXSwiftDemo
//
//  Created by iMac on 2018/1/20.
//  Copyright © 2018年 iMac. All rights reserved.
//

import UIKit
import RxSwift

/*
 Map与FlatMap
 都是将传入的参数转化之后返回另一个对象,和map不同的是,flatmap返回的是一个Observable对象,并且这个Observable并不是被直接发送到了Subcriber的回调方法中.
 flatmap的原理:
 1.使用传入的事件对象创建一个Observable对象.
 2.并不发送这个Observable对象,而是将它激活,于是它开始发射事件
 3.每一个创建出来的Observable发送的事件,都被汇入同一个Observable,而这个Observable负责将这些事件统一交给Subscribe的回调方法
 flat:铺平 
 */
class TransformingViewController: BaseViewController {

    struct Student {
        var score:BehaviorSubject<Int>
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        example(of: "toArray") {
            
            let disposeBag = DisposeBag()
            
            Observable.of("A","B","C")
                .toArray()
                .subscribe(onNext:{
                    print($0)
                }).disposed(by: disposeBag)
            
        }
        
        example(of: "map") {
           // one hundred twenty-three
           // four
           // fifty-six
            let disposeBag = DisposeBag()
            
            let formatter = NumberFormatter()
            formatter.numberStyle = .spellOut
            
            Observable<NSNumber>.of(123,4,56)
                .map({ (number) -> String in
                    formatter.string(from: number) ?? ""
                }).subscribe(onNext:{
                    print($0)
                }).disposed(by: disposeBag)
        }
        
        example(of: "enumerated and map") {
//            ---Example of: enumerated and map ---
//            1
//            2
//            3
//            8
//            10
//            12
            let disposeBag = DisposeBag()
            
            Observable.of(1,2,3,4,5,6)
            .enumerated()
                .map({ (index,value) -> Int in
                    index > 2 ? value * 2 : value
                }).subscribe(onNext:{
                    print($0)
                }).disposed(by: disposeBag)
        }
        
        example(of: "flatMap") {
            
            let disposeBag = DisposeBag()
            
            let ryan = Student(score: BehaviorSubject(value: 80))
            let charlotte = Student(score: BehaviorSubject(value: 90))
            
            let student = PublishSubject<Student>()
            
            student.flatMap{
                $0.score
                }.subscribe(onNext:{
                  print($0)
                }).disposed(by: disposeBag)
            
            student.onNext(ryan)
            
            ryan.score.onNext(85)
            
            student.onNext(charlotte)
            
            charlotte.score.onNext(95)
            
            charlotte.score.onNext(100)
        }
        
        example(of: "flatMapLatest") {
            
            let disposeBag = DisposeBag()
            
            let ryan = Student(score: BehaviorSubject(value: 80))
            let charlotte = Student(score: BehaviorSubject(value: 90))
            
            let student = PublishSubject<Student>()
            
            student
                .flatMapLatest {
                    $0.score
                }
                .subscribe(onNext: {
                    print($0)
                })
                .disposed(by: disposeBag)
            
            student.onNext(ryan)
            
            ryan.score.onNext(85)
            
            student.onNext(charlotte)
            
            // 1 订阅者不会收到
            ryan.score.onNext(95)
            
            charlotte.score.onNext(100)
        }
        
        example(of: "materialize and dematerialize") {
            
            // 1
            enum MyError: Error {
                case anError
            }
            
            let disposeBag = DisposeBag()
            
            // 2
            let ryan = Student(score: BehaviorSubject(value: 80))
            let charlotte = Student(score: BehaviorSubject(value: 100))
            
            let student = BehaviorSubject(value: ryan)
            
            // 1
            let studentScore = student
                .flatMapLatest {
                    $0.score.materialize()
            }
            
            // 2
            studentScore
                // 1
                .filter {
                    guard $0.error == nil else {
                        print($0.error!)
                        return false
                    }
                    
                    return true
                }
                // 2
                .dematerialize()
                .subscribe(onNext: {
                    print($0)
                })
                .disposed(by: disposeBag)
            
            // 3
            ryan.score.onNext(85)
            
            ryan.score.onError(MyError.anError)
            
            ryan.score.onNext(90)
            
            // 4
            student.onNext(charlotte)
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
