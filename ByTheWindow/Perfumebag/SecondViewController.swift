//
//  SecondViewController.swift
//  XiangNang
//
//  Created by 项慕凡 on 2020/3/12.
//  Copyright © 2020 项慕凡. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {
    
    var chooseColor: String?
    @IBOutlet weak var _title: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _title.font = UIFont(name: "MaShanZheng-Regular", size: 48)
        _title.isEditable = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is ThirdViewController {
            let vc = segue.destination as! ThirdViewController
            vc.colorName = chooseColor
        }
    }
    
    @IBAction func chooseBlue(_ sender: Any) {
        chooseColor = "blue"
    }
    @IBAction func chooseRed(_ sender: Any) {
        chooseColor = "red"
    }
    
    
}
