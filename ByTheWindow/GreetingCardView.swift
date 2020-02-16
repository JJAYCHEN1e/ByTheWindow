//
//  GreetingCardView.swift
//  ByTheWindow
//
//  Created by JJAYCHEN on 2020/2/16.
//  Copyright © 2020 JJAYCHEN. All rights reserved.
//

import SwiftUI
import PencilKit

struct GreetingCardView: View {
    @State var allowsFingerDrawing = true
    @State var clearAction: () -> () = {}
    @State var handWrittenToggleAction: () -> () = {}
    
    @State var content = """
    今年过节送你福，福来运来幸福来，
    人旺运旺财运旺，大吉大利好预兆，
    顺心顺利更如意，幸福快乐更逍遥，
    恭贺新春快乐，吉祥好运，
    健康平安，心想事成！
    """
    
    
    var body: some View {
        ZStack {
            Image("GreetingCard00")
                .resizable()
                .aspectRatio(contentMode: .fit)
            
            GreetingCardContentTextView(text: $content)
                .frame(width: 600, height: 300)
                .offset(x: -120, y: 20)
            
            PencilKitView(allowsFingerDrawing: $allowsFingerDrawing, clearAction: $clearAction, handWrittenToggleAction: $handWrittenToggleAction)
            
            VStack {
                HStack {
                    ButtonWithBlurBackground(
                        action: {
                            self.handWrittenToggleAction()
                    },
                        imageName: "hand.draw",
                        color: allowsFingerDrawing ? Color.blue : Color.white.opacity(0.9),
                        size: 34
                    )
                    
                    Spacer()
                    
                    ButtonWithBlurBackground(action: {
                        self.clearAction()
                    }, imageName: "trash")
                }
                .padding()
                Spacer()
            }
        }
    }
}

struct GreetingCardView_Previews: PreviewProvider {
    static var previews: some View {
        GreetingCardView(clearAction: {
            
        }, handWrittenToggleAction: {
            
        }).previewLayout(.fixed(width: 1112, height: 834))
    }
}

struct GreetingCardContentTextView: UIViewRepresentable {
    @Binding var text: String

    func makeUIView(context: Context) -> UITextView {
        let view = UITextView()
        view.font = UIFont(name: "MaShanZheng-Regular", size: 40)
        view.textColor = #colorLiteral(red: 0.9763947129, green: 0.964057982, blue: 0.6910167336, alpha: 1)
        view.backgroundColor = .clear
        view.isScrollEnabled = false
        view.isEditable = true
        view.isUserInteractionEnabled = true
        return view
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
    }
}
