//
//  EggDrawingView.swift
//  ByTheWindow
//
//  Created by JJAYCHEN on 2020/3/16.
//  Copyright © 2020 JJAYCHEN. All rights reserved.
//

import SwiftUI
import PencilKit
import Combine

let dragonBoatImage = UIImage(named: "dragon-boat-stroke")!
let beatDrumImage = UIImage(named: "beat-drum-stroke")!
let zongziImage = UIImage(named: "zongzi-stroke")!
let emptyEggImage = UIImage(named: "egg-empty")!

let eggThumnailImage = [Image("dragon-boat-thumbnail"), Image("beat-drum-thumbnail"), Image("zongzi-thumbnail"), Image("egg-empty-thumbnail")]

struct EggDrawingView: View {
    static private var pencilDetector: BOApplePencilReachability?
    
    @State var currentEggInedx: Int = 0
    @State var allowsFingerDrawing = true
    @State var text = ""
    @State var notificationOffset: CGFloat = -100
    @State var timer: Cancellable?
    
    @State var showShareSheet = false
    @State var sharedImage = UIImage()
    
    @State var getThumbnailImageFirst: () -> UIImage = { UIImage() }
    @State var getThumbnailImageSecond: () -> UIImage = { UIImage() }
    @State var getThumbnailImageThird: () -> UIImage = { UIImage() }
    @State var getThumbnailImageFourth: () -> UIImage = { UIImage() }
    
    func showNotification(_ message: String) {
        self.text = message
        self.timer?.cancel()
        self.notificationOffset = 0
        self.timer = DispatchQueue.main.schedule(
            after: DispatchQueue.main.now.advanced(by: .seconds(3)),
            interval: .seconds(2)
        ) {
            self.notificationOffset = -100
            self.timer?.cancel()
        }
    }
    
