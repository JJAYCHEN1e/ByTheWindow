//
//  KongmingLanternView.swift
//  ByTheWindow
//
//  Created by 陈俊杰 on 11/10/20.
//  Copyright © 2020 JJAYCHEN. All rights reserved.
//

import SwiftUI

struct KongmingLanternView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> KongmingLanternViewController {
        KongmingLanternViewController()
    }
    
    func updateUIViewController(_ uiViewController: KongmingLanternViewController, context: Context) {
        
    }
    
    typealias UIViewControllerType = KongmingLanternViewController
}
