//
//  ButtonViewController.swift
//  RXSwift
//
//  Created by iMac on 2018/1/11.
//  Copyright © 2018年 iMac. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift




class ButtonViewController: BaseViewController {

    let resetBtn:UIButton = {
        let reset = UIButton(frame: CGRect(x: 40, y: 100, width: UIConst.ScreenWidth - 2 * 40, height: 40))
        reset.setTitle("reset", for: .normal)
        reset.backgroundColor = UIColor.blue
        reset.addTarget(self, action: #selector(resetClick), for: UIControlEvents.touchUpInside)
        return reset
    }()
    
    let label:UILabel = {
        let label = UILabel(frame: CGRect(x: 40, y: 200, width: UIConst.ScreenWidth - 2 * 40, height: 40))
        label.backgroundColor = UIColor.brown
        label.textColor = UIColor.black
        label.textAlignment = .center
        label.text = "0"
        return label
    }()
    
    
    let countDown:UIButton = {
        let countDown = UIButton(frame: CGRect(x: 40, y: 300, width: UIConst.ScreenWidth - 2 * 40, height: 40))
        countDown.setTitle("countDown", for: .normal)
        countDown.backgroundColor = UIColor.orange
        countDown.addTarget(self, action: #selector(countDownClick), for: UIControlEvents.touchUpInside)
        return countDown
    }()
    
    fileprivate let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //懒加载 不需要使用self.
        view.addSubview(resetBtn)
        view.addSubview(label)
        view.addSubview(countDown)
        
        let longPress = UILongPressGestureRecognizer()
        longPress.minimumPressDuration = 2.0
        countDown.addGestureRecognizer(longPress)
        
        longPress.rx.event.subscribe { [weak self] (event) in
            //event.event为UILongPressGestureRecognizer()
            //state   Began -> Changed -> Ended
            guard let this = self else{
                return
            }
            guard let text = this.label.text else{
                return
            }
            guard let number = Int(text) else{
                return
            }
            this.label.text = String(number + 1)
        }.disposed(by: disposeBag)
        
        
        
        countDown.rx.tap.subscribe(onNext: {[weak self] in
            guard let this = self else{
                return
            }
            guard let text = this.label.text else{
                return
            }
            guard let number = Int(text) else{
                return
            }
            this.label.text = String(number + 1)
        }).disposed(by: disposeBag)
        
       
        
        
        //闭包对self进行捕获 造成循环引用
//        resetBtn.rx.tap.subscribe(onNext:{
//
//            self.label.text = "0"
//
//        }).disposed(by: disposeBag)
        
        
        resetBtn.rx.tap.subscribe(onNext:{ [weak self] in
            guard let this = self else{
                return
            }
            this.label.text = "0"

        }).disposed(by: disposeBag)
        

        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


extension ButtonViewController{
    
    
    @objc func resetClick(){
        print("reset")
    }
    
    @objc func countDownClick(){
        print("++")
    }
}






