//
//  CoupletView.swift
//  ByTheWindow
//
//  Created by JJAYCHEN on 2020/2/19.
//  Copyright © 2020 JJAYCHEN. All rights reserved.
//

import SwiftUI
import Combine

let sideCoupletImage = UIImage(named: "couplet")!
let centerCoupletImage = UIImage(named: "couplet-center")!


struct CoupletView: View {
    @State var allowsFingerDrawing = true
    @State var clearAction: () -> () = {}
    @State var undoAction: () -> () = {}
    @State var redoAction: () -> () = {}
    @State var showNotificationInterface: (_ text: String) -> () = {_ in }
    @State var prevIndex: Int = 1
    @State var currentIndex: Int = 1
    @State var changeSelectedCouplet: (_ : Int, _ : Int) -> () = {_,_ in }
    @State var redoable = false
    @State var undoable = false
    
    @State var cgImages: [UIImage] = [centerCoupletImage, sideCoupletImage, sideCoupletImage]
    
    @State var centerSize = CGRect.zero
    @State var leftSize = CGRect.zero
    @State var rightSize = CGRect.zero
    
    var body: some View {
        HStack(spacing: 0) {
            VStack {
                Spacer()
                
                VStack {
                    ZStack {
                        Image(uiImage: centerCoupletImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .background(GeometryGetter(rect: $centerSize))
                        
                        Image(uiImage: cgImages[0])
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: centerSize.height)
                            .onTapGesture {
                                self.prevIndex = self.currentIndex
                                self.currentIndex = 0
                                self.changeSelectedCouplet(self.prevIndex, 0)
                        }
                    }
                    .frame(width: 250)
                    .padding(.bottom)
                    
                    
                    HStack{
                        ZStack(alignment: .top) {
                            Image(uiImage: sideCoupletImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .background(GeometryGetter(rect: $leftSize))
                            
                            Image(uiImage: cgImages[1])
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: leftSize.height)
                                .onTapGesture {
                                    self.prevIndex = self.currentIndex
                                    self.currentIndex = 1
                                    self.changeSelectedCouplet(self.prevIndex, 1)
                            }
                        }
                        .frame(width: 100)
                        .padding(.leading)
                        
                        Spacer()
                        
                        ZStack(alignment: .top) {
                            Image(uiImage: sideCoupletImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .background(GeometryGetter(rect: $rightSize))
                            
                            Image(uiImage: cgImages[2])
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: rightSize.height)
                                .onTapGesture {
                                    self.prevIndex = self.currentIndex
                                    self.currentIndex = 2
                                    self.changeSelectedCouplet(self.prevIndex, 2)
                            }
                        }
                        .frame(width: 100)
                        .padding(.trailing)
                        
                    }
                }
                
                Spacer()
            }
            .frame(width: screen.width / 3)
            
            ZStack {
                Color(#colorLiteral(red: 0.7019159198, green: 0.2200317383, blue: 0.185915947, alpha: 1))
                    .frame(maxWidth: .infinity)
                
                VStack {
                    ZStack {
                        CoupletDrawingView(allowsFingerDrawing: $allowsFingerDrawing, clearAction: $clearAction, undoAction: $undoAction, redoAction: $redoAction, showNotification: $showNotificationInterface, prevIndex: $prevIndex, currentIndex: $currentIndex, changeSelectedCouplet: $changeSelectedCouplet, undoable: $undoable, redoable: $redoable, cgImages: $cgImages)
                            .clipShape(Rectangle())
                        
                        CoupletButtonView(allowsFingerDrawing: $allowsFingerDrawing, clearAction: $clearAction,
                                          undoAction: $undoAction, redoAction: $redoAction, showNoticationInterface: $showNotificationInterface, undoable: $undoable, redoable: $redoable)
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

struct CoupletDrawingView: UIViewRepresentable {
    @Binding var allowsFingerDrawing: Bool
    @Binding var clearAction: () -> ()
    @Binding var undoAction: () -> ()
    @Binding var redoAction: () -> ()
    @Binding var showNotification: (_ text: String) -> ()
    @Binding var prevIndex: Int
    @Binding var currentIndex: Int
    @Binding var changeSelectedCouplet: (_ : Int, _ : Int) -> ()
    @Binding var undoable: Bool
    @Binding var redoable: Bool
    
    @Binding var cgImages: [UIImage]
    
    func makeCoordinator() -> Coordinator {
        let coordinator = Coordinator(self)
        coordinator.beginPencilDetect()
        return coordinator
    }
    
    class Coordinator: NSObject, UIGestureRecognizerDelegate, StrokeCollectionDelegate {
        var coupletDrawingView: CoupletDrawingView!
        
        init(_ coupletDrawingView: CoupletDrawingView) {
            self.coupletDrawingView = coupletDrawingView
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
        var centerCoupletImageView: UIImageView!
        var sideCoupletCGView: StrokeCGView!
        var centerCoupletCGView: StrokeCGView!
        var containerView: UIView!
        var strokeCollections = [
            [StrokeCollection(), StrokeCollection(), StrokeCollection(), StrokeCollection()],
            [StrokeCollection(), StrokeCollection(), StrokeCollection(), StrokeCollection(), StrokeCollection(), StrokeCollection(), StrokeCollection()],
            [StrokeCollection(), StrokeCollection(), StrokeCollection(), StrokeCollection(), StrokeCollection(), StrokeCollection(), StrokeCollection()]
        ]
        var fingerStrokeRecognizer: StrokeGestureRecognizer!
        var pencilStrokeRecognizer: StrokeGestureRecognizer!
        var panGestureRecognizer: UIPanGestureRecognizer!
        
        var characterIndex = 0
        
        var redoable: Bool = false{
            didSet {
                DispatchQueue.main.async {
                    self.coupletDrawingView.redoable = self.redoable
                }
            }
        }
        
        var undoable: Bool = false {
            didSet {
                DispatchQueue.main.async {
                    self.coupletDrawingView.undoable = self.undoable
                }
            }
        }
        
        var currentIndex: Int {
            get {
                self.coupletDrawingView.currentIndex
            }
        }
        
        var prevIndex: Int {
            self.coupletDrawingView.prevIndex
        }
        
        func getCoupletImage(at index: Int) -> UIImage {
            switch currentIndex {
            case 0:
                return centerCoupletImage
            case 1,2:
                return sideCoupletImage
            default:
                return sideCoupletImage
            }
        }
        
        func getCoupletImageView(at index: Int) -> UIImageView {
            switch currentIndex {
            case 0:
                return self.centerCoupletImageView
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
        
        var currentCoupletImage: UIImage {
            getCoupletImage(at: currentIndex)
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
        
        func setAllowsFingerDrawing(_ allowsFingerDrawing: Bool) {
            
            DispatchQueue.main.async {
                if allowsFingerDrawing {
                    self.panGestureRecognizer.minimumNumberOfTouches = 2
                    if self.fingerStrokeRecognizer.view == nil {
                        self.currentCoupletImageView.addGestureRecognizer(self.fingerStrokeRecognizer)
                    }
                } else {
                    self.panGestureRecognizer.minimumNumberOfTouches = 1
                    if let view = self.fingerStrokeRecognizer.view {
                        view.removeGestureRecognizer(self.fingerStrokeRecognizer)
                    }
                }
            }
            
            if self.coupletDrawingView.allowsFingerDrawing != allowsFingerDrawing {
                DispatchQueue.main.async {
                    self.coupletDrawingView.allowsFingerDrawing = allowsFingerDrawing
                }
            }
        }
        
        
        /// 用于检测是否连接到 Apple Pencil 的辅助类
        private var pencilDetector: BOApplePencilReachability?
        
        /// 开始检测 Apple Pencil. 若检测到 Apple Pencil，则关闭手写
        func beginPencilDetect() {
            self.pencilDetector = BOApplePencilReachability.init(didChangeClosure: { isPencilReachable in
                self.setAllowsFingerDrawing(!isPencilReachable)
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
                
                self.characterIndex = 6 - (Int(index) + 2)
                currentCGView.characterIndex = self.characterIndex
                self.strokeCollections[self.currentIndex][self.characterIndex].delegate = self
                
                let destinationY = index * squareUnit - 30*coupletScale
                
                //            print("个数\(index)")
                
                UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                    self.sideCoupletImageView.center = CGPoint(
                        x: self.sideCoupletImageView.center.x,
                        y: destinationY
                    )
                })
            } else {
                centerCoupletImageView.center = CGPoint(
                    x: centerCoupletImageView.center.x + translation.x,
                    y: centerCoupletImageView.center.y
                )
                
                
                gesture.setTranslation(.zero, in: centerCoupletImageView)
                
                //                print(self.centerCouletImageView.center.x)
                
                guard gesture.state == .ended else {
                    return
                }
                
                // -317 141 600 1058
                // 1011-553= 458
                //                print(coupletScale)
                let squareUnit = self.squareUnit * 0.9786324
                var index = max(-1, floor((centerCoupletImageView.center.x + squareUnit*0.5 - 77.3931*coupletScale) / squareUnit))
                
                index = min(2, index)
                //                print(index)
                let destinationX = index * squareUnit + 77.3931*coupletScale
                
                self.characterIndex = 3 - (Int(index) + 1)
                currentCGView.characterIndex = self.characterIndex
                self.strokeCollections[self.currentIndex][self.characterIndex].delegate = self
                
                UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                    self.centerCoupletImageView.center = CGPoint(
                        x: destinationX,
                        y: self.centerCoupletImageView.center.y
                    )
                })
            }
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
            var stroke: Stroke?
            if strokeGesture.state != .cancelled {
                stroke = strokeGesture.stroke
                if strokeGesture.state == .began ||
                    (strokeGesture.state == .ended && strokeCollections[currentIndex][characterIndex].activeStroke == nil) {
                    strokeCollections[currentIndex][characterIndex].activeStroke = stroke
                }
            } else {
                strokeCollections[currentIndex][characterIndex].activeStroke = nil
            }
            
            if let stroke = stroke {
                if strokeGesture.state == .ended {
                    if strokeGesture === pencilStrokeRecognizer {
                        // Make sure we get the final stroke update if needed.
                        stroke.receivedAllNeededUpdatesBlock = { [weak self] in
                            self?.receivedAllUpdatesForStroke(stroke)
                        }
                    }
                    strokeCollections[currentIndex][characterIndex].takeActiveStroke()
                    currentCGView.readyGetThumbnail = 0

                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now().advanced(by: .milliseconds(300))) {
                        self.coupletDrawingView.cgImages[self.currentIndex] = self.currentCGView.getThumbnail()
                    }
                }
            }
            currentCGView.strokeCollections = strokeCollections[currentIndex]
            currentCGView.readyGetThumbnail += 1
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
            sideCoupletImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: screen.width * 0.055)
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
        coordinator.centerCoupletImageView = centerCoupletImageView
        coordinator.sideCoupletCGView = sideCoupletCGView
        coordinator.centerCoupletCGView = centerCoupletCGView
        coordinator.containerView = containerView
        
        coordinator.strokeCollections[self.currentIndex][coordinator.characterIndex].delegate = coordinator
        
        DispatchQueue.main.async{
            self.clearAction = {
                coordinator.strokeCollections[self.currentIndex][coordinator.characterIndex] = StrokeCollection()
                coordinator.currentCGView.strokeCollections[coordinator.characterIndex] = coordinator.strokeCollections[self.currentIndex][coordinator.characterIndex]
                
                coordinator.coupletDrawingView.cgImages[self.currentIndex] = coordinator.currentCoupletImage
            }
            
            self.undoAction = {
                coordinator.strokeCollections[self.currentIndex][coordinator.characterIndex].undo()
                coordinator.currentCGView.strokeCollections = coordinator.strokeCollections[self.currentIndex]
            }
            
            self.redoAction = {
                coordinator.strokeCollections[self.currentIndex][coordinator.characterIndex].redo()
                coordinator.currentCGView.strokeCollections = coordinator.strokeCollections[self.currentIndex]
            }
            
            self.changeSelectedCouplet = { from, to in
                if from != to {
                    if from + to == 3 {
                        // 都是侧联，只需要更换 Stroke.
                        coordinator.sideCoupletCGView.strokeCollections = coordinator.strokeCollections[to]
                        coordinator.strokeCollections[self.currentIndex][coordinator.characterIndex].delegate = coordinator
                        
                    } else if to == 0 {
                        sideCoupletImageView.removeFromSuperview()
                        containerView.insertSubview(centerCoupletImageView, belowSubview: squareImageView)
                        centerCoupletCGView.strokeCollections = coordinator.strokeCollections[to]
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
                        
                        coordinator.characterIndex = 0
                        coordinator.strokeCollections[self.currentIndex][coordinator.characterIndex].delegate = coordinator
                        
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
                        sideCoupletCGView.strokeCollections = coordinator.strokeCollections[to]
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
                        
                        coordinator.characterIndex = 0
                        coordinator.strokeCollections[self.currentIndex][coordinator.characterIndex].delegate = coordinator
                        
                        // 配置 sideCoupletImageView 和 containerView 的大小
                        NSLayoutConstraint.activate([
                            sideCoupletImageView.widthAnchor.constraint(equalTo: containerView.widthAnchor),
                            sideCoupletImageView.widthAnchor.constraint(equalTo: sideCoupletImageView.heightAnchor, multiplier: 278/1317),
                            sideCoupletImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: screen.width * 0.055),
                            sideCoupletImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                        ])
                    }
                }
            }
        }
        
        coordinator.fingerStrokeRecognizer = coordinator.setupStrokeGestureRecognizer(isForPencil: false)
        coordinator.pencilStrokeRecognizer = coordinator.setupStrokeGestureRecognizer(isForPencil: true)
        
        return containerView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.setAllowsFingerDrawing(allowsFingerDrawing)
    }
}

struct CoupletButtonView: View {
    @Binding var allowsFingerDrawing: Bool
    @Binding var clearAction: () -> ()
    @Binding var undoAction: () -> ()
    @Binding var redoAction: () -> ()
    @Binding var showNoticationInterface: (_ text:String) -> ()
    @Binding var undoable: Bool
    @Binding var redoable: Bool
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
                    self.showNotification("该页已清空")
                    self.clearAction()
                    }], imageName: ["trash"])
                
            }
            .padding()
            
            Spacer()
            HStack {
                ButtonWithBlurBackground(
                    actions: [
                        {
                            if self.undoable {
                                self.undoAction()
                                self.showNotification("该页撤销一笔")
                            }
                        },
                        {
                            if self.redoable {
                                self.redoAction()
                                self.showNotification("该页重做一笔")
                            }
                        }
                    ],
                    imageName: [ "arrow.uturn.left", "arrow.uturn.right",],
                    frameWidth: 100,
                    colors: [undoable ? Color.blue : Color.white.opacity(0.5), redoable ? Color.blue : Color.white.opacity(0.5)]
                )
                
                Spacer()
            }
            .padding()
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

