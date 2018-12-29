//
//  TextFieldViewController.swift
//  RXSwiftDemo
//
//  Created by iMac on 2018/1/12.
//  Copyright © 2018年 iMac. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift



class TextFieldViewController: BaseViewController {

    //懒加载
    //必须使用var声明变量
    //必须指定变量的类型
    //lazy和{}(),其实就是闭包,所以需要注意循环引用,编译器会自动提示
    lazy var textField:UITextField = {[weak self] in
        let textField = UITextField(frame: CGRect(x: 40, y: 120, width: UIConst.ScreenWidth - 2 * 40, height: 40))
        textField.delegate = self
        textField.borderStyle = UITextBorderStyle.roundedRect
        textField.placeholder = "$0.00"
        textField.textAlignment = .right
        textField.keyboardType = UIKeyboardType.decimalPad
        textField.addTarget(self, action: #selector(textDidChange(_:)), for: UIControlEvents.editingChanged)
        return textField
    }()
    let disposeBag:DisposeBag = DisposeBag()
    
    lazy var tipLabel:UILabel = {
       let tip = UILabel(frame: CGRect(x: 120, y: 170, width: UIConst.ScreenWidth - 40 - 120, height: 20))
        tip.numberOfLines = 1;
        tip.text = "Tip(0%)     $0.00"
        tip.textAlignment = NSTextAlignment.right
        tip.font = UIFont.systemFont(ofSize: 14)
        return tip
    }()
    
    lazy var totalLabel:UILabel = {
        let total = UILabel(frame: CGRect(x: 120, y: 200, width: UIConst.ScreenWidth - 40 - 120, height: 20))
        total.numberOfLines = 1;
        total.text = "Total:     $0.00"
        total.textAlignment = NSTextAlignment.right
        total.font = UIFont.systemFont(ofSize: 14)
        return total
    }()
    
    lazy var slider:UISlider = {
       let slider = UISlider(frame: CGRect(x: 40, y: 240, width: UIConst.ScreenWidth - 2 * 40, height: 20))
        slider.value = 0
        return slider
    }()
    
    var value:Double = 0.0
    var percent:Double = 0.0
    
    let doneButton:UIBarButtonItem = {
       let item = UIBarButtonItem()
        item.title = "Done"
        item.style = UIBarButtonItemStyle.done
        return item
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //1.添加UI
        view.addSubview(textField)
        view.addSubview(tipLabel)
        view.addSubview(totalLabel)
        view.addSubview(slider)
        
        let toobar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIConst.ScreenWidth, height: 40))
        toobar.items = [doneButton]
        toobar.barStyle = UIBarStyle.default
        toobar.sizeToFit()
        textField.inputAccessoryView = toobar
        
        
        
        //2.绑定事件
        //textfield
//        textField.rx.text.subscribe({(event) in
//            print(event.event)
//        }).disposed(by: disposeBag)
        
        textField.rx.controlEvent(UIControlEvents.touchDown).subscribe(onNext:{[weak self] in
            guard let this = self else{
                return
            }
            this.textField.text = ""
            
        }).disposed(by: disposeBag)
        
        
         //slider
        //有参数的闭包 [weak self]放在(参数)之前
        slider.rx.value.subscribe{[weak self] (value) in
            
            guard let this = self else{
                return
            }
            this.caulator()
        }.disposed(by: disposeBag)
        
        //闭包的循环引用
//        [unowned self] _unsafe__retained作用类似  -> 对象被回收是 内存地址不会自动指向nil 会造成野指针访问
//        [weak self] __weak typeof(self) 作用类似  -> 对象被回收是 内存地址会自动指向nil  更加安全 推荐使用这种方式
        
        //结束编辑
        doneButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let this = self else{
                return
            }
            guard let text = this.textField.text else{
                return
            }
            guard !text.isEmpty else{
                return
            }
            guard let number = Double(text)?.roundToPlaces(2) else{
                return
            }
            this.value = number
            this.textField.text = "$\(String(format:"%.2f",number))"
            this.caulator()
            this.view.endEditing(true)
            })
            .disposed(by: disposeBag)
        
        
    }
    
    func caulator(){
        let percent = Double(slider.value).roundToPlaces(2)
        tipLabel.text = "Tip(\(String(format:"%.0f",percent * 100))%)     $\(String(format:"%.2f",value * percent))"
        totalLabel.text = "Total:     $\(String(format:"%.2f",Double(String(format:"%.2f",value * percent))! + value))"
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

extension TextFieldViewController:UITextFieldDelegate{
    
    
}

extension Double {
    /// Rounds the double to decimal places value
    func roundToPlaces(_ places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return Darwin.round(self * divisor) / divisor
    }
}

// MARK: - Event
extension TextFieldViewController{
    
    @objc func textDidChange(_ textField:UITextField){
        
    }
}
