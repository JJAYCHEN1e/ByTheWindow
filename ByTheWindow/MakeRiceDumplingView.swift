//
//  MakeRiceDumplingView.swift
//  ByTheWindow
//
//  Created by 童翰文 on 2020/3/6.
//  Copyright © 2020 JJAYCHEN. All rights reserved.
//

import SwiftUI

enum RiceDumplingViewType {
    case BoilLeaves
    case SoakRice
    case MixStuffing
    case AddIngredients
    case BoilRiceDumplings
    case Finished
}

class TransitionInfo: ObservableObject {
    @Published var currentViewType:RiceDumplingViewType = .BoilLeaves
    @Published var onTransition = false
    @Published var titleText = "煮粽叶"
    @Published var hintText = "点击铁锅，将水倒入其中"
}

class StuffingInfo: ObservableObject {
    @Published var bowlImage:String = "small-red-bean"
    @Published var stuffingImage:String = "big-red-bean"
    @Published var mixedStuffingImage:String = "mixed-red-bean"
    @Published var ingredientImage:String = "ingredient-red-bean"
    
    init() {
        
    }
    
    init(bowlImage:String, stuffingImage:String, mixedStuffingImage:String, ingredientImage:String) {
        self.bowlImage = bowlImage
        self.stuffingImage = stuffingImage
        self.mixedStuffingImage = mixedStuffingImage
        self.ingredientImage = ingredientImage
    }
}

struct MakeRiceDumplingView: View {
    
    @EnvironmentObject var navigation:NavigationStack
    
    /**
     和场景切换相关的信息
     */
    @ObservedObject var transition:TransitionInfo = TransitionInfo()
    
    /**
     煮粽叶相关
     */
    @State var showWater = false
    @State var tapsOnWater = 0
    @State var onFire = false
    @State var fireCount = 0
    @State var fireScale : CGFloat = 1
    @State var fireTimer : Timer!
    
    /**
     泡糯米相关
     */
    @State var showWaterInBracket = false
    @State var showRice = false
    @State var soakTimer:Timer!
    
    /**
     拌馅料相关
     */
    @State var showStuffing = false
    @State var mixedStuffDegree:Angle = .zero
    @State var mixTimer:Timer!
    @State var mixCount = 0
    @State var showMixedStuffing = false
    @ObservedObject var beanInfo:StuffingInfo = StuffingInfo()
    
    /**
     包粽子相关
     */
    @ObservedObject var ingredientInfo:StuffingInfo = StuffingInfo(bowlImage: "meat", stuffingImage: "meat", mixedStuffingImage: "meat", ingredientImage: "meat")
    @State var showIngredient = false
    @State var covered = false
    @State var ingredientTimer:Timer!
    
    /**
     出锅相关
     */
    @State var showRiceDumplings = false
    
    
    func currentView() -> AnyView {
        switch self.transition.currentViewType {
        case .BoilLeaves:
            return AnyView(BoilLeavesView(transition: transition, onFire: $onFire, fireScale: $fireScale, fireCount: $fireCount, showWater: $showWater, tapsOnWater: $tapsOnWater, fireTimer: $fireTimer))
        case .SoakRice:
            return AnyView(SoakRiceView(transition: transition, showWaterInBracket: $showWaterInBracket, showRice: $showRice, soakTimer: $soakTimer))
        case .MixStuffing:
            return AnyView(MixStuffingView(transition:transition, showStuffing: $showStuffing, mixedStuffDegree: $mixedStuffDegree, mixTimer: $mixTimer, mixCount: $mixCount, showMixedStuffing: $showMixedStuffing,
            beanInfo: beanInfo))
        case .AddIngredients:
            return AnyView(AddIngredientView(transition: transition, ingredientInfo: ingredientInfo, beanInfo: beanInfo, showIngredient: $showIngredient, covered: $covered, ingredientTimer: $ingredientTimer))
        case .BoilRiceDumplings:
            return AnyView(BoilRiceDumplingView(transition: transition, onFire: $onFire, fireScale: $fireScale, fireCount: $fireCount, showWater: $showWater, tapsOnWater: $tapsOnWater, fireTimer: $fireTimer))
        case .Finished:
            return AnyView(FinishedView(showRiceDumplings: $showRiceDumplings, transition: transition))
//        default:
//            return AnyView(Text("端午节快乐").font(.custom("MaShanZheng-Regular", size: 80)))
        }
    }
    
