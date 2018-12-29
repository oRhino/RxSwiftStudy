//
//  ADViewController.swift
//  RXSwiftDemo
//
//  Created by iMac on 2018/1/12.
//  Copyright © 2018年 iMac. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit


class ADViewController: BaseViewController{
    
    let titleLabel:UILabel = {
       let label = UILabel(frame: CGRect(x: 40, y: 200, width: UIConst.ScreenWidth - (2 * 40), height: 30))
        label.text = "当前时间"
        label.textAlignment = NSTextAlignment.center
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 1
        return label
    }()
    
    let timeLabel:UILabel = {
        let label = UILabel(frame: CGRect(x: 40, y: 240, width: UIConst.ScreenWidth - (2 * 40), height: 40))
        label.textAlignment = NSTextAlignment.center
        label.font = UIFont.systemFont(ofSize: 25)
        label.numberOfLines = 1
        return label
    }()
    
    //必须声明类型,编译器无法推断
    let refreshButton:UIButton = {
       let button = UIButton(frame: CGRect(x: 80, y: 300, width: UIConst.ScreenWidth - (2 * 80), height: 30))
        button.adjustsImageWhenDisabled = false
        button.adjustsImageWhenHighlighted = false
        button.setTitle("Refresh", for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        return button
    }()
    
    let disposeBag:DisposeBag = DisposeBag()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(titleLabel)
        view.addSubview(timeLabel)
        view.addSubview(refreshButton)
        
        
        //约束 宽高相等100,在屏幕中心
        refreshButton.snp.makeConstraints { (make) in
            make.width.height.equalTo(100)
            make.center.equalTo(self.view)
        }
        
        
        
        timeLabel.text = getNowTimeString()
        
        //映射为字符串 然后进行绑定
        refreshButton.rx.tap.map({ [weak self]  in
            return self?.getNowTimeString()
            })
            .bind(to: timeLabel.rx.text)
            .disposed(by: disposeBag)
        
        
        
    }
    
    
    private func getNowTimeString() -> String{
        
        let dateformate = DateFormatter()
        dateformate.dateStyle = .medium
        dateformate.timeStyle = .medium
        return dateformate.string(from: Date())
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
