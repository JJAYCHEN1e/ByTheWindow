//
//  CoupletView.swift
//  ByTheWindow
//
//  Created by JJAYCHEN on 2020/2/19.
//  Copyright © 2020 JJAYCHEN. All rights reserved.
//

import SwiftUI
import Combine

struct CoupletView: View {
    @State var allowsFingerDrawing = true
    @State var clearAction: () -> () = {}
    @State var showNotificationInterface: (_ text: String) -> () = {_ in }
//    @State var leftCouletImage: UIImage?
    @State var coupletImageThumbnail: [UIImage] = [UIImage(named: "couplet-center")!, UIImage(named: "couplet")!, UIImage(named: "couplet")!]
    @State var prevIndex: Int = 1
    @State var currentIndex: Int = 1
    @State var changeSelectedCouplet: (_ : Int, _ : Int) -> () = {_,_ in }
    
    var body: some View {
        HStack(spacing: 0) {
            VStack {
                VStack {
                    Image(uiImage: coupletImageThumbnail[0])
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 250)
                        .padding(.bottom)
                        .onTapGesture {
                            self.prevIndex = self.currentIndex
                            self.currentIndex = 0
                            self.changeSelectedCouplet(self.prevIndex, 0)
                    }
                    
                    HStack{
                        Image(uiImage: coupletImageThumbnail[1])
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100)
                            .padding(.leading)
                            .onTapGesture {
                                self.prevIndex = self.currentIndex
                                self.currentIndex = 1
                                self.changeSelectedCouplet(self.prevIndex, 1)
                        }
                        
                        Spacer()
                        
                        Image(uiImage: coupletImageThumbnail[2])
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100)
                            .padding(.trailing)
                            .onTapGesture {
                                self.prevIndex = self.currentIndex
                                self.currentIndex = 2
                                self.changeSelectedCouplet(self.prevIndex, 2)
                        }
                    }
                }
            }
            .frame(width: screen.width / 3)
            
            ZStack {
                Color(#colorLiteral(red: 0.7019159198, green: 0.2200317383, blue: 0.185915947, alpha: 1))
                    .frame(maxWidth: .infinity)
                
                VStack {
                    ZStack {
                        coupletDrawingView(allowsFingerDrawing: $allowsFingerDrawing, clearAction: $clearAction, showNotification: $showNotificationInterface, coupletImageThumbnail: $coupletImageThumbnail, prevIndex: $prevIndex, currentIndex: $currentIndex, changeSelectedCouplet: $changeSelectedCouplet)
                            .clipShape(Rectangle())
                        
                        CoupletButtonView(allowsFingerDrawing: $allowsFingerDrawing, clearAction: $clearAction, showNoticationInterface: $showNotificationInterface)
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

struct coupletDrawingView: UIViewRepresentable {
    @Binding var allowsFingerDrawing: Bool
    @Binding var clearAction: () -> ()
    @Binding var showNotification: (_ text: String) -> ()
    @Binding var coupletImageThumbnail: [UIImage]
    @Binding var prevIndex: Int
    @Binding var currentIndex: Int
    @Binding var changeSelectedCouplet: (_ : Int, _ : Int) -> ()
    
    func makeCoordinator() -> Coordinator {
        let coordinator = Coordinator(self)
        coordinator.beginPencilDetect()
        return coordinator
    }
    
    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        var coupletDrawingView: coupletDrawingView!
        
        init(_ sideCoupletDrawingView: coupletDrawingView) {
            self.coupletDrawingView = sideCoupletDrawingView
        }
        
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
        
        var sideCoupletImageView: UIImageView!
        var centerCouletImageView: UIImageView!
        var sideCoupletCGView: StrokeCGView!
        var centerCoupletCGView: StrokeCGView!
        var containerView: UIView!
        var strokeCollection = [StrokeCollection(), StrokeCollection(), StrokeCollection()]
        var fingerStrokeRecognizer: StrokeGestureRecognizer!
        var pencilStrokeRecognizer: StrokeGestureRecognizer!
        var panGestureRecognizer: UIPanGestureRecognizer!
        var readyToGetThumbnail = false
        
        var currentIndex: Int {
            self.coupletDrawingView.currentIndex
        }
        
        var prevIndex: Int {
            self.coupletDrawingView.prevIndex
        }
    
        func getCoupletImageView(at index: Int) -> UIImageView {
            switch currentIndex {
            case 0:
                return self.centerCouletImageView
            case 1,2:
                return self.sideCoupletImageView
            default:
                return self.sideCoupletImageView
            }
        }
        
        func getCoupletCGView(at index: Int) -> StrokeCGView {
            switch currentIndex {
            case 0:
                return self.centerCoupletCGView
            case 1,2:
                return self.sideCoupletCGView
            default:
                return self.sideCoupletCGView
            }
        }
        
        var currentCoupletImageView: UIImageView {
            getCoupletImageView(at: currentIndex)
        }
        
        var currentCGView: StrokeCGView{
            getCoupletCGView(at: currentIndex)
        }
        
        var prevCoupletImageView: UIImageView {
            getCoupletImageView(at: prevIndex)
        }
        
        var prevCGView: StrokeCGView{
            getCoupletCGView(at: prevIndex)
        }
        
        /// Toggles hand-written mode for the app.
        /// - Tag: handWrittenMode
        var allowsFingerDrawing = true {
            didSet {
                DispatchQueue.main.async {
                    self.coupletDrawingView.allowsFingerDrawing = self.allowsFingerDrawing
                }
                
                if allowsFingerDrawing {
                    self.panGestureRecognizer.minimumNumberOfTouches = 2
                    if self.fingerStrokeRecognizer.view == nil {
                        currentCoupletImageView.addGestureRecognizer(fingerStrokeRecognizer)
                    }
                } else {
                    self.panGestureRecognizer.minimumNumberOfTouches = 1
                    if let view = fingerStrokeRecognizer.view {
                        view.removeGestureRecognizer(fingerStrokeRecognizer)
                    }
                }
            }
        }
        
        
        /// 用于检测是否连接到 Apple Pencil 的辅助类
        private var pencilDetector: BOApplePencilReachability?
        
        /// 开始检测 Apple Pencil. 若检测到 Apple Pencil，则关闭手写
        func beginPencilDetect() {
            self.pencilDetector = BOApplePencilReachability.init(didChangeClosure: { isPencilReachable in
                self.allowsFingerDrawing = !isPencilReachable
                if isPencilReachable {
                    self.coupletDrawingView.showNotification("检测到 Apple Pencil")
                }
            })
        }
        
        func getPanGesture() -> UIPanGestureRecognizer {
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
            panGesture.delegate = self
            panGesture.minimumNumberOfTouches = 2
            panGesture.maximumNumberOfTouches = 2
            
            self.panGestureRecognizer = panGesture
            
            return panGesture
        }
        
        func setCoupletViewInitPosition() {
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.sideCoupletImageView.center = CGPoint(x: self.sideCoupletImageView.center.x, y: 4 * self.squareUnit - 30*self.coupletScale)
            })
            
        }
        
        func getCoupletViewThumbnailImage() -> UIImage? {
            return getThumbnailImage(with: sideCoupletImageView)
        }
        
        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            let translation = gesture.translation(in: currentCoupletImageView)
            
            if currentIndex > 0 {
                sideCoupletImageView.center = CGPoint(
                    x: sideCoupletImageView.center.x,
                    y: sideCoupletImageView.center.y + translation.y
                )
                //            print(coupletImageView.center.y)
                gesture.setTranslation(.zero, in: sideCoupletImageView)
                
                guard gesture.state == .ended else {
                    return
                }
                
                var index = max(-2, floor((sideCoupletImageView.center.y + squareUnit*0.5 + 30*coupletScale) / squareUnit))
                
                index = min(4, index)
                
                let destinationY = index * squareUnit - 30*coupletScale
                
                //            print("个数\(index)")
                
                UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                    self.sideCoupletImageView.center = CGPoint(
                        x: self.sideCoupletImageView.center.x,
                        y: destinationY
                    )
                })
            } else {
                centerCouletImageView.center = CGPoint(
                    x: centerCouletImageView.center.x + translation.x,
                    y: centerCouletImageView.center.y
                )
                
                
                gesture.setTranslation(.zero, in: centerCouletImageView)
                
//                print(self.centerCouletImageView.center.x)
                
                guard gesture.state == .ended else {
                    return
                }
                
                // -317 141 600 1058
                // 1011-553= 458
//                print(coupletScale)
                let squareUnit = self.squareUnit * 0.9786324
                var index = max(-1, floor((centerCouletImageView.center.x + squareUnit*0.5 - 77.3931*coupletScale) / squareUnit))
                
                index = min(2, index)
//                print(index)
                let destinationX = index * squareUnit + 77.3931*coupletScale
                
                UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                    self.centerCouletImageView.center = CGPoint(
                        x: destinationX,
                        y: self.centerCouletImageView.center.y
                    )
                })
            }
            
            
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
            //
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
            sideCoupletImageView.addGestureRecognizer(recognizer)
            recognizer.coordinateSpaceView = sideCoupletCGView
            recognizer.isForPencil = isForPencil
            return recognizer
        }
        
        func receivedAllUpdatesForStroke(_ stroke: Stroke) {
            sideCoupletCGView.setNeedsDisplay(for: stroke)
            stroke.clearUpdateInfo()
        }
        
        /// Handles the gesture for `StrokeGestureRecognizer`.
        /// - Tag: strokeUpdate
        @objc
        func strokeUpdated(_ strokeGesture: StrokeGestureRecognizer) {
            readyToGetThumbnail = false
            var stroke: Stroke?
            if strokeGesture.state != .cancelled {
                stroke = strokeGesture.stroke
                if strokeGesture.state == .began ||
                    (strokeGesture.state == .ended && strokeCollection[currentIndex].activeStroke == nil) {
                    strokeCollection[currentIndex].activeStroke = stroke
                }
            } else {
                strokeCollection[currentIndex].activeStroke = nil
            }
            
            if let stroke = stroke {
                if strokeGesture.state == .ended {
                    if strokeGesture === pencilStrokeRecognizer {
                        // Make sure we get the final stroke update if needed.
                        stroke.receivedAllNeededUpdatesBlock = { [weak self] in
                            self?.receivedAllUpdatesForStroke(stroke)
                        }
                    }
                    strokeCollection[currentIndex].takeActiveStroke()
                    
//                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now().advanced(by: DispatchTimeInterval.seconds(3)), execute: {
//                        self.readyToGetThumbnail = true
//                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now().advanced(by: DispatchTimeInterval.seconds(3)), execute: {
//                            if self.readyToGetThumbnail {
//                                self.sideCoupletDrawingView.leftCouletImage = self.getCoupletViewThumbnailImage()
//                            }
//                        })
//                    })
                }
            }
            
            currentCGView.strokeCollection = strokeCollection[currentIndex]
        }
    }
    
    func makeUIView(context: Context) -> UIView {
        let coordinator = context.coordinator
        
        let sideCoupletImage = UIImage(named: "couplet")
        let centerCoupletImage = UIImage(named: "couplet-center")
        let squareImage = UIImage(named: "田字格")
        
        let sideCoupletImageView = UIImageView(image: sideCoupletImage)
        let centerCoupletImageView = UIImageView(image: centerCoupletImage)
        let squareImageView = UIImageView(image: squareImage)
        let containerView = UIView(frame: sideCoupletImageView.bounds)
        let sideCoupletCGView = StrokeCGView(frame: sideCoupletImageView.bounds)
        let centerCoupletCGView = StrokeCGView(frame: centerCoupletImageView.bounds)
        
//        coupletImageView.contentMode = .scaleAspectFill
        
        sideCoupletImageView.addSubview(sideCoupletCGView)
        sideCoupletImageView.isUserInteractionEnabled = true
        sideCoupletImageView.addGestureRecognizer(coordinator.getPanGesture())
        
        centerCoupletImageView.addSubview(centerCoupletCGView)
        centerCoupletImageView.isUserInteractionEnabled = true
//        centerCoupletImageView.addGestureRecognizer(coordinator.getPanGesture())
        
        containerView.addSubview(sideCoupletImageView)
        containerView.addSubview(squareImageView)
        
        sideCoupletImageView.translatesAutoresizingMaskIntoConstraints = false
        sideCoupletCGView.translatesAutoresizingMaskIntoConstraints = false
        centerCoupletImageView.translatesAutoresizingMaskIntoConstraints = false
        centerCoupletCGView.translatesAutoresizingMaskIntoConstraints = false
        
        // 配置 sideCoupletImageView 和 sideCoupletImageView 的大小
        // 配置 centerCoupletImageView 和 centerCoupletImageView 的大小
        NSLayoutConstraint.activate([
            sideCoupletCGView.centerXAnchor.constraint(equalTo: sideCoupletImageView.centerXAnchor),
            sideCoupletCGView.centerYAnchor.constraint(equalTo: sideCoupletImageView.centerYAnchor),
            sideCoupletCGView.widthAnchor.constraint(equalTo: sideCoupletImageView.widthAnchor),
            sideCoupletCGView.heightAnchor.constraint(equalTo: sideCoupletImageView.heightAnchor),
            centerCoupletCGView.centerXAnchor.constraint(equalTo: centerCoupletImageView.centerXAnchor),
            centerCoupletCGView.centerYAnchor.constraint(equalTo: centerCoupletImageView.centerYAnchor),
            centerCoupletCGView.widthAnchor.constraint(equalTo: centerCoupletImageView.widthAnchor),
            centerCoupletCGView.heightAnchor.constraint(equalTo: centerCoupletImageView.heightAnchor),
            
        ])
        
        
        // 配置 sideCoupletImageView 和 containerView 的大小
        NSLayoutConstraint.activate([
            sideCoupletImageView.widthAnchor.constraint(equalTo: containerView.widthAnchor),
            sideCoupletImageView.widthAnchor.constraint(equalTo: sideCoupletImageView.heightAnchor, multiplier: 278/1317),
            sideCoupletImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            sideCoupletImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
        ])
        
        // 配置田字格居中
        squareImageView.contentMode = .scaleAspectFit
        squareImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            squareImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            squareImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            squareImageView.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: squareScale)
        ])
        
        coordinator.sideCoupletImageView = sideCoupletImageView
        coordinator.centerCouletImageView = centerCoupletImageView
        coordinator.sideCoupletCGView = sideCoupletCGView
        coordinator.centerCoupletCGView = centerCoupletCGView
        coordinator.containerView = containerView
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now().advanced(by: DispatchTimeInterval.milliseconds(100)), execute: {
            coordinator.setCoupletViewInitPosition()
            self.clearAction = {
                coordinator.strokeCollection[self.currentIndex] = StrokeCollection()
                coordinator.currentCGView.strokeCollection = coordinator.strokeCollection[self.currentIndex]
            }
            
            self.changeSelectedCouplet = { from, to in
                if from != to {
                    if from + to == 3 {
                        // 都是侧联，只需要更换 Stroke.
                        coordinator.sideCoupletCGView.strokeCollection = coordinator.strokeCollection[to]
                    } else if to == 0 {
                        sideCoupletImageView.removeFromSuperview()
                        containerView.insertSubview(centerCoupletImageView, belowSubview: squareImageView)
                        centerCoupletCGView.strokeCollection = coordinator.strokeCollection[to]
                        centerCoupletImageView.addGestureRecognizer(coordinator.panGestureRecognizer)
                        
                        coordinator.fingerStrokeRecognizer.coordinateSpaceView = centerCoupletCGView
                        coordinator.pencilStrokeRecognizer.coordinateSpaceView = centerCoupletCGView
                        if let view = coordinator.fingerStrokeRecognizer.view {
                            view.removeGestureRecognizer(coordinator.fingerStrokeRecognizer)
                            centerCoupletImageView.addGestureRecognizer(coordinator.fingerStrokeRecognizer)
                        }
                        
                        if let view = coordinator.pencilStrokeRecognizer.view {
                            view.removeGestureRecognizer(coordinator.pencilStrokeRecognizer)
                            centerCoupletImageView.addGestureRecognizer(coordinator.pencilStrokeRecognizer)
                        }
                        
                        // 配置 centerCoupletImageView 和 containerView 的大小
                        NSLayoutConstraint.activate([
                            centerCoupletImageView.heightAnchor.constraint(equalTo: containerView.widthAnchor),
                            centerCoupletImageView.widthAnchor.constraint(equalTo: centerCoupletImageView.heightAnchor, multiplier: 1080/403),
                            centerCoupletImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: screen.width * 0.055),
                            centerCoupletImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
                        ])
                    } else {
                        centerCoupletImageView.removeFromSuperview()
                        containerView.insertSubview(sideCoupletImageView, belowSubview: squareImageView)
                        sideCoupletCGView.strokeCollection = coordinator.strokeCollection[to]
                        sideCoupletImageView.addGestureRecognizer(coordinator.panGestureRecognizer)
                        
                        coordinator.fingerStrokeRecognizer.coordinateSpaceView = sideCoupletCGView
                        coordinator.pencilStrokeRecognizer.coordinateSpaceView = sideCoupletCGView
                        if let view = coordinator.fingerStrokeRecognizer.view {
                            view.removeGestureRecognizer(coordinator.fingerStrokeRecognizer)
                            sideCoupletImageView.addGestureRecognizer(coordinator.fingerStrokeRecognizer)
                        }
                        
                        if let view = coordinator.pencilStrokeRecognizer.view {
                            view.removeGestureRecognizer(coordinator.pencilStrokeRecognizer)
                            sideCoupletImageView.addGestureRecognizer(coordinator.pencilStrokeRecognizer)
                        }
                        
                        // 配置 sideCoupletImageView 和 containerView 的大小
                        NSLayoutConstraint.activate([
                            sideCoupletImageView.widthAnchor.constraint(equalTo: containerView.widthAnchor),
                            sideCoupletImageView.widthAnchor.constraint(equalTo: sideCoupletImageView.heightAnchor, multiplier: 278/1317),
                            sideCoupletImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                            sideCoupletImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
                        ])
                    }
                }
            }
//            self.leftCouletImage = coordinator.getCoupletViewThumbnailImage()
        })
        
        coordinator.fingerStrokeRecognizer = coordinator.setupStrokeGestureRecognizer(isForPencil: false)
        coordinator.pencilStrokeRecognizer = coordinator.setupStrokeGestureRecognizer(isForPencil: true)
        
        return containerView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.allowsFingerDrawing = allowsFingerDrawing
    }
}

struct CoupletButtonView: View {
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
            HStack {
                ButtonWithBlurBackground(
                    actions: [{
                        self.allowsFingerDrawing.toggle()
                        self.showNotification(self.allowsFingerDrawing ? "允许触控书写" : "关闭触控书写")
                    }],
                    imageName: ["hand.draw"],
                    colors: [allowsFingerDrawing ? Color.blue : Color.white.opacity(0.9)]
                )
                
                Spacer()
                
                TextWithBlurBackground(text: $text)
                    .offset(y: notificationOffset)
                    .animation(.spring())
                    .onAppear() {
                        self.showNotification("单击左侧缩略图可切换对联")
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

