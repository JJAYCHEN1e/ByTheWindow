//
//  ThirdViewController.swift
//  XiangNang
//
//  Created by 项慕凡 on 2020/3/16.
//  Copyright © 2020 项慕凡. All rights reserved.
//

import UIKit

class ThirdViewController: UIViewController {
    
    var colorName: String?
    
    var chooseShape: String?

    @IBOutlet weak var nangChooseImage: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let name = colorName {
            nangChooseImage.image = UIImage(named: name)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is FourthViewController {
            let vc = segue.destination as! FourthViewController
            vc.nangName = colorName! + chooseShape!
        }
    }
    
    @IBAction func chooseTriangle(_ sender: Any) {
        chooseShape = "Triangle"
    }
    
    @IBAction func chooseBao(_ sender: Any) {
        chooseShape = "Bao"
    }
    
}