    var body: some View {
        ZStack {
            TableBackgroundView()
            
            if self.transition.onTransition {
                currentView().transition(AnyTransition.opacity.animation(.easeInOut(duration: 1.5))).id(self.transition.currentViewType)
            } else {
                currentView().transition(AnyTransition.opacity.animation(.easeInOut(duration: 1.5))).id(self.transition.currentViewType)
            }
                
            TitleView(text: $transition.titleText)
        
            HintView(hintText: $transition.hintText)
        }
    }
}

struct MakeRiceDumplingView_Previews: PreviewProvider {
    static var previews: some View {
        MakeRiceDumplingView().previewLayout(.fixed(width: 1112, height: 834))
    }
}

struct BackgroundView: View {
    var body: some View {
        ZStack {
            Image("table-background")
                .edgesIgnoringSafeArea(.all)
            
            Image("tablecloth")
                .resizable()
                .frame(width:2 * screen.width, height: screen.height / 2)
        }
    }
}

struct TableBackgroundView: View {
    var body: some View {
        ZStack {
            Image("table-background")
                .resizable()
                //                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .frame(width: 1200, height: 850)
                .edgesIgnoringSafeArea(.all)
            
            Image("tablecloth")
                .resizable()
                .frame(width: 1200, height: 570)
        }
    }
}

struct TitleView: View {
    @Binding var text:String
    var body: some View {
        VStack {
            Text(self.text)
                .font(.custom("MaShanZheng-Regular", size: 70))
                .padding(.top, 35)
                .foregroundColor(Color(#colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)))
                .transition(.opacity)
                .id(self.text)
            Spacer()
        }
    }
}

struct BoilLeavesView: View {
    @ObservedObject var transition:TransitionInfo
    @Binding var onFire:Bool
    @Binding var fireScale: CGFloat
    @Binding var fireCount: Int
    @Binding var showWater: Bool
    @Binding var tapsOnWater: Int
    @Binding var fireTimer: Timer!
    var body: some View {
        ZStack {
            Image("pot-base")
                .resizable()
                .frame(width: 600, height: 600)
            
            Image("fire")
                .resizable()
                .frame(width:690, height: 690)
                .scaleEffect(self.onFire ? self.fireScale : CGFloat(1))
                .opacity(self.onFire ? 1.0 : 0)
                .animation(.spring())
            
            HStack(alignment: .bottom, spacing: 40) {
                Image("pot")
                    .resizable()
                    .frame(width: 600, height: 550)
                    .padding(.leading, 120)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 1.2)) {
                            self.showWater = true
                            self.transition.hintText = "再次点击，放入粽叶"
                        }
                }
                
                VStack {
                    Image("switch")
                        .resizable()
                        .frame(width: 90, height: 90)
                        .rotationEffect(self.onFire ? Angle.degrees(90) : Angle.degrees(0))
                        .onTapGesture {
                            withAnimation(.spring()) {
                                if self.tapsOnWater >= 3 {
                                        self.onFire.toggle()
                                        self.fireCount = 0
                                        if self.onFire {
                                            self.fireTimer = Timer.scheduledTimer(withTimeInterval: 0.2,
                                                                                  repeats: true,
                                                                                  block: { timer in
                                                                                    self.fireCount += 1
                                                                                    self.fireScale = CGFloat(Float(arc4random()) / Float(UInt32.max)) * 0.3 + 0.8
                                                                                    if self.fireCount >= 10 {
                                                                                        withAnimation() {
                                                        self.fireTimer.invalidate()
                                                                                            self.onFire = false
                                                                                            self.fireCount = 0
                                                                                            self.fireScale = 1
                                                                                            self.tapsOnWater = 0
                                                                                            self.showWater = false
                                                                                            self.transition.currentViewType = .SoakRice
                                                            
                                                                                            self.transition.titleText = "泡糯米"
                                                                                            self.transition.hintText = "点击竹篮，放入糯米"
                                                                                            self.transition.onTransition.toggle()
                                                                                        }

                                    }
                                            })
                                        } else {
                                            self.fireTimer.invalidate()
                                        }
                                    }
                                }
                    }
                    
                    Text(self.onFire ? "关火" : "开火")
                        .font(.custom("MaShanZheng-Regular", size: 30))
                }
                
            }
            
            ZStack() {
                ForEach(1 ..< 4) { item in
                    Image("leaf")
                        .resizable()
                        .frame(width: 600, height: 160)
                        .offset(y: CGFloat(60 * (item - 1)))
                        .opacity(item <= self.tapsOnWater ? 1 : 0)
                    
                }
            }
            .offset(y: -60)
            
            Image("water")
                .resizable()
                .frame(width: 480, height: 480)
                .opacity(self.showWater ? 0.7 : 0)
                .onTapGesture {
                    withAnimation() {
                        self.tapsOnWater += 1
                        if self.tapsOnWater >= 3 {
                            self.transition.hintText = "开火煮粽叶"
                        }
                    }
            }
            
        }
    }
}

