//
//  FourthViewController.swift
//  XiangNang
//
//  Created by 项慕凡 on 2020/3/16.
//  Copyright © 2020 项慕凡. All rights reserved.
//

import UIKit

class FourthViewController: UIViewController {
    
    var nangName: String?

    @IBOutlet weak var nangImage: UIImageView!
    @IBOutlet weak var poemTitle: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        poemTitle.font = UIFont(name: "MaShanZheng-Regular", size: 40)
        poemTitle.isEditable = false
        
        if let name = nangName {
            nangImage.image = UIImage(named: name)
        }
        // Do any additional setup after loading the view.
    }
    

}
