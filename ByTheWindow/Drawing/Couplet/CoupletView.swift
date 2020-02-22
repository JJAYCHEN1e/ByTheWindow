//
//  CoupletView.swift
//  ByTheWindow
//
//  Created by JJAYCHEN on 2020/2/19.
//  Copyright © 2020 JJAYCHEN. All rights reserved.
//

import SwiftUI

struct CoupletView: View {
    var body: some View {
        HStack(spacing: 0) {
            VStack {
                Text("")
            }
            .frame(width: screen.width / 3)
            
            ZStack {
                Color(#colorLiteral(red: 0.7019159198, green: 0.2200317383, blue: 0.185915947, alpha: 1))
                    .frame(maxWidth: .infinity)
                
                VStack {
                    ZStack {
                        SideCoupletDrawingView()
                        
                        VStack {
                            HStack {
                                ButtonWithBlurBackground(
                                    actions: [
                                        {
                                            //                                        self.allowsDrawing.toggle()
                                            //                                        self.showNotification(self.allowsDrawing ? "开启书写功能" : "关闭书写功能")
                                        },
                                        {
                                            //                                        if self.allowsDrawing {
                                            //                                            self.allowsFingerDrawing.toggle()
                                            //                                            self.showNotification(self.allowsFingerDrawing ? "允许触控书写" : "关闭触控书写")
                                            //                                        }
                                        }
                                    ],
                                    imageName: [ "pencil.and.outline", "hand.draw",],
                                    frameWidth: 120,
                                    colors: [Color.blue, Color.blue],
                                    //                                colors: [allowsDrawing ? Color.blue : Color.white.opacity(0.9), allowsDrawing ? (allowsFingerDrawing ? Color.blue : Color.white.opacity(0.9)) : Color.white.opacity(0.3)],
                                    size: 34
                                )
                                
                                Spacer()
                                
                                ButtonWithBlurBackground(actions: [{
                                    //                        self.showNotification("书写内容已清空")
                                    //                        self.clearAction()
                                    }], imageName: ["trash"])
                                
                            }
                            .padding()
                            
                            Spacer()
                        }
                    }
                }
            }
            .frame(width: screen.width * 2 / 3)
        }
        .edgesIgnoringSafeArea(.all)
    }
}


// 原图大小 407*1865
// 正方形大小 257*257
let squareScale: CGFloat = 0.6313
let topOffset: CGFloat = 340 / 834 * screen.height

struct SideCoupletDrawingView: UIViewRepresentable {
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        var squareUnit: CGFloat {
            get {
                squareScale * containerView.frame.width
            }
        }
        
        var coupletScale: CGFloat {
            get {
                containerView.frame.width / 407
            }
        }
        
        var coupletImageView: UIImageView!
        var cgView: StrokeCGView!
        var containerView: UIView!
        var strokeCollection = StrokeCollection()
        var fingerStrokeRecognizer: StrokeGestureRecognizer!
        var pencilStrokeRecognizer: StrokeGestureRecognizer!
        
        func getPanGesture() -> UIPanGestureRecognizer {
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
            panGesture.delegate = self
            panGesture.minimumNumberOfTouches = 1
            panGesture.maximumNumberOfTouches = 2
            
            return panGesture
        }
        