struct SoakRiceView: View {
    @ObservedObject var transition:TransitionInfo
    @Binding var showWaterInBracket:Bool
    @Binding var showRice:Bool
    @Binding var soakTimer: Timer!
    var body: some View {
        ZStack {
            Image("bracket")
                .resizable()
                .frame(width: 570, height: 570)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 1.2)) {
                        self.showRice = true
                        self.transition.hintText = "点击糯米，加水"
                    }
            }
            
            Image("rice")
                .resizable()
                .frame(width: 420, height: 420)
                .opacity(self.showRice ? 1.0 : 0.0)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 1.2)) {
                        self.showWaterInBracket = true
                        self.transition.hintText = "完成"
                        self.soakTimer = Timer.scheduledTimer(withTimeInterval: 2.4, repeats: false, block: { timer in
                            withAnimation(.easeInOut) {
                                self.transition.currentViewType = .MixStuffing
                                
                                self.transition.titleText = "拌粽馅"
                                self.transition.hintText = "选择粽馅，拖动到糯米上"
                                self.transition.onTransition.toggle()
                                
                                self.showRice = false
                                self.showWaterInBracket = false
                            }
                        })
                    }
            }
            
            Image("water")
                .resizable()
                .frame(width: 460, height: 460)
                .opacity(self.showWaterInBracket ? 0.7 : 0)
        }
    }
}

struct BowlView: View {
    var bowlImage:String = "small-red-bean"
    var bracketImage:String = "big-red-bean"
    var mixedBracketImage:String = "mixed-red-bean"
    var ingredientImage:String = "ingredient-red-bean"
    @State var currentPos:CGSize = .zero
    @State var newPos:CGSize = .zero
    @Binding var showStuffing:Bool
    @Binding var covered:Bool
    @ObservedObject var currentStuffingInfo:StuffingInfo
    @ObservedObject var transition:TransitionInfo
    
    var body: some View {
        ZStack {
            Image("bowl")
                .resizable()
                .frame(width: 150, height: 150)
            
            Image(self.bowlImage)
            .resizable()
            .frame(width: 75, height: 75)
            
            Image(self.bowlImage)
                .resizable()
                .frame(width: 75, height: 75)
                .offset(x: self.currentPos.width, y: self.currentPos.height)
                .gesture(DragGesture()
                    .onChanged{ value in
                        self.currentPos = CGSize(width: value.translation.width + self.newPos.width, height: value.translation.height + self.newPos.height)
                    }
                .onEnded { value in
                    withAnimation(.easeInOut) {
                        self.currentPos = self.newPos
                        self.currentStuffingInfo.bowlImage = self.bowlImage
                        self.currentStuffingInfo.stuffingImage = self.bracketImage
                       
                        self.currentStuffingInfo.mixedStuffingImage = self.mixedBracketImage
                        self.currentStuffingInfo.ingredientImage = self.ingredientImage
                        if !self.covered {
                            self.showStuffing = true
                        }
                        self.transition.hintText = "点击糯米上的粽馅，将其拌入糯米中"
                    }
                }
            )
        }
    }
}

