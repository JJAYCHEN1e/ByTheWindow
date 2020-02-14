//
//  Blur.swift
//  ByTheWindow
//
//  Created by JJAYCHEN on 2020/2/14.
//  Copyright © 2020 JJAYCHEN. All rights reserved.
//

import UIKit

extension UIView {
    func addBlurInSubviewWith(cornerRadius: CGFloat = 15) {
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blurView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        blurView.layer.cornerRadius = cornerRadius
        blurView.clipsToBounds = true
        insertSubview(blurView, at: 0)
    }
}
