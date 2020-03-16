//
//  PerfumebagView.swift
//  ByTheWindow
//
//  Created by 项慕凡 on 2020/3/16.
//  Copyright © 2020 JJAYCHEN. All rights reserved.
//

import SwiftUI

struct PerfumebagView: View {
    var body: some View {
        ZStack {
            PerfumebagController()
        }
    }
}

struct PerfumebagController: UIViewControllerRepresentable {
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<PerfumebagController>) {
    
    }
    
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<PerfumebagController>) -> UIViewController {
        
        let storyboard = UIStoryboard(name: "PerfumeBag", bundle: Bundle.main)
        let controller = storyboard.instantiateViewController(identifier: "PerfumeBag")
        
        
        return controller
    }
    
    
}
