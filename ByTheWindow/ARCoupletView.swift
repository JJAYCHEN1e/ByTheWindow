//
//  ARCoupletView.swift
//  ByTheWindow
//
//  Created by 项慕凡 on 2020/2/26.
//  Copyright © 2020 JJAYCHEN. All rights reserved.
//

import SwiftUI

struct ARCoupletView: View {
    var body: some View {
        ARCoupletView()
    }
}



struct ARCoupletController: UIViewControllerRepresentable {
    func makeUIViewController(context: UIViewControllerRepresentableContext<ARCoupletController>) -> UIViewController {
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let controller = storyboard.instantiateViewController(identifier: "ARCouplet")
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<ARCoupletController>) {
        
    }
}
