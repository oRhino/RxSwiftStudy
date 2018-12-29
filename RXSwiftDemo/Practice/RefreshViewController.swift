//
//  RefreshViewController.swift
//  RXSwiftDemo
//
//  Created by Rhino on 2018/1/14.
//  Copyright © 2018年 iMac. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class RefreshViewController: BaseViewController,DataEnteredDelegated{

    let tableView:UITableView = {
       let t = UITableView()
        t.rowHeight = 47
        t.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        t.backgroundColor = UIColor.yellow
        return t
    }()
    fileprivate let refresh:UIRefreshControl = UIRefreshControl()
    
    let items = Variable([
        "Mike",
        "Apples",
        "Ham",
        "Eggs"
        ])
    
    let items2 = [
        "Fish",
        "Carrots",
        "Mike",
        "Apples",
        "Ham",
        "Eggs",
        "Bread",
        "Chiken",
        "Water"
    ]
    let disposeBag:DisposeBag = DisposeBag()
    
    var edit = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        tableView.addSubview(refresh)
        
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsets.zero)
        }
        
        //cell
        items.asObservable().bind(to: tableView.rx.items(cellIdentifier:"Cell",cellType:UITableViewCell.self),curriedArgument:{
            (row,element,cell) in
            cell.textLabel?.text = element
        }).disposed(by: disposeBag)
        
        //刷新
        refresh.rx.controlEvent(UIControlEvents.valueChanged).subscribe(onNext:{ [weak self] in
            self?.items.value = (self?.items2)!
            self?.refresh.endRefreshing()
        }).disposed(by: disposeBag)
        
        //删除
        tableView.rx.itemDeleted.subscribe(onNext:{[weak self] (indexPath) in
            self?.items.value.remove(at: indexPath.row)
        }).disposed(by: disposeBag)
        
        //移动
        tableView.rx.itemMoved.subscribe(onNext:{[weak self] (fromIndexPath, toIndexPath)in
            let ele = self?.items.value.remove(at: fromIndexPath.row)
            self?.items.value.insert(ele ?? "", at: toIndexPath.row)
        }).disposed(by: disposeBag)
        
        //点击事件
        tableView.rx.itemSelected.subscribe(onNext:{(event) in
            print(event) //indexPath
        }).disposed(by: disposeBag)
        tableView.rx.modelSelected(String.self).subscribe(onNext:{ (value) in
            print(value)
        }).disposed(by: disposeBag)
        //可选类型
//        tableView.rx.modelSelected(String.self).subscribe{ (value) in
//            print(value)
//        }.disposed(by: disposeBag)
        
        
        let btn = UIButton()
        btn.setTitle("Edit", for: UIControlState.normal)
        btn.setTitleColor(UIColor.black, for: .normal)
        //编辑
        btn.rx.tap.subscribe(onNext:{ [weak self] in
            if (self?.edit)!{
                self?.tableView.isEditing = false
            }else{
                self?.tableView.isEditing = true
            }
            self?.edit = !(self?.edit)!
        }).disposed(by: disposeBag)
        
        //添加
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil)
        
        add.rx.tap.subscribe(onNext:{[weak self] in
            
            let subVc = RefreshSubViewController()
            subVc.delegate = self
            self?.navigationController?.pushViewController(subVc, animated: true)
            
        }).disposed(by: disposeBag)
        
        
        
        self.navigationItem.rightBarButtonItems = [add,UIBarButtonItem(customView: btn)]
        
        
        
        _ = self.tableView.rx.observe(CGPoint.self, "contentOffset")
            .subscribe(onNext: {offset in
        
                print(offset)
            })
        
        
    }
    
    //实现代理方法
    func userDidEnterInformation(_ info: String) {
        //不用刷新 很厉害!!!!
        items.value.append(info)
        
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