struct MixStuffingView: View {
    @ObservedObject var transition:TransitionInfo
    @Binding var showStuffing:Bool
    @Binding var mixedStuffDegree:Angle
    @Binding var mixTimer:Timer!
    @Binding var mixCount:Int
    @Binding var showMixedStuffing:Bool
    @State var coverd = false
    @State var timerOn = false
    @ObservedObject var beanInfo:StuffingInfo
    
    var body: some View {
        HStack(alignment: .center, spacing: 80) {
            ZStack {
                Image("bracket")
                    .resizable()
                    .frame(width: 570, height: 570)
                
                Image("rice")
                    .resizable()
                    .frame(width: 420, height: 420)
                    .rotationEffect(self.mixedStuffDegree)
                
                Image(self.beanInfo.stuffingImage)
                    .resizable()
                    .frame(width: 180, height: 180)
                    .opacity(self.showStuffing ? 1.0 : 0.0)
                    .id(self.beanInfo.stuffingImage)
                    .onTapGesture {
                        withAnimation(.easeInOut) {
                            self.showStuffing = false
                            self.showMixedStuffing = true
                            self.transition.hintText = "长按粽馅进行搅拌"
                        }
                        
                }
                
                Image(self.beanInfo.mixedStuffingImage)
                    .resizable()
                    .frame(width: 380, height: 380)
                    .rotationEffect(self.mixedStuffDegree)
                    .opacity(self.showMixedStuffing ? 1.0 : 0.0)
                    .gesture(LongPressGesture(minimumDuration: 4) .onChanged { value in
                        if !self.timerOn {
                            self.mixTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true, block: { timer in
                                if self.mixCount >= 19 {
                                    withAnimation() {
                                        timer.invalidate()
                                        self.transition.currentViewType = .AddIngredients
                                        self.transition.titleText = "包粽子"
                                        self.transition.hintText = "选择其他粽馅，拖动到糯米上"
                                        self.transition.onTransition.toggle()
                                        
                                        self.mixCount = 0
                                        self.showStuffing = false
                                        self.showMixedStuffing = false
                                    }
                                }
                                self.mixCount += 1
                                withAnimation(.spring()) {
                                    self.mixedStuffDegree = Angle.degrees(self.mixedStuffDegree.degrees + 10)
                                }
                            })
                            self.timerOn = true
                        }
                    }.onEnded{ value in
                        withAnimation() {
                            self.mixTimer.invalidate()
                            self.transition.currentViewType = .AddIngredients
                            self.transition.titleText = "包粽子"
                            self.transition.hintText = "选择其他粽馅，拖动到糯米上"
                            self.transition.onTransition.toggle()
                            self.mixCount = 0
                            self.showStuffing = false
                            self.showMixedStuffing = false
                        }
                    })
                
                //                    Image("spoon")
                //                    .resizable()
                //                    .frame(width: 300, height: 300)
                //                    .offset(x: -100, y: -100)
            }
            .padding(.leading, 200)
            
            VStack(spacing: 150) {
                BowlView(bowlImage: "small-red-bean", bracketImage: "big-red-bean",mixedBracketImage: "mixed-red-bean",
                         ingredientImage: "ingredient-red-bean",
                         currentPos: .zero, newPos: .zero, showStuffing: $showStuffing, covered: $coverd,
                         currentStuffingInfo: beanInfo, transition: transition)
                BowlView(bowlImage: "small-green-bean", bracketImage: "big-green-bean", mixedBracketImage: "mixed-green-bean",
                         ingredientImage: "ingredient-green-bean",
                         currentPos: .zero, newPos: .zero, showStuffing: $showStuffing, covered: $coverd,
                         currentStuffingInfo: beanInfo, transition: transition)
            }.padding(.trailing, 30)
        }
    }
}

