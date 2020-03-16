//
//  ARCoupletView.swift
//  ByTheWindow
//
//  Created by 项慕凡 on 2020/2/26.
//  Copyright © 2020 JJAYCHEN. All rights reserved.
//

import SwiftUI

struct ARCoupletView: View {
    
    @EnvironmentObject var navigation: NavigationStack
    var body: some View {
        ZStack {
            ARCoupletController()
            VStack {
                HStack {
                    Spacer()
                    
                    Image(systemName: "arrowshape.turn.up.left.fill")
                    .frame(width: 36, height: 36)
                    .foregroundColor(.black)
                    .background(Color.white)
                        .clipShape(Circle())
                }
                Spacer()
            }
            .offset(x: -16, y: 16)
            .transition(.move(edge: .top))
            .animation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0))
            .onTapGesture {
                withAnimation() {
                    self.navigation.unwind()
                }
            }
        }
    }
}



struct ARCoupletController: UIViewControllerRepresentable {
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ARCoupletController>) -> UIViewController {
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let controller = storyboard.instantiateViewController(identifier: "ARCouplet")
        
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        return
    }
}

