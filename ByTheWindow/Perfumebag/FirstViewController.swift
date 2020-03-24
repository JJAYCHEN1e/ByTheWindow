//
//  ViewController.swift
//  XiangNang
//
//  Created by 项慕凡 on 2020/3/9.
//  Copyright © 2020 项慕凡. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {
    
    @IBOutlet weak var plate: UIImageView!
    
    @IBOutlet weak var dragedSpice: UIImageView!
    
    @IBOutlet weak var introduction: UITextView!
    
    @IBOutlet weak var xiang: UIImageView!
    @IBOutlet weak var you: UIImageView!
    @IBOutlet weak var bai: UIImageView!
    @IBOutlet weak var xiong: UIImageView!
    @IBOutlet weak var ai: UIImageView!
    
    @IBOutlet weak var backBtn: UIButton!
    
    
    var selectSpice: UIImageView?
    var preSpice: UIImageView?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dragedSpice.alpha = 0.5
        dragedSpice.isHidden = true
        xiang.isHidden = true
        you.isHidden = true
        bai.isHidden = true
        xiong.isHidden = true
        ai.isHidden = true
        backBtn.isEnabled = false
        introduction.isEditable = false
        introduction.font = UIFont(name: "MaShanZheng-Regular", size: 38)
        
        
        let handDrag = UIPanGestureRecognizer(target: self, action: #selector(handleDrag(_:)))
        
        self.view.addGestureRecognizer(handDrag)
        
        
        
    }
    @IBAction func handleDrag(_ sender: UIPanGestureRecognizer) {
        if(dragedSpice.isHidden) {
            return
        }
        let point = sender.location(in: self.view)
        if sender.state == .began  {
            dragedSpice.centerX = point.x
            dragedSpice.centerY = point.y
        } else if sender.state == .changed {
            dragedSpice.centerX = point.x
            dragedSpice.centerY = point.y
        } else {
            dragedSpice.centerX = -121
            dragedSpice.centerY = -51
            dragedSpice.isHidden = true
            selectSpice?.isHidden = false
            preSpice = selectSpice
            backBtn.isEnabled = true
        }
    }
    
    @IBAction func backBtn(_ sender: Any) {
        preSpice?.isHidden = true
        backBtn.isEnabled = false
    }
    @IBAction func reset(_ sender: Any) {
        xiang.isHidden = true
        you.isHidden = true
        bai.isHidden = true
        xiong.isHidden = true
        ai.isHidden = true
        backBtn.isEnabled = false
        introduction.text = "点击即可查看香料的介绍，拖动到盘子中选中香料。"
    }
    
    
    @IBAction func xiangTouchDown(_ sender: Any) {
        introduction.text = "香茅\n\n有柠檬的芳香，全草所含挥发油是香茅油，能祛风除湿，散寒解表，还能防虫咬。"
        dragedSpice.image = #imageLiteral(resourceName: "香茅")
        selectSpice = xiang
        dragedSpice.isHidden = false
    }
    

    @IBAction func youTouchDown(_ sender: Any) {
        introduction.text = "柚子叶\n\n是芸香科植物柚子的叶子，所含的挥发油有橘子皮的味道，可以防治风头痛。"
        dragedSpice.image = #imageLiteral(resourceName: "柚子叶")
        selectSpice = you
        dragedSpice.isHidden = false
    }
    

    @IBAction func baiTouchDown(_ sender: Any) {
        introduction.text = "白芷\n\n有祛风燥湿，消肿止痛的功效。"
        dragedSpice.image = #imageLiteral(resourceName: "白芷")
        selectSpice = bai
        dragedSpice.isHidden = false
    }
    

    @IBAction func xiongTouchDown(_ sender: Any) {
        introduction.text = "雄黄\n\n燥湿祛风，杀虫、解毒。"
        dragedSpice.image = #imageLiteral(resourceName: "雄黄")
        selectSpice = xiong
        dragedSpice.isHidden = false
    }
    
    
    @IBAction func aiTouchDown(_ sender: Any) {
        introduction.text = "艾草\n\n有理气血、逐寒湿、温经、止血等功效"
        dragedSpice.image = #imageLiteral(resourceName: "艾叶")
        selectSpice = ai
        dragedSpice.isHidden = false
    }
}


extension UIView {
    
    // MARK: - 常用位置属性
    
    public var left:CGFloat {
        get {
            return self.frame.origin.x
        }
        set(newLeft) {
            var frame = self.frame
            frame.origin.x = newLeft
            self.frame = frame
        }
    }
    
    public var top:CGFloat {
        get {
            return self.frame.origin.y
        }
        
        set(newTop) {
            var frame = self.frame
            frame.origin.y = newTop
            self.frame = frame
        }
    }
    
    public var width:CGFloat {
        get {
            return self.frame.size.width
        }
        
        set(newWidth) {
            var frame = self.frame
            frame.size.width = newWidth
            self.frame = frame
        }
    }
    
    public var height:CGFloat {
        get {
            return self.frame.size.height
        }
        
        set(newHeight) {
            var frame = self.frame
            frame.size.height = newHeight
            self.frame = frame
        }
    }
    
    public var right:CGFloat {
        get {
            return self.left + self.width
        }
    }
    
    public var bottom:CGFloat {
        get {
            return self.top + self.height
        }
    }
    
    public var centerX:CGFloat {
        get {
            return self.center.x
        }
        
        set(newCenterX) {
            var center = self.center
            center.x = newCenterX
            self.center = center
        }
    }
    
    public var centerY:CGFloat {
        get {
            return self.center.y
        }
        
        set(newCenterY) {
            var center = self.center
            center.y = newCenterY
            self.center = center
        }
    }
    
}
