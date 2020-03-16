//
//  CoupletView.swift
//  ByTheWindow
//
//  Created by JJAYCHEN on 2020/2/19.
//  Copyright © 2020 JJAYCHEN. All rights reserved.
//

import SwiftUI
import Combine
import PencilKit

let sideCoupletImage = UIImage(named: "couplet")!
let centerCoupletImage = UIImage(named: "couplet-center")!
let squareImage = UIImage(named: "田字格")!

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
    
    @State var couletImages: [UIImage] = [centerCoupletImage, sideCoupletImage, sideCoupletImage]
    @State var drawingImages: [UIImage] = [centerCoupletImage, sideCoupletImage, sideCoupletImage]
    
    @State var centerSize = CGRect.zero
    @State var leftSize = CGRect.zero
    @State var rightSize = CGRect.zero
    
    @State var generateARImage: () -> UIImage = { UIImage() }
    
    @State var image = UIImage()
    
    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                VStack {
                    Spacer()
                    
                    VStack {
                        ZStack {
                            Image(uiImage: centerCoupletImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                            .frame(width: 250)
                            
                            Image(uiImage: drawingImages[0])
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .onTapGesture {
                                    self.prevIndex = self.currentIndex
                                    self.currentIndex = 0
                                    self.changeSelectedCouplet(self.prevIndex, 0)
                            }
                            .frame(width: 250, height: centerCoupletImage.size.height / (centerCoupletImage.size.width / 250))
                        }
                        .padding(.bottom)
                        
                        
                        
                        HStack{
                            ZStack {
                                Image(uiImage: sideCoupletImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                .frame(width: 100)
                                
                                Image(uiImage: drawingImages[1])
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .onTapGesture {
                                        self.prevIndex = self.currentIndex
                                        self.currentIndex = 1
                                        self.changeSelectedCouplet(self.prevIndex, 1)
                                }
                                .frame(width: 100, height: sideCoupletImage.size.height / (sideCoupletImage.size.width / 100))
                            }
                            .padding(.leading)
                            
                            Spacer()
                            
                            ZStack {
                                Image(uiImage: sideCoupletImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                .frame(width: 100)
                                
                                Image(uiImage: drawingImages[2])
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .onTapGesture {
                                        self.prevIndex = self.currentIndex
                                        self.currentIndex = 2
                                        self.changeSelectedCouplet(self.prevIndex, 2)
                                }
                                .frame(width: 100, height: sideCoupletImage.size.height / (sideCoupletImage.size.width / 100))
                            }
                            .padding(.trailing)
                        }
                    }
                    
                    Spacer()
                }
                .frame(width: screen.width / 3)
                
                ZStack {
                    Color(#colorLiteral(red: 0.7019159198, green: 0.2200317383, blue: 0.185915947, alpha: 1))
                        .frame(maxWidth: .infinity)
    //
                    VStack {
                        ZStack {
                            CoupletDrawingView(allowsFingerDrawing: $allowsFingerDrawing, clearAction: $clearAction, undoAction: $undoAction, redoAction: $redoAction, showNotification: $showNotificationInterface, prevIndex: $prevIndex, currentIndex: $currentIndex, changeSelectedCouplet: $changeSelectedCouplet, undoable: $undoable, redoable: $redoable, coupletImages: $couletImages, drawingImages: $drawingImages, generateARImage: $generateARImage)
                                .clipShape(Rectangle())
                            
                            CoupletButtonView(allowsFingerDrawing: $allowsFingerDrawing, clearAction: $clearAction,
                                              undoAction: $undoAction, redoAction: $redoAction, showNoticationInterface: $showNotificationInterface, undoable: $undoable, redoable: $redoable, generateARImage: $generateARImage, image: $image)
                        }
                    }
                }
                .frame(width: screen.width * 2 / 3)
            }
            .edgesIgnoringSafeArea(.all)
            
            Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 100)
        }
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
    
    @Binding var coupletImages: [UIImage]
    @Binding var drawingImages: [UIImage]
    @Binding var generateARImage: () -> UIImage
    
    func makeCoordinator() -> Coordinator {
        let coordinator = Coordinator(self)
        coordinator.beginPencilDetect()
        return coordinator
    }
    
    class Coordinator: NSObject {
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
        
        var containerView: UIView!
        
        var leftCoupletImageView: UIImageView!
        var rightCoupletImageView: UIImageView!
        var centerCoupletImageView: UIImageView!
        
        var leftCoupletPKCanvasView: PKCanvasView!
        var rightCoupletPKCanvasView: PKCanvasView!
        var centerCoupletPKCanvasView: PKCanvasView!
        
        var leftCouletPKCanvasViewDelegate: CoupletPKCanvasViewDelegate!
        var rightCouletPKCanvasViewDelegate: CoupletPKCanvasViewDelegate!
        var centerCouletPKCanvasViewDelegate: CoupletPKCanvasViewDelegate!
        
        var currentIndex: Int {
            get {
                self.coupletDrawingView.currentIndex
            }
        }
        
        var prevIndex: Int {
            self.coupletDrawingView.prevIndex
        }
        
        func getCoupletImageView(at index: Int) -> UIImageView {
            switch index {
            case 0:
                return self.centerCoupletImageView
            case 1:
                return self.leftCoupletImageView
            case 2:
                return self.rightCoupletImageView
            default:
                return self.leftCoupletImageView
            }
        }
        
        func getCoupletPKCanvasView(at index: Int) -> PKCanvasView {
            switch index {
            case 0:
                return self.centerCoupletPKCanvasView
            case 1:
                return self.leftCoupletPKCanvasView
            case 2:
                return self.rightCoupletPKCanvasView
            default:
                return self.leftCoupletPKCanvasView
            }
        }
        
        var currentCoupletImageView: UIImageView {
            getCoupletImageView(at: currentIndex)
        }
        
        var currentCoupletPKCanvasView: PKCanvasView{
            getCoupletPKCanvasView(at: currentIndex)
        }
        
        var prevCoupletImageView: UIImageView {
            getCoupletImageView(at: prevIndex)
        }
        
        var prevCGView: PKCanvasView{
            getCoupletPKCanvasView(at: prevIndex)
        }
        
        func setAllowsFingerDrawing(_ allowsFingerDrawing: Bool) {
            self.leftCoupletPKCanvasView.allowsFingerDrawing = allowsFingerDrawing
            self.rightCoupletPKCanvasView.allowsFingerDrawing = allowsFingerDrawing
            self.centerCoupletPKCanvasView.allowsFingerDrawing = allowsFingerDrawing
            
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
        
        func generateARImage() -> UIImage {
            UIGraphicsBeginImageContext(CGSize(width: 2732, height: 2048))
            
            leftCoupletPKCanvasView.draw(CGRect(origin: CGPoint.zero, size: leftCoupletPKCanvasView.frame.size))
//            rightCoupletPKCanvasView.draw(CGRect(origin: CGPoint.zero, size: rightCoupletPKCanvasView.frame.size))
//            leftCoupletPKCanvasView.draw(CGRect(origin: CGPoint.zero, size: leftCoupletPKCanvasView.frame.size))
            
            let resultImage = UIGraphicsGetImageFromCurrentImageContext()
            
            UIGraphicsEndImageContext()
            
            //打印工程所在文件路径
            print(NSHomeDirectory())
            //获取本地缓存文件路径
            let cachPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
            //设置保存路径
            let path = cachPath[0] + "/img.png"
            
            do {
                try resultImage?.pngData()?.write(to: URL(fileURLWithPath: path))
            } catch {
                print(error)
            }
            
            return resultImage!
        }
        
        class CoupletPKCanvasViewDelegate: NSObject, PKCanvasViewDelegate {
            var squareUnit: CGFloat
            var coupletScale: CGFloat
            var offsetPercentage: CGFloat
            var maxIndex: CGFloat
            var isVertical: Bool
            var coupletIndex: Int
            var coupletDrawingView: CoupletDrawingView
            
            init(coupletDrawingView: CoupletDrawingView, coupletIndex: Int,squareUnit : CGFloat, coupletScale: CGFloat, offsetPercentage: CGFloat, maxIndex: CGFloat, isVertical: Bool) {
                self.coupletDrawingView = coupletDrawingView
                self.coupletIndex = coupletIndex
                self.squareUnit = squareUnit
                self.coupletScale = coupletScale
                self.offsetPercentage = offsetPercentage
                self.maxIndex = maxIndex
                self.isVertical = isVertical
            }
            
            func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
                coupletDrawingView.drawingImages[coupletIndex] = canvasView.drawing.image(from: CGRect(origin: .zero, size: canvasView.contentSize), scale: 1)
            }
            
            func scrollToDestination(_ scrollView: UIScrollView) {
                let currentPosition = isVertical ? scrollView.contentOffset.y : scrollView.contentOffset.x
                let squareUnit = self.squareUnit * (isVertical ? 1 : 0.9786324)
                var index = max(0, floor((currentPosition + squareUnit*0.5 + offsetPercentage * screen.height) / squareUnit))
                
                index = min(maxIndex, index)
                
                let destination = index * squareUnit - offsetPercentage * screen.height
                
                if isVertical {
                    scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x, y: destination), animated: true)
                } else {
                    scrollView.setContentOffset(CGPoint(x: destination, y: scrollView.contentOffset.y), animated: true)
                }
            }
            
            func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
                if decelerate == false {
                   scrollToDestination(scrollView)
                }
            }
            
            func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
                scrollToDestination(scrollView)
            }
        }
        
        func setUpCoupletPKCanvasViewDelegate(coupletPKCanvasView: PKCanvasView, coupletIndex: Int) {
            if coupletIndex == 0 {
                self.centerCouletPKCanvasViewDelegate = CoupletPKCanvasViewDelegate(coupletDrawingView: coupletDrawingView, coupletIndex: 0, squareUnit: squareUnit, coupletScale: coupletScale, offsetPercentage: 0.07793764988, maxIndex: 3, isVertical: false)
                coupletPKCanvasView.delegate = self.centerCouletPKCanvasViewDelegate
            } else if coupletIndex == 1 {
                self.leftCouletPKCanvasViewDelegate = CoupletPKCanvasViewDelegate(coupletDrawingView: coupletDrawingView, coupletIndex: 1, squareUnit: squareUnit, coupletScale: coupletScale, offsetPercentage: 0.07793764988, maxIndex: 6, isVertical: true)
                coupletPKCanvasView.delegate = self.leftCouletPKCanvasViewDelegate
            } else {
                self.rightCouletPKCanvasViewDelegate = CoupletPKCanvasViewDelegate(coupletDrawingView: coupletDrawingView, coupletIndex: 2, squareUnit: squareUnit, coupletScale: coupletScale, offsetPercentage: 0.07793764988, maxIndex: 6, isVertical: true)
                coupletPKCanvasView.delegate = self.rightCouletPKCanvasViewDelegate
            }
        }
    }
    
    func makeUIView(context: Context) -> UIView {
        let coordinator = context.coordinator
        
        // MARK: View Layout Configurations
        let leftCoupletImageView = UIImageView(image: sideCoupletImage)
        let rightCoupletImageView = UIImageView(image: sideCoupletImage)
        let centerCoupletImageView = UIImageView(image: centerCoupletImage)
        let squareImageView = UIImageView(image: squareImage)
        
        let leftCoupletPKCanvasView = PKCanvasView(frame: .zero)
        let rightCoupletPKCanvasView = PKCanvasView(frame: .zero)
        let centerCoupletPKCanvasView = PKCanvasView(frame: .zero)
        
        let containerView = UIView(frame: .zero)
        
        /// 设置 PKCanvasView 背景为透明
        leftCoupletPKCanvasView.backgroundColor = .clear
        rightCoupletPKCanvasView.backgroundColor = .clear
        centerCoupletPKCanvasView.backgroundColor = .clear
        leftCoupletPKCanvasView.isOpaque = false
        rightCoupletPKCanvasView.isOpaque = false
        centerCoupletPKCanvasView.isOpaque = false
        
        /// 插入对联背景和田字格
        leftCoupletPKCanvasView.insertSubview(leftCoupletImageView, at: 0)
        rightCoupletPKCanvasView.insertSubview(rightCoupletImageView, at: 0)
        centerCoupletPKCanvasView.insertSubview(centerCoupletImageView, at: 0)
        containerView.addSubview(squareImageView)
        
        /// 配置 AutoLayout
        leftCoupletImageView.translatesAutoresizingMaskIntoConstraints = false
        rightCoupletImageView.translatesAutoresizingMaskIntoConstraints = false
        centerCoupletImageView.translatesAutoresizingMaskIntoConstraints = false
        leftCoupletPKCanvasView.translatesAutoresizingMaskIntoConstraints = false
        rightCoupletPKCanvasView.translatesAutoresizingMaskIntoConstraints = false
        centerCoupletPKCanvasView.translatesAutoresizingMaskIntoConstraints = false
        squareImageView.translatesAutoresizingMaskIntoConstraints = false
        squareImageView.contentMode = .scaleAspectFit
        
        /// 配置 leftCoupletImageView 和 sideCoupletPKCanvasView 的 Autolayout
        NSLayoutConstraint.activate([
            leftCoupletImageView.widthAnchor.constraint(equalTo: leftCoupletPKCanvasView.widthAnchor),
            leftCoupletImageView.widthAnchor.constraint(equalTo: leftCoupletImageView.heightAnchor, multiplier: 278/1317),
            leftCoupletImageView.centerXAnchor.constraint(equalTo: leftCoupletPKCanvasView.centerXAnchor),
            leftCoupletImageView.topAnchor.constraint(equalTo: leftCoupletPKCanvasView.topAnchor)
        ])

        /// 配置 rightCoupletImageView 和 sideCoupletPKCanvasView 的 Autolayout
        NSLayoutConstraint.activate([
            rightCoupletImageView.widthAnchor.constraint(equalTo: rightCoupletPKCanvasView.widthAnchor),
            rightCoupletImageView.widthAnchor.constraint(equalTo: rightCoupletImageView.heightAnchor, multiplier: 278/1317),
            rightCoupletImageView.centerXAnchor.constraint(equalTo: rightCoupletPKCanvasView.centerXAnchor),
            rightCoupletImageView.topAnchor.constraint(equalTo: rightCoupletPKCanvasView.topAnchor)
        ])
        
        /// 配置 centerCoupletImageView 和 sideCoupletPKCanvasView 的 Autolayout
        NSLayoutConstraint.activate([
            centerCoupletImageView.heightAnchor.constraint(equalTo: centerCoupletPKCanvasView.widthAnchor),
            centerCoupletImageView.widthAnchor.constraint(equalTo: centerCoupletImageView.heightAnchor, multiplier: 1080/403),
            centerCoupletImageView.centerYAnchor.constraint(equalTo: centerCoupletPKCanvasView.centerYAnchor),
            centerCoupletImageView.leadingAnchor.constraint(equalTo: centerCoupletPKCanvasView.leadingAnchor)
        ])
        
        // 配置 squareImageView 的 Autolayout
        NSLayoutConstraint.activate([
            squareImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            squareImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            squareImageView.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: squareScale)
        ])
        
        /// 更新 Inset 以对齐上下边界
        leftCoupletPKCanvasView.contentInset.top = screen.width * 0.06
        leftCoupletPKCanvasView.contentInset.bottom = screen.width * 0.06
        rightCoupletPKCanvasView.contentInset.top = screen.width * 0.06
        rightCoupletPKCanvasView.contentInset.bottom = screen.width * 0.06
        centerCoupletPKCanvasView.contentInset.left = screen.width * 0.06
        centerCoupletPKCanvasView.contentInset.right = screen.width * 0.06
        
