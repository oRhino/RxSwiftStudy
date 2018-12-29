//
//  ViewController.swift
//  RXSwiftDemo
//
//  Created by iMac on 2018/1/12.
//  Copyright © 2018年 iMac. All rights reserved.
//

import UIKit




class ViewController: BaseViewController {
    
    //计算型属性
    //1.存储型属性子类不能够重写
    //2.计算性属性必须声明为var
    var dataSource:[[String:String]]{
        return [
            ["title":"OtherPractice","viewcontroller":"PracticeViewController"],
            ["title":"Observable_Subject","viewcontroller":"Observable_SubjectController"],
            ["title":"Operators","viewcontroller":"OperatorViewController"],
            ["title":"Weather","viewcontroller":"WeatherSearchViewController"],
            ["title":"Transform","viewcontroller":"ActivityController"]
        ]
    }
    
    let identifierCell = "UITableViewCellIdentifier"
    
    lazy var tableView:UITableView = { [weak self] in
        let tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.rowHeight = 47
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: identifierCell)
        return tableView
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "RxSwift"
        view.addSubview(self.tableView)
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

extension ViewController:UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifierCell, for: indexPath)
        let dict = dataSource[indexPath.row]["title"]
        cell.textLabel?.text = dict
        return cell
    }
    
}

extension ViewController:UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vcName = dataSource[indexPath.row]["viewcontroller"] ?? "UIViewController"
        let Class = NSClassFromString(Bundle.main.namespace + "." + vcName) as?UIViewController.Type
        let viewController:UIViewController = Class!.init()
        viewController.title = dataSource[indexPath.row]["title"]
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
}

