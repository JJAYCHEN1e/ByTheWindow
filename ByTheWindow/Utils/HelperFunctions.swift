//
//  HelpetFunctions.swift
//  ByTheWindow
//
//  Created by JJAYCHEN on 2020/2/23.
//  Copyright © 2020 JJAYCHEN. All rights reserved.
//

import Foundation
import UIKit

func getThumbnailImage(with view: UIView) -> UIImage? {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0)
    defer { UIGraphicsEndImageContext() }
    view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
    return UIGraphicsGetImageFromCurrentImageContext()
}

func getImageOfScrollView(scrollView: UIScrollView, constrains: [NSLayoutConstraint] = []) -> UIImage {
    var image = UIImage()

    UIGraphicsBeginImageContextWithOptions(scrollView.contentSize, false, 0)
    
    // save initial values
    let savedContentOffset = scrollView.contentOffset
    let savedFrame = scrollView.frame
    let savedBackgroundColor = scrollView.backgroundColor

    // reset offset to top left point
    scrollView.contentOffset = .zero
    // set frame to content size
    scrollView.frame = CGRect(x: 0, y: 0, width: scrollView.contentSize.width, height: scrollView.contentSize.height)
    // remove background
    scrollView.backgroundColor = UIColor.clear

    // make temp view with scroll view content size
    // a workaround for issue when image on ipad was drawn incorrectly
    let tempView = UIView(frame: CGRect(x: 0, y: 0, width: scrollView.contentSize.width, height: scrollView.contentSize.height))

    // save superview
    let tempSuperView = scrollView.superview
    let index = tempSuperView?.subviews.firstIndex(of: scrollView)
    
    // remove scrollView from old superview
    scrollView.removeFromSuperview()
    // and add to tempView
    tempView.addSubview(scrollView)

    // render view
    // drawViewHierarchyInRect not working correctly
    tempView.layer.render(in: UIGraphicsGetCurrentContext()!)
    // and get image
    image = UIGraphicsGetImageFromCurrentImageContext()!

    // and return everything back
    tempView.subviews[0].removeFromSuperview()
    
    if tempSuperView != nil {
        tempSuperView!.insertSubview(scrollView, at: index!)
        NSLayoutConstraint.activate(constrains)
    }

    // restore saved settings
    scrollView.contentOffset = savedContentOffset
    scrollView.frame = savedFrame
    scrollView.backgroundColor = savedBackgroundColor

    UIGraphicsEndImageContext()

    return image
}
