//
//  Blur.swift
//  ByTheWindow
//
//  Created by JJAYCHEN on 2020/2/14.
//  Copyright © 2020 JJAYCHEN. All rights reserved.
//

import UIKit
import SwiftUI

extension UIView {
    func addBlurInSubviewWith(cornerRadius: CGFloat = 15) {
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blurView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        blurView.layer.cornerRadius = cornerRadius
        blurView.clipsToBounds = true
        insertSubview(blurView, at: 0)
    }
}

/// 封装 UIVisualEffectView 的 SwiftUI 结构体
struct VisualEffect: UIViewRepresentable {
    var effect: UIVisualEffect?
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: effect)
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = effect
    }
}

/// 封装 VisualEffect 与 Button
struct ButtonWithBlurBackground: View {
    var action: () -> Void
    var imageName: String
    
    var effect: UIVisualEffect = UIBlurEffect(style: .dark)
    var frameWidth: CGFloat = 80
    var frameHeight: CGFloat = 50
    var cornerRadius: CGFloat = 15
    var color: Color = Color(.white).opacity(0.9)
    var size: CGFloat = 28
    
    var body: some View {
        ZStack {
            VisualEffect(effect: effect)
                .frame(width: frameWidth, height: frameHeight)
                .cornerRadius(cornerRadius)
            Button(action: action){
                HStack {
                    Image(systemName: imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(color)
    //                    .background(Color.white)
                        .frame(width: size, height: size)
                }
                .frame(width: frameWidth, height: frameHeight)
            }
        }
    }
}

struct Blur_Previews: PreviewProvider {
    static var previews: some View {
        ButtonWithBlurBackground(action: {
        }, imageName: "hand.draw")
    }
}
