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
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0.5)
    defer { UIGraphicsEndImageContext() }
    view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
    return UIGraphicsGetImageFromCurrentImageContext()
}
