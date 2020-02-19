//
//  GreetingCardView.swift
//  ByTheWindow
//
//  Created by JJAYCHEN on 2020/2/16.
//  Copyright © 2020 JJAYCHEN. All rights reserved.
//

import SwiftUI
import PencilKit
import Combine

struct GreetingCardView: View {
    @State var allowsDrawing = true
    @State var allowsFingerDrawing = true
    @State var clearAction: () -> () = {}
    @State var contentEditingAction: () -> () = {}
    @State var showNotificationInterface: (_ text: String) -> () = {_ in }
    
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
                .aspectRatio(contentMode: .fill)
                .frame(height: screen.height)
            
            
            if allowsDrawing {
                GreetingCardContentTextView(text: $content, contentEditingAction: $contentEditingAction)
                    .offset(x: screen.width * 1.3 / 11, y: screen.height * 3 / 8)
            }
            
            PencilKitView(allowsDrawing: $allowsDrawing, allowsFingerDrawing: $allowsFingerDrawing, clearAction: $clearAction, showNotification: $showNotificationInterface)
            
            if !allowsDrawing {
                GreetingCardContentTextView(text: $content, contentEditingAction: $contentEditingAction)
                    .offset(x: screen.width * 1.3 / 11, y: screen.height * 3 / 8)
            }
            
            GreetingCardButtonView(allowsDrawing: $allowsDrawing, allowsFingerDrawing: $allowsFingerDrawing, clearAction: $clearAction, showNoticationInterface: $showNotificationInterface)
        }
        .edgesIgnoringSafeArea(.all)
    }
}

/// GreetingCardContentTextView
struct GreetingCardContentTextView: UIViewRepresentable {
    @Binding var text: String
    @Binding var contentEditingAction: () -> ()
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UITextView {
        let view = UITextView()
        //        view.font = UIFont(name: "?| ", size: 40)
//        view.font = UIFont(name: "MaShanZheng-Regular", size: 40)
        let customFont = UIFont(name: "MaShanZheng-Regular", size: 40)
        view.font = UIFontMetrics.default.scaledFont(for: customFont!)
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

/// GreetingCardButtonView
struct GreetingCardButtonView: View {
    @Binding var allowsDrawing: Bool
    @Binding var allowsFingerDrawing: Bool
    @Binding var clearAction: () -> ()
    @Binding var showNoticationInterface: (_ text:String) -> ()
    @State var text = ""
    @State var notificationOffset: CGFloat = 0
    @State var timer: Cancellable?
    
    func showNotification(_ text: String) {
        self.text = text
        timer?.cancel()
        notificationOffset = 0
        timer = DispatchQueue.main.schedule(
            after: DispatchQueue.main.now.advanced(by: .seconds(3)),
            interval: .seconds(2)
        ) {
            self.notificationOffset = -100
            self.timer?.cancel()
        }
    }
    
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                ButtonWithBlurBackground(
                    actions: [
                        {
                            self.allowsDrawing.toggle()
                            self.showNotification(self.allowsDrawing ? "开启书写功能" : "关闭书写功能")
                        },
                        {
                            if self.allowsDrawing {
                                self.allowsFingerDrawing.toggle()
                                self.showNotification(self.allowsFingerDrawing ? "允许触控书写" : "关闭触控书写")
                            }
                        }
                    ],
                    imageName: [ "pencil.and.outline", "hand.draw",],
                    frameWidth: 120,
                    colors: [allowsDrawing ? Color.blue : Color.white.opacity(0.9), allowsDrawing ? (allowsFingerDrawing ? Color.blue : Color.white.opacity(0.9)) : Color.white.opacity(0.3)],
                    size: 34
                )
                
                Spacer()
                
                TextWithBlurBackground(text: $text)
                    .offset(y: notificationOffset)
                    .animation(.spring())
                    .onAppear() {
                        self.showNotification("左侧可开启书写功能")
                        self.showNoticationInterface = self.showNotification
                }
                
                Spacer()
                
                ButtonWithBlurBackground(actions: [{
                    self.showNotification("书写内容已清空")
                    self.clearAction()
                    }], imageName: ["trash"])
            }
            .padding()
            Spacer()
        }
    }
}

/// PencilKitView
struct PencilKitView: UIViewRepresentable {
    @Binding var allowsDrawing: Bool
    @Binding var allowsFingerDrawing: Bool
    @Binding var clearAction: () -> ()
    @Binding var showNotification: (_ text: String) -> ()
    
    func makeCoordinator() -> Coordinator {
        let coordinator = Coordinator(self)
        coordinator.beginPencilDetect()
        return Coordinator(self)
    }
    
    func makeUIView(context: Context) -> PKCanvasView {
        let canvasView = PKCanvasView()
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        
        if let window = UIApplication.shared.windows.first, let toolPicker = PKToolPicker.shared(for: window) {
            canvasView.delegate = context.coordinator
            toolPicker.setVisible(true, forFirstResponder: canvasView)
            toolPicker.addObserver(canvasView)
            
            toolPicker.selectedTool = PKInkingTool(.pen, color: .black, width: 30)
            canvasView.becomeFirstResponder()
        }
        
        DispatchQueue.main.async {
            self.clearAction = {
                canvasView.drawing = PKDrawing()
            }
            self.allowsDrawing.toggle()
        }
        
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        uiView.allowsFingerDrawing = allowsFingerDrawing
        uiView.isUserInteractionEnabled = allowsDrawing
    }
    
    class Coordinator: NSObject, PKCanvasViewDelegate {
        var pencilKitView : PencilKitView
        
        /// 用于检测是否连接到 Apple Pencil 的辅助类
        private var pencilDetector: BOApplePencilReachability?
        
        init(_ pencilKitView: PencilKitView) {
            self.pencilKitView = pencilKitView
        }
        
        /// 开始检测 Apple Pencil. 若检测到 Apple Pencil，则关闭手写
        func beginPencilDetect() {
            self.pencilDetector = BOApplePencilReachability.init(didChangeClosure: { isPencilReachable in
                self.pencilKitView.allowsFingerDrawing = !isPencilReachable
                if isPencilReachable {
                    self.pencilKitView.showNotification("检测到 Apple Pencil")
                }
            })
        }
    }
}


struct GreetingCardView_Previews: PreviewProvider {
    static var previews: some View {
        GreetingCardView(clearAction: {
            
        })
//            .previewLayout(.fixed(width: 1112, height: 834)) // iPad Air 10.5
//                .previewLayout(.fixed(width: 1080, height: 810)) // iPad 7th
                .previewLayout(.fixed(width: 1194, height: 834)) // iPad Pro 11"
//                .previewLayout(.fixed(width: 1366, height: 1024)) // iPad Pro 12.9"
//                .previewLayout(.fixed(width: 1024, height: 768)) // iPad mini5, iPad Pro 9.7"
    }
}
