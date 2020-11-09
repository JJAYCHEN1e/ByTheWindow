//
//  OsmanthusWineMakerViewController.swift
//  ByTheWindow
//
//  Created by 项慕凡 on 2020/11/9.
//  Copyright © 2020 JJAYCHEN. All rights reserved.
//

import UIKit

class OsmanthusWineMakerViewController: UIViewController {
    @IBOutlet weak var osmanthusOnWine: UIImageView!
    @IBOutlet weak var osmanthus: UIImageView!
    @IBOutlet weak var dragImage: UIImageView!
    var osmanthusIsOnWine: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        osmanthusOnWine.isHidden = true
        dragImage.isHidden = true
        osmanthusIsOnWine = false
        
        let m_handleDrag = UIPanGestureRecognizer(target: self, action: #selector(handleDrag(_:)))
        self.view.addGestureRecognizer(m_handleDrag)
    }
    
    
    @IBAction func handleDrag(_ sender: UIPanGestureRecognizer) {
        if osmanthusIsOnWine {
            return
        }
        let x = dragImage.centerX
        let y = dragImage.centerY
        let point = sender.location(in: self.view)
        if sender.state == .began {
            dragImage.centerX = point.x
            dragImage.centerY = point.y
        } else if sender.state == .changed {
            dragImage.centerX = point.x
            dragImage.centerY = point.y
        } else {
            dragImage.centerX = x
            dragImage.centerY = y
            dragImage.isHidden = true
            osmanthusOnWine.isHidden = false
            osmanthusIsOnWine = true
        }
        
    }
    
    @IBAction func osmanthusTouchDown(_ sender: Any) {
        if osmanthusIsOnWine {
            return
        }
        dragImage.isHidden = false
    }
}
