//
//  OsmanthusWineViewController.swift
//  ByTheWindow
//
//  Created by 项慕凡 on 2020/11/9.
//  Copyright © 2020 JJAYCHEN. All rights reserved.
//

import UIKit

class OsmanthusWineViewController: UIViewController {
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var nextBtn: UIButton!
    
    var period: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        image.image = UIImage(named: "shake-tree-1")
        period = 1
        nextBtn.isEnabled = false
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if period == 1 {
            image.image = UIImage(named: "shake-tree-2")
            period = 2
        } else {
            image.image = UIImage(named: "shake-tree-3")
            nextBtn.isEnabled = true
        }
    }
    
    
}