    var body: some View {
        ZStack {
            Image("egg-background")
                .resizable()
                .onAppear {
                    EggDrawingView.pencilDetector = BOApplePencilReachability.init(didChangeClosure: { isPencilReachable in
                        self.allowsFingerDrawing = !isPencilReachable
                        self.showNotification("Apple Pencil 已连接")
                    })
            }
            
            EggDrawingPKView(allowsFingerDrawing: $allowsFingerDrawing, thumbnailImage: $getThumbnailImageFirst, image: dragonBoatImage)
                .opacity(currentEggInedx == 0 ? 100 : 0)
            
            EggDrawingPKView(allowsFingerDrawing: $allowsFingerDrawing, thumbnailImage: $getThumbnailImageSecond, image: beatDrumImage)
                .opacity(currentEggInedx == 1 ? 100 : 0)
            
            EggDrawingPKView(allowsFingerDrawing: $allowsFingerDrawing, thumbnailImage: $getThumbnailImageThird, image: zongziImage)
                .opacity(currentEggInedx == 2 ? 100 : 0)
            
            EggDrawingPKView(allowsFingerDrawing: $allowsFingerDrawing, thumbnailImage: $getThumbnailImageFourth, image: emptyEggImage)
                .opacity(currentEggInedx == 3 ? 100 : 0)
            
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
                        .padding()
                    
                    Spacer()
                    
                    TextWithBlurBackground(text: $text)
                        .offset(y: notificationOffset)
                        .animation(.spring())
                        .padding()
                    
                    Spacer()
                    
                    ButtonWithBlurBackground(
                        actions: [{
                            if self.currentEggInedx == 0 {
                                self.sharedImage = self.getThumbnailImageFirst()
                            } else if self.currentEggInedx == 1 {
                                self.sharedImage = self.getThumbnailImageSecond()
                            } else if self.currentEggInedx == 2 {
                                self.sharedImage = self.getThumbnailImageThird()
                            } else if self.currentEggInedx == 3 {
                                self.sharedImage = self.getThumbnailImageFourth()
                            }
                            self.showShareSheet = true
                            }],
                        imageName: ["square.and.arrow.up"],
                        colors: [Color.blue]
                    )
                        .padding()
                }
                
                Spacer()
                
                ZStack {
                    VisualEffect(effect: UIBlurEffect(style: .light))
                        .frame(width: 375, height: 120)
                        .cornerRadius(30)
                    
                    HStack(spacing: 15) {
                        ForEach(0 ..< eggThumnailImage.count) { i in
                            eggThumnailImage[i]
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 75, height: 96)
                                .onTapGesture {
                                    self.currentEggInedx = i
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .sheet(isPresented: $showShareSheet) {
                ShareSheet(activityItems: [self.sharedImage])
        }
    }
}

struct EggDrawingPKView: UIViewRepresentable {
    @Binding var allowsFingerDrawing: Bool
    @Binding var thumbnailImage: () -> UIImage
    
    var image: UIImage
    var drawing = PKDrawing()
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
    class Coordinator: NSObject, PKCanvasViewDelegate {
        
    }
    
    func makeUIView(context: Context) -> PKCanvasView {
        let eggDrawingPKCanvasView = PKCanvasView()
        eggDrawingPKCanvasView.backgroundColor = .clear
        eggDrawingPKCanvasView.isOpaque = false
        
        let eggImageView = UIImageView(image: image)
        eggImageView.translatesAutoresizingMaskIntoConstraints = false
        eggImageView.contentMode = .scaleAspectFit
        
        eggDrawingPKCanvasView.subviews.first?.insertSubview(eggImageView, at: 0)
        NSLayoutConstraint.activate([
            eggImageView.leadingAnchor.constraint(equalTo: eggImageView.superview!.leadingAnchor),
            eggImageView.topAnchor.constraint(equalTo: eggImageView.superview!.topAnchor),
            eggImageView.bottomAnchor.constraint(equalTo: eggImageView.superview!.bottomAnchor),
            eggImageView.rightAnchor.constraint(equalTo: eggImageView.superview!.rightAnchor)
        ])
        
        eggDrawingPKCanvasView.delegate = context.coordinator
        eggDrawingPKCanvasView.minimumZoomScale = 1.0
        eggDrawingPKCanvasView.maximumZoomScale = 5.0
        eggDrawingPKCanvasView.zoomScale = 1.0
        eggDrawingPKCanvasView.showsVerticalScrollIndicator = false
        eggDrawingPKCanvasView.showsHorizontalScrollIndicator = false
        
        if let window = UIApplication.shared.windows.first, let toolPicker = PKToolPicker.shared(for: window) {
            toolPicker.setVisible(true, forFirstResponder: eggDrawingPKCanvasView)
            toolPicker.addObserver(eggDrawingPKCanvasView)
            
            toolPicker.selectedTool = PKInkingTool(.pen, color: .blue, width: 15)
            eggDrawingPKCanvasView.becomeFirstResponder()
        }
        
        DispatchQueue.main.async {
            self.thumbnailImage = {
                eggDrawingPKCanvasView.setZoomScale(1, animated: false)
                let background = UIImage(named: "egg-background")
                let imageView = UIImageView(image: background)
                imageView.translatesAutoresizingMaskIntoConstraints = false
                
                eggDrawingPKCanvasView.insertSubview(imageView, at: 0)
                NSLayoutConstraint.activate([
                    imageView.widthAnchor.constraint(equalTo: eggDrawingPKCanvasView.widthAnchor),
                    imageView.heightAnchor.constraint(equalTo: eggDrawingPKCanvasView.heightAnchor)
                ])
                
                defer{eggDrawingPKCanvasView.subviews.first?.removeFromSuperview()}
                return getThumbnailImage(with: eggDrawingPKCanvasView)!
            }
        }
        
        return eggDrawingPKCanvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        uiView.allowsFingerDrawing = allowsFingerDrawing
    }
}

struct EggDrawingView_Previews: PreviewProvider {
    static var previews: some View {
        EggDrawingView()
    }
}