struct AddIngredientView: View {
    @ObservedObject var transition:TransitionInfo
    @ObservedObject var ingredientInfo:StuffingInfo
    @ObservedObject var beanInfo:StuffingInfo
    @Binding var showIngredient:Bool
    @Binding var covered:Bool
    @Binding var ingredientTimer:Timer!
    
    
    var body: some View {
        HStack(alignment: .center, spacing: 60) {
            ZStack {
                Image("bracket")
                    .resizable()
                    .frame(width: 570, height: 570)
                
                Image("leaf")
                    .resizable()
                    .frame(width: 650, height: 180)
                
                Image("ingredient-rice")
                    .resizable()
                    .frame(width: 200, height: 130)
                    .opacity(covered ? 0.0 : 1.0)
                
                Image("covered-rice")
                    .resizable()
                    .frame(width: 250, height: 160)
                    .opacity(covered ? 1.0 : 0.0)
                
                Image(self.beanInfo.ingredientImage)
                    .resizable()
                    .frame(width: 160, height: 120)
                    .offset(y: 20)
                    .scaleEffect(covered ? 1.2 : 1.0)
                
                Image(self.ingredientInfo.stuffingImage)
                    .resizable()
                    .frame(width: 80, height: 80)
                    .rotationEffect(Angle.degrees(-60))
                    .opacity(showIngredient ? 1.0 : 0.0)
                    .id(self.ingredientInfo.stuffingImage)
                    .onTapGesture {
                        withAnimation(.spring()) {
                            if self.showIngredient {
                                self.transition.hintText = "完成"
                                self.covered = true
                                self.showIngredient = false
                                self.ingredientTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: { timer in
                                    withAnimation() {
                                        self.transition.currentViewType = .BoilRiceDumplings
                                        self.transition.titleText = "煮粽子"
                                        self.transition.hintText = "点击铁锅，将水倒入其中"
                                        self.transition.onTransition.toggle()
                                        self.showIngredient = false
                                        self.covered = false
                                    }
                                })
                            }
                        }
                }
            }
            
            VStack(spacing: 150) {
                BowlView(bowlImage: "meat", bracketImage: "meat", mixedBracketImage: "meat", ingredientImage: "meat", currentPos: .zero, newPos: .zero, showStuffing: $showIngredient, covered: $covered, currentStuffingInfo: ingredientInfo, transition: transition)
                
                BowlView(bowlImage: "duck-egg", bracketImage: "duck-egg", mixedBracketImage: "duck-egg", ingredientImage: "duck-egg", currentPos: .zero, newPos: .zero, showStuffing: $showIngredient, covered: $covered, currentStuffingInfo: ingredientInfo, transition: transition)
            }.padding(.trailing, 30)
        }
        .padding(.leading, 200)
    }
}

struct BoilRiceDumplingView: View {
    @ObservedObject var transition:TransitionInfo
    @Binding var onFire:Bool
    @Binding var fireScale: CGFloat
    @Binding var fireCount: Int
    @Binding var showWater: Bool
    @Binding var tapsOnWater: Int
    @Binding var fireTimer: Timer!
    
    var body: some View {
        ZStack {
            Image("pot-base")
                .resizable()
                .frame(width: 600, height: 600)
            
            Image("fire")
                .resizable()
                .frame(width:690, height: 690)
                .scaleEffect(self.onFire ? self.fireScale : CGFloat(1))
                .opacity(self.onFire ? 1.0 : 0)
                .animation(.spring())
            
            HStack(alignment: .bottom, spacing: 40) {
                Image("pot")
                    .resizable()
                    .frame(width: 600, height: 550)
                    .padding(.leading, 120)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 1.2)) {
                            self.showWater = true
                            self.transition.hintText = "再次点击，将粽子放入锅中"
                        }
                }
                