//        centerCoupletPKCanvasView.

        /// 默认插入左侧对联
        /// 配置 leftCoupletPKCanvasView 和 containerView 的 Autolayout
        containerView.insertSubview(leftCoupletPKCanvasView, at: 0)
        NSLayoutConstraint.activate([
            leftCoupletPKCanvasView.widthAnchor.constraint(equalTo: containerView.widthAnchor),
            leftCoupletPKCanvasView.heightAnchor.constraint(equalTo: containerView.heightAnchor),
            leftCoupletPKCanvasView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            leftCoupletPKCanvasView.topAnchor.constraint(equalTo: containerView.topAnchor)
        ])
        
        DispatchQueue.main.async{
            self.clearAction = {
                coordinator.currentCoupletPKCanvasView.drawing = PKDrawing()
            }
            
            self.generateARImage = {
                coordinator.generateARImage()
            }

            self.changeSelectedCouplet = { from, to in
                if from != to {
                    let prevPKCanvasView = coordinator.getCoupletPKCanvasView(at: from)
                    prevPKCanvasView.removeFromSuperview()
                    
                    let currentPKCanvasView = coordinator.getCoupletPKCanvasView(at: to)
                    containerView.insertSubview(currentPKCanvasView, at: 0)
                    
                    let currentImageView = coordinator.getCoupletImageView(at: to)
                    
                    if to == 0 {
                        NSLayoutConstraint.activate([
                            currentPKCanvasView.heightAnchor.constraint(equalTo: containerView.widthAnchor),
                            currentPKCanvasView.widthAnchor.constraint(equalTo: containerView.widthAnchor),
                            currentPKCanvasView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                            currentPKCanvasView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
                        ])
                    } else {
                        NSLayoutConstraint.activate([
                            currentPKCanvasView.widthAnchor.constraint(equalTo: containerView.widthAnchor),
                            currentPKCanvasView.heightAnchor.constraint(equalTo: containerView.heightAnchor),
                            currentPKCanvasView.topAnchor.constraint(equalTo: containerView.topAnchor),
                            currentPKCanvasView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
                        ])
                    }
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now().advanced(by: .milliseconds(300))) {
                        currentPKCanvasView.contentSize = currentImageView.frame.size
                        currentPKCanvasView.becomeFirstResponder()
                    }
                }
            }
        }
        

        // MARK: PKCanvasView Configurations
        
        coordinator.containerView = containerView
        coordinator.leftCoupletPKCanvasView = leftCoupletPKCanvasView
        coordinator.rightCoupletPKCanvasView = rightCoupletPKCanvasView
        coordinator.centerCoupletPKCanvasView = centerCoupletPKCanvasView
        coordinator.leftCoupletImageView = leftCoupletImageView
        coordinator.rightCoupletImageView = rightCoupletImageView
        coordinator.centerCoupletImageView = centerCoupletImageView
        
        /// 需要在 SwiftUI 接受该 View 之后更新 contentSize 并且设置代理
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now().advanced(by: .milliseconds(500))) {
            leftCoupletPKCanvasView.contentSize = leftCoupletImageView.frame.size
            
            coordinator.setUpCoupletPKCanvasViewDelegate(coupletPKCanvasView: centerCoupletPKCanvasView, coupletIndex: 0)
            coordinator.setUpCoupletPKCanvasViewDelegate(coupletPKCanvasView: leftCoupletPKCanvasView, coupletIndex: 1)
            coordinator.setUpCoupletPKCanvasViewDelegate(coupletPKCanvasView: rightCoupletPKCanvasView, coupletIndex: 2)
        }
        
        /// 设置 PencilKitTool
        if let window = UIApplication.shared.windows.first, let toolPicker = PKToolPicker.shared(for: window) {
            toolPicker.setVisible(true, forFirstResponder: leftCoupletPKCanvasView)
            toolPicker.setVisible(true, forFirstResponder: rightCoupletPKCanvasView)
            toolPicker.setVisible(true, forFirstResponder: centerCoupletPKCanvasView)
            
            toolPicker.addObserver(leftCoupletPKCanvasView)
            toolPicker.addObserver(rightCoupletPKCanvasView)
            toolPicker.addObserver(centerCoupletPKCanvasView)
            
            toolPicker.selectedTool = PKInkingTool(.pen, color: .black, width: 100)
            leftCoupletPKCanvasView.becomeFirstResponder()
        }
        
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
    @Binding var generateARImage: () -> UIImage
    @Binding var image: UIImage
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
            
//            Spacer()
            
            Text("分享")
            .contextMenu {
                VStack {
                    Button(action: {
                        self.image = self.generateARImage()
                    }) {
                        HStack {
                            Text("分享对联")
                            Image(systemName: "square.and.arrow.up")
                        }
                    }

                    Button(action: {
                        // enable geolocation
                    }) {
                        HStack {
                            Text("AR 贴春联")
                            Image(systemName: "arkit")
                        }
                    }
                }
            }
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