        func setCoupletViewInitPosition() {
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.coupletImageView.center = CGPoint(x: self.coupletImageView.center.x, y: 4 * self.squareUnit - 30*self.coupletScale)
            })
            
        }
        
        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            let translation = gesture.translation(in: coupletImageView)
            
            coupletImageView.center = CGPoint(
                x: coupletImageView.center.x,
                y: coupletImageView.center.y + translation.y
            )
            //            print(coupletImageView.center.y)
            gesture.setTranslation(.zero, in: coupletImageView)
            
            guard gesture.state == .ended else {
                return
            }
            
            var index = max(-2, floor((coupletImageView.center.y + squareUnit*0.5 + 30*coupletScale) / squareUnit))
            
            index = min(4, index)
            
            let destinationY = index * squareUnit - 30*coupletScale
            
            //            print("个数\(index)")
            
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.coupletImageView.center = CGPoint(
                    x: self.coupletImageView.center.x,
                    y: destinationY
                )
            })
            
            //            UIView.animate(
            //                withDuration: 0.5,
            //                delay: 0,
            //                options: .curveEaseOut,
            //                animations: {
            //                    self.coupletImageView.center = CGPoint(
            //                        x: self.coupletImageView.center.x,
            //                        y: destinationY
            //                    )
            //            })
            //            print(coupletImageView.center.y)
            //            print("应该在: \(coupletImageView.center.y - squareUnit*0.5) 到 \(coupletImageView.center.y + squareUnit*0.5) 之间")
            
            //            let unit = squareUnit
            //            print("containerView.width: \(containerView.frame.width), containerView.height: \(containerView.frame.height)")
            //            print("coupletImageView.width: \(coupletImageView.frame.width), coupletImageView.height: \(coupletImageView.frame.height)")
            //            print(containerView.center.x)
            //            print(containerView.center.y)
            //            print(coupletImageView.center.y)
            //            print(squareUnit)
        }
        
        // MARK: Stroke things.
        /// A helper method that creates stroke gesture recognizers.
        /// - Tag: setupStrokeGestureRecognizer
        func setupStrokeGestureRecognizer(isForPencil: Bool) -> StrokeGestureRecognizer {
            let recognizer = StrokeGestureRecognizer(target: self, action: #selector(strokeUpdated(_:)))
            recognizer.cancelsTouchesInView = false
            coupletImageView.addGestureRecognizer(recognizer)
            recognizer.coordinateSpaceView = cgView
            recognizer.isForPencil = isForPencil
            return recognizer
        }
        
        func receivedAllUpdatesForStroke(_ stroke: Stroke) {
            cgView.setNeedsDisplay(for: stroke)
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
            
            cgView.strokeCollection = strokeCollection
        }
    }
    
    func makeUIView(context: Context) -> UIView {
        let coordinator = context.coordinator
        
        let coupletImage = UIImage(named: "couplet")
        let squareImage = UIImage(named: "田字格")
        
        let coupletImageView = UIImageView(image: coupletImage)
        let squareImageView = UIImageView(image: squareImage)
        let containerView = UIView(frame: coupletImageView.bounds)
        let cgView = StrokeCGView(frame: coupletImageView.bounds)
        
//        coupletImageView.contentMode = .scaleAspectFill
        
        coupletImageView.addSubview(cgView)
        coupletImageView.isUserInteractionEnabled = true
        coupletImageView.addGestureRecognizer(coordinator.getPanGesture())
        
        containerView.addSubview(coupletImageView)
        containerView.addSubview(squareImageView)
        
        coupletImageView.translatesAutoresizingMaskIntoConstraints = false
        cgView.translatesAutoresizingMaskIntoConstraints = false
        
        // 配置 coupletImageView 和 cgView 的大小
        NSLayoutConstraint.activate([
            cgView.centerXAnchor.constraint(equalTo: coupletImageView.centerXAnchor),
            cgView.centerYAnchor.constraint(equalTo: coupletImageView.centerYAnchor),
            cgView.widthAnchor.constraint(equalTo: coupletImageView.widthAnchor),
            cgView.heightAnchor.constraint(equalTo: coupletImageView.heightAnchor),
            coupletImageView.widthAnchor.constraint(equalTo: containerView.widthAnchor),
            coupletImageView.widthAnchor.constraint(equalTo: coupletImageView.heightAnchor, multiplier: 278/1317),
            coupletImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            coupletImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
        ])
        
        // 配置田字格居中
        squareImageView.contentMode = .scaleAspectFit
        squareImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            squareImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            squareImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            squareImageView.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: squareScale)
        ])
        
        coordinator.coupletImageView = coupletImageView
        coordinator.cgView = cgView
        coordinator.containerView = containerView
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now().advanced(by: DispatchTimeInterval.milliseconds(100)), execute: {
            coordinator.setCoupletViewInitPosition()
        })
        
//        coordinator.fingerStrokeRecognizer = coordinator.setupStrokeGestureRecognizer(isForPencil: false)
//        coordinator.pencilStrokeRecognizer = coordinator.setupStrokeGestureRecognizer(isForPencil: true)
        
        return containerView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
}


struct CoupletView_Previews: PreviewProvider {
    static var previews: some View {
        CoupletView()
            .previewLayout(.fixed(width: 1112, height: 834)) // iPad Air 10.5
        //            .previewLayout(.fixed(width: 1080, height: 810)) // iPad 7th
        //            .previewLayout(.fixed(width: 1194, height: 834)) // iPad Pro 11"
        //            .previewLayout(.fixed(width: 1366, height: 1024)) // iPad Pro 12.9"
        //            .previewLayout(.fixed(width: 1024, height: 768)) // iPad mini5, iPad Pro 9.7"
    }
}