                VStack {
                    Image("switch")
                        .resizable()
                        .frame(width: 90, height: 90)
                        .rotationEffect(self.onFire ? Angle.degrees(90) : Angle.degrees(0))
                        .onTapGesture {
                            withAnimation(.spring()) {
                                if self.tapsOnWater >= 2 {
                                    self.onFire.toggle()
                                    self.fireCount = 0
                                    if self.onFire {
                                        self.fireTimer = Timer.scheduledTimer(withTimeInterval: 0.2,
                                                                              repeats: true,
                                                                              block: { timer in
                                                                                self.fireCount += 1
                                                                                self.fireScale = CGFloat(Float(arc4random()) / Float(UInt32.max)) * 0.3 + 0.8
                                                                                if self.fireCount >= 10 {
                                                                                    withAnimation() {
                                                                                        self.fireTimer.invalidate()
                                                                                        self.onFire = false
                                                                                        self.fireCount = 0
                                                                                        self.transition.currentViewType = .Finished
                                                                                        self.transition.hintText = "点击木盆，将粽子从锅中捞出"
                                                                                        self.transition.titleText = "出锅"
                                                                                        
                                                                                        self.transition.onTransition.toggle()
                                                                                    }
                                                                                    
                                                                                }
                                        })
                                    } else {
                                        self.fireTimer.invalidate()
                                    }
                                }
                            }
                    }
                    
                    Text(self.onFire ? "关火" : "开火")
                        .font(.custom("MaShanZheng-Regular", size: 30))
                }
                
            }
            
            ZStack() {
                ForEach(1 ..< 3) { item in
                    Image("riceDumpling")
                        .resizable()
                        .frame(width: 240, height: 220)
                        .offset((item == 1) ? CGSize(width: 60.0, height: -20.0) : CGSize(width: -40.0, height: 100.0))
                        .opacity(item <= self.tapsOnWater ? 1.0 : 0.0)
                    
                }
            }
            .offset(y: -40.0)
            
            
            Image("water")
                .resizable()
                .frame(width: 480, height: 480)
                .opacity(self.showWater ? 0.7 : 0.0)
                .onTapGesture {
                    withAnimation() {
                        self.tapsOnWater += 1
                        if (self.tapsOnWater >= 2) {
                            self.transition.hintText = "开火煮粽子"
                        }
                    }
            }
            
        }
    }
}

struct FinishedView: View {
    @Binding var showRiceDumplings:Bool
    @ObservedObject var transition:TransitionInfo
    
    var body: some View {
        ZStack {
            Image("bracket")
                .resizable()
                .frame(width: 570, height: 570)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 1.2)) {
                        self.showRiceDumplings = true
                        self.transition.hintText = ""
                    }
            }
            
            Image("riceDumpling")
                .resizable()
                .frame(width: 240, height: 220)
                .offset(CGSize(width: 60.0, height: -60.0))
                .opacity(showRiceDumplings ? 1.0 : 0.0)
            
            Image("riceDumpling")
                .resizable()
                .frame(width: 240, height: 220)
                .rotationEffect(Angle.degrees(-30))
                .offset(CGSize(width: -40.0, height: 60.0))
                .opacity(showRiceDumplings ? 1.0 : 0.0)
            
            VStack {
                Spacer()
                // TODO: 返回
                Button(action: {
                    
                }) {
                    Text("返回")
                        .font(.custom("MaShanZheng-Regular", size: 50))
                        .foregroundColor(Color.white)
                        .padding(.bottom, 50)
                        .opacity(self.showRiceDumplings ? 1.0 : 0.0)
                }
            }
            
        }
    }
}

struct HintView: View {
    @Binding var hintText:String
    var body: some View {
        VStack {
            Spacer()
            Text(self.hintText)
                .font(.custom("MaShanZheng-Regular", size: 50))
                .padding(.bottom, 40)
                .foregroundColor(.white)
                .transition(.opacity)
                .id(self.hintText)
        }
    }
}
