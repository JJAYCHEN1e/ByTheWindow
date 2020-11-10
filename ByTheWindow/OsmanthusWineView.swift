//
//  OsmanthusWineView.swift
//  ByTheWindow
//
//  Created by 项慕凡 on 2020/11/9.
//  Copyright © 2020 JJAYCHEN. All rights reserved.
//

import SwiftUI

struct OsmanthusWineView: View {
    var body: some View {
        ZStack {
            OsmanthusWineController()
                .edgesIgnoringSafeArea(.all)
        }
    }
}

struct OsmanthusWineController: UIViewControllerRepresentable {
    
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<OsmanthusWineController>) -> UIViewController {
        let storyboard = UIStoryboard(name: "OsmanthusWine", bundle: Bundle.main)
        let controller = storyboard.instantiateViewController(identifier: "OsmanthusWine")
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<OsmanthusWineController>) {
        
    }
}
