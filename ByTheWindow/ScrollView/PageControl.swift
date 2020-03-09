//
//  SwiftUIView.swift
//  ByTheWindow
//
//  Created by 徐滔锴 on 2020/3/9.
//  Copyright © 2020 JJAYCHEN. All rights reserved.
//

import SwiftUI
import UIKit

import UIKit

struct PageControl: UIViewRepresentable {
    var numberOfPages: Int
    @Binding var currentPage: Int

    func makeUIView(context: Context) -> UIPageControl {
        let control = UIPageControl()
        control.numberOfPages = numberOfPages
        return control
    }

    func updateUIView(_ uiView: UIPageControl, context: Context) {
        uiView.currentPage = currentPage
    }
}
