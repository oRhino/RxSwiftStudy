//
//  PracticeViewController.swift
//  RXSwiftDemo
//
//  Created by iMac on 2018/1/20.
//  Copyright © 2018年 iMac. All rights reserved.
//

import UIKit

class PracticeViewController: ViewController {

    //Cannot override with a stored property 'dataSource'
    //存储型属性不能重写 (更改为存储型属性)
    //子类重写属性必须添加 override
   override var dataSource:[[String:String]]{
        return [
            ["title":"Button","viewcontroller":"ButtonViewController"],
            ["title":"TextField","viewcontroller":"TextFieldViewController"],
            ["title":"Map","viewcontroller":"ADViewController"],
            ["title":"Snap","viewcontroller":"SnapViewController"],
            ["title":"SnapInset","viewcontroller":"SnapInsetViewController"],
            ["title":"Refresh","viewcontroller":"RefreshViewController"]]
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
