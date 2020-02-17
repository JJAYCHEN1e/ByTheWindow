//
//  GreetingCardViewController.swift
//  ByTheWindow
//
//  Created by JJAYCHEN on 2020/2/6.
//  Copyright © 2020 JJAYCHEN. All rights reserved.
//

import UIKit
import PencilKit
import SwiftUI

class GreetingCardViewController: UIViewController, PKCanvasViewDelegate {
    
    @IBOutlet var canvasView: PKCanvasView!
    
    @IBOutlet weak var handWrittenModeButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer!
    @IBOutlet var pinchGestureRecognizer: UIPinchGestureRecognizer!
    @IBOutlet var rotationGestureRecognizer: UIRotationGestureRecognizer!
    
    /// 用来控制缩放的边界
    private var minScale: CGFloat = 1.0
    private var maxScale: CGFloat = 2.0
    private var currentScale: CGFloat = 1.0
    
    /// 若用户连接到 Apple Pencil，则会自动关闭手写，用户也可以选择打开手写
    /// 在开和关的同时相应一些事件：1. 更改设置图标 2. 更改 Pan 手势的指数
    private var allowsFingerDrawing: Bool = true {
        didSet {
            self.canvasView.allowsFingerDrawing = allowsFingerDrawing
            if allowsFingerDrawing {
                handWrittenModeButton.setImage(UIImage(systemName: "hand.raised"), for: .normal)
                panGestureRecognizer.minimumNumberOfTouches = 2
            } else {
                handWrittenModeButton.setImage(UIImage(systemName: "hand.raised.slash"), for: .normal)
                panGestureRecognizer.minimumNumberOfTouches = 1
            }
        }
    }
    
    @IBAction func handWrittenButtonClicked() {
        self.allowsFingerDrawing.toggle()
    }
    
    /// 用于检测是否连接到 Apple Pencil 的辅助类
    private var pencilDetector: BOApplePencilReachability?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        handWrittenModeButton.superview?.addBlurInSubviewWith(cornerRadius: 15)
        clearButton.superview?.addBlurInSubviewWith(cornerRadius: 15)
        shareButton.superview?.addBlurInSubviewWith(cornerRadius: 15)
        
        /// 一定要设置 delegate，否则 gestureRecognizer(
        ///            _ gestureRecognizer: UIGestureRecognizer,
        ///            shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer)
        /// 不生效。或者也可以在 StoryBoard 中设置。
        panGestureRecognizer.delegate = canvasView
        pinchGestureRecognizer.delegate = canvasView
        rotationGestureRecognizer.delegate = canvasView

        /// 默认是允许手写的，所以 Pan 手势应该是两根手指. 并且限制触控类行为手指
        panGestureRecognizer.minimumNumberOfTouches = 2
        panGestureRecognizer.allowedTouchTypes = [UITouch.TouchType.direct.rawValue as NSNumber]
        
        /// 若检测到 Apple Pencil，则关闭手写
        self.pencilDetector = BOApplePencilReachability.init(didChangeClosure: { isPencilReachable in
            self.allowsFingerDrawing = !isPencilReachable
        })
        
        /// 设置 PencilKit
        if let window = UIApplication.shared.windows.first, let toolPicker = PKToolPicker.shared(for: window) {
            canvasView.delegate = self
            toolPicker.setVisible(true, forFirstResponder: canvasView)
            toolPicker.addObserver(canvasView)
            
            toolPicker.selectedTool = PKInkingTool(.pen, color: .black, width: 30)
            canvasView.becomeFirstResponder()
        }
    }
    
    @IBAction func clearButtonClicked() {
        canvasView.drawing = PKDrawing()
    }
    
    // MARK: Handle Gestures
    @IBAction func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        // gesture.scale 是增量的
        let scale = gesture.scale * currentScale
        if scale <= maxScale, scale >= minScale {
            canvasView.transform = canvasView.transform.scaledBy(x: gesture.scale, y: gesture.scale)
            currentScale = scale
        }
        
        gesture.scale = 1
    }
    
    @IBAction func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: canvasView)
        
//        // 由于存在缩放，在 Pan 手势处理时应该 * currentScale
//        canvasView.center = CGPoint(
//            x: canvasView.center.x + translation.x * currentScale,
//            y: canvasView.center.y + translation.y * currentScale
//        )
        
        // 上面的代码会和 Rotation 有冲突，改用 translatedBy 函数。
        // 且不用考虑缩放尺寸。
        canvasView.transform = canvasView.transform.translatedBy(
            x: translation.x,
            y: translation.y
        )
        
        gesture.setTranslation(.zero, in: canvasView)
    }
    
    @IBAction func handleRotation(_ gesture: UIRotationGestureRecognizer) {
        canvasView.transform = canvasView.transform.rotated(
          by: gesture.rotation
        )
        
        gesture.rotation = 0
    }
}

// MARK: Gesture Delegate
extension PKCanvasView: UIGestureRecognizerDelegate {
    /// 允许各个 GestureRecognizer 共同工作。
    public func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        return true
    }
}

struct PencilKitView: UIViewRepresentable {
    @Binding var allowsDrawing: Bool
    @Binding var allowsFingerDrawing: Bool
    @Binding var clearAction: () -> ()
    
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
            })
        }
    }
}
