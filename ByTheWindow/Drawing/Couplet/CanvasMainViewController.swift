/*
 See LICENSE folder for this sample’s licensing information.
 
 Abstract:
 The primary view controller.
 */

import UIKit
import SwiftUI

class CanvasMainViewController: UIViewController {
    
    var leftCGView: StrokeCGView!
    
    var fingerStrokeRecognizer: StrokeGestureRecognizer!
    var pencilStrokeRecognizer: StrokeGestureRecognizer!
    
    @IBOutlet var leftScrollView: UIScrollView!
    @IBOutlet weak var leftCoupletImageView: UIImageView!
    
    @IBOutlet weak var handWrittenModeButton: UIButton!
    
    var strokeCollection = StrokeCollection()
    
    /// 清空笔迹
    @IBAction func clearButtonAction(_ sender: AnyObject) {
        self.strokeCollection = StrokeCollection()
        leftCGView.strokeCollection = self.strokeCollection
    }
    
    /// Toggles hand-written mode for the app.
    /// - Tag: handWrittenMode
    var handWrittenMode = true {
        didSet {
            if handWrittenMode {
                leftScrollView.panGestureRecognizer.minimumNumberOfTouches = 2
                handWrittenModeButton.setImage(UIImage(systemName: "hand.raised"), for: .normal)
                if fingerStrokeRecognizer.view == nil {
                    leftScrollView.addGestureRecognizer(fingerStrokeRecognizer)
                }
            } else {
                leftScrollView.panGestureRecognizer.minimumNumberOfTouches = 1
                handWrittenModeButton.setImage(UIImage(systemName: "hand.raised.slash"), for: .normal)
                if let view = fingerStrokeRecognizer.view {
                    view.removeGestureRecognizer(fingerStrokeRecognizer)
                }
            }
        }
    }
    
    @IBAction func handWrittenButtonClicked(_ sender: AnyObject?) {
        handWrittenMode.toggle()
    }
    
    /// 用于检测是否连接到 Apple Pencil 的辅助类
    private var pencilDetector: BOApplePencilReachability?
    
    /// Prepare the drawing canvas.
    /// - Tag: CanvasMainViewController-viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// 为左边对联设置可以绘制的 leftCGView
        let leftCGView = StrokeCGView(frame: leftCoupletImageView.bounds)
        leftCGView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.leftCGView = leftCGView
        leftScrollView.addSubview(leftCGView)
        
        // We put our UI elements on top of the scroll view, so we don't want any of the
        // delay or cancel machinery in place.
        leftScrollView.delaysContentTouches = false
        
//        let canvasContainerView = CanvasContainerView(canvasSize: cgView.frame.size)
//        canvasContainerView.documentView = cgView
//        self.canvasContainerView = canvasContainerView
//        view.contentSize = canvasContainerView.frame.size
//        view.contentOffset = CGPoint(x: (canvasContainerView.frame.width - view.bounds.width) / 2.0,
//                                           y: (canvasContainerView.frame.height - view.bounds.height) / 2.0)
//        view.addSubview(canvasContainerView)
//        view.backgroundColor = canvasContainerView.backgroundColor
//        view.maximumZoomScale = 3.0
//        view.minimumZoomScale = 0.5
//        view.panGestureRecognizer.allowedTouchTypes = [UITouch.TouchType.direct.rawValue as NSNumber]
//        view.pinchGestureRecognizer?.allowedTouchTypes = [UITouch.TouchType.direct.rawValue as NSNumber]
        
        self.fingerStrokeRecognizer = setupStrokeGestureRecognizer(isForPencil: false)
        self.pencilStrokeRecognizer = setupStrokeGestureRecognizer(isForPencil: true)
        
        /// 默认支持手写。若检测到 Apple Pencil，则关闭手写
        handWrittenMode = true
        self.pencilDetector = BOApplePencilReachability.init(didChangeClosure: { isPencilReachable in
            self.handWrittenMode = !isPencilReachable
        })
    }
    
    /// A helper method that creates stroke gesture recognizers.
    /// - Tag: setupStrokeGestureRecognizer
    func setupStrokeGestureRecognizer(isForPencil: Bool) -> StrokeGestureRecognizer {
        let recognizer = StrokeGestureRecognizer(target: self, action: #selector(strokeUpdated(_:)))
//        recognizer.delegate = self
        recognizer.cancelsTouchesInView = false
        leftScrollView.addGestureRecognizer(recognizer)
        recognizer.coordinateSpaceView = leftCGView
        recognizer.isForPencil = isForPencil
        return recognizer
    }
    
    func receivedAllUpdatesForStroke(_ stroke: Stroke) {
        leftCGView.setNeedsDisplay(for: stroke)
        stroke.clearUpdateInfo()
    }
    
    /// Handles the gesture for `StrokeGestureRecognizer`.
    /// - Tag: strokeUpdate
    @objc
    func strokeUpdated(_ strokeGesture: StrokeGestureRecognizer) {
        var stroke: Stroke?
        if strokeGesture.state != .cancelled {
            stroke = strokeGesture.stroke
            if strokeGesture.state == .began ||
                (strokeGesture.state == .ended && strokeCollection.activeStroke == nil) {
                strokeCollection.activeStroke = stroke
            }
        } else {
            strokeCollection.activeStroke = nil
        }
        
        if let stroke = stroke {
            if strokeGesture.state == .ended {
                if strokeGesture === pencilStrokeRecognizer {
                    // Make sure we get the final stroke update if needed.
                    stroke.receivedAllNeededUpdatesBlock = { [weak self] in
                        self?.receivedAllUpdatesForStroke(stroke)
                    }
                }
                strokeCollection.takeActiveStroke()
            }
        }
        
        leftCGView.strokeCollection = strokeCollection
    }
}

struct CanvasMainViewControllerRepresentation: UIViewControllerRepresentable {
    
    func makeUIViewController(
        context: UIViewControllerRepresentableContext
        <CanvasMainViewControllerRepresentation>) -> CanvasMainViewController {
        UIStoryboard(name: "Canvas", bundle: nil)
            .instantiateViewController(withIdentifier: "Canvas")
            as! CanvasMainViewController
    }
    
    func updateUIViewController(_ uiViewController: CanvasMainViewController,
                                context: UIViewControllerRepresentableContext
        <CanvasMainViewControllerRepresentation>) {
        
    }
    
}
