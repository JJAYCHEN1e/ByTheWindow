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
    @State var allowsDrawing = true
    @State var allowsFingerDrawing = true
    @State var clearAction: () -> () = {}
    @State var contentEditingAction: () -> () = {}
    
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
            
            
            if allowsDrawing {
                GreetingCardContentTextView(text: $content, contentEditingAction: $contentEditingAction)
                    .offset(x: 100, y: 300)
            }
            
            PencilKitView(allowsDrawing: $allowsDrawing, allowsFingerDrawing: $allowsFingerDrawing, clearAction: $clearAction)
            
            if !allowsDrawing {
                GreetingCardContentTextView(text: $content, contentEditingAction: $contentEditingAction)
                    .offset(x: 100, y: 300)
            }
            
            VStack {
                HStack {
                    ButtonWithBlurBackground(
                        actions: [
                            {
                                self.allowsDrawing.toggle()
                            },
                            {
                                self.allowsFingerDrawing.toggle()
                            }
                        ],
                        imageName: [ "pencil.and.outline", "hand.draw",],
                        frameWidth: 120,
                        colors: [allowsDrawing ? Color.blue : Color.white.opacity(0.9), allowsDrawing ? (allowsFingerDrawing ? Color.blue : Color.white.opacity(0.9)) : Color.white.opacity(0.3)],
                        size: 34
                    )
                    
                    Spacer()
                    
                    ButtonWithBlurBackground(actions: [{
                        self.clearAction()
                        }], imageName: ["trash"])
                }
                .padding()
                Text(content)
                Spacer()
            }
        }
    }
}

// MARK: 文本框
struct GreetingCardContentTextView: UIViewRepresentable {
    @Binding var text: String
    @Binding var contentEditingAction: () -> ()
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UITextView {
        let view = UITextView()
        view.font = UIFont(name: "?| ", size: 40)
        view.textColor = #colorLiteral(red: 0.9763947129, green: 0.964057982, blue: 0.6910167336, alpha: 1)
        view.backgroundColor = .clear
        view.isScrollEnabled = false
        view.isEditable = true
        view.isUserInteractionEnabled = true
        view.frame = CGRect(x: 0, y: 0, width: 650, height: 300)
        
        // 限制宽度
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalToConstant: 650).isActive = true
        
        view.delegate = context.coordinator
        
        DispatchQueue.main.async {
            self.contentEditingAction = {
                view.becomeFirstResponder()
            }
        }
        return view
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var greetingCardContentTextView: GreetingCardContentTextView
        
        init(_ greetingCardContentTextView: GreetingCardContentTextView) {
            self.greetingCardContentTextView = greetingCardContentTextView
        }
        
        func textViewDidChange(_ textView: UITextView) {
            // 实时保存文本，但是由于中文输入法存在冲突(markedText)，因此要特殊判断
            if textView.markedTextRange == nil {
                greetingCardContentTextView.text = textView.text ?? String()
            }
        }
    }
}

struct GreetingCardView_Previews: PreviewProvider {
    static var previews: some View {
        GreetingCardView(clearAction: {
            
        })
            .previewLayout(.fixed(width: 1112, height: 834)) // iPad Air 10.5
        //        .previewLayout(.fixed(width: 1080, height: 810)) // iPad 7th
        //        .previewLayout(.fixed(width: 1194, height: 834)) // iPad Pro 11"
        //        .previewLayout(.fixed(width: 1366, height: 1024)) // iPad Pro 12.9"
        //        .previewLayout(.fixed(width: 1024, height: 768)) // iPad mini5, iPad Pro 9.7"
    }
}
