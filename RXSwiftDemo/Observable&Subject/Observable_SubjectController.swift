//
//  Observable&SubjectController.swift
//  RXSwiftDemo
//
//  Created by iMac on 2018/1/20.
//  Copyright © 2018年 iMac. All rights reserved.
//

import UIKit



class Observable_SubjectController: ViewController {

    override var dataSource:[[String:String]]{
        return [["title":"Observable","viewcontroller":"ObservableViewController"],
                ["title":"Subject","viewcontroller":"SubjectViewController"],
                ["title":"Practice","viewcontroller":"MainViewController"]]
    }
    
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}



