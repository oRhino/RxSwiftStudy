//
//  RefreshSubViewController.swift
//  RXSwiftDemo
//
//  Created by Rhino on 2018/1/14.
//  Copyright © 2018年 iMac. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit



//定义协议
protocol DataEnteredDelegated:class {
    func userDidEnterInformation(_ info :String)
    
}

class RefreshSubViewController: BaseViewController,UITextViewDelegate{

    //代理 weak
    weak var delegate:DataEnteredDelegated? = nil
    
    let textView:UITextView = {
       let t = UITextView()
        t.font = UIFont.systemFont(ofSize: 14)
        t.backgroundColor = UIColor.groupTableViewBackground
        return t
    }()
    let disposeBag:DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "添加"
        view.addSubview(textView)
        textView.delegate = self
        
        textView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 100, left: 20, bottom: 200, right: 20))
        }
        let done =  UIBarButtonItem(barButtonSystemItem: .done, target: self, action: nil)
        navigationItem.rightBarButtonItem = done
        
        //why ?  disposeBag必须传一个具有引用的变量,直接传DisposeBag()不会执行
        //disposeBag是根据引用来进行销毁做内存回收的吧
        done.rx.tap.subscribe(onNext:{ [weak self] in
            self?.textView.resignFirstResponder()
        }).disposed(by:disposeBag)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textView.becomeFirstResponder()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        delegate?.userDidEnterInformation(textView.text)
        self.navigationController?.popViewController(animated: true)
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
