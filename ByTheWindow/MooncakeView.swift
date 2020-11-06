//
//  MooncakeView.swift
//  ByTheWindow
//
//  Created by 童翰文 on 2020/11/5.
//  Copyright © 2020 JJAYCHEN. All rights reserved.
//

import SwiftUI

let mooncakeNames = ["广式月饼", "晋式月饼", "潮式月饼", "苏式月饼", "滇式月饼", "京式月饼",
"徽式月饼", "衢式月饼", "秦式月饼", "丰镇月饼" ]
let mooncakeImages = ["guang", "jin", "chao", "su", "dian", "jing", "hui", "qu", "qin", "fengzhen"]
let mooncakeDescription = ["皮薄松软、造型美观、图案精致、花纹清晰",
    "性质古朴，口味淳厚，酥绵爽口，甜而不腻",
    "皮酥馅细，油不肥舌，甜不腻口，可分绿豆、乌豆、水晶、紫芋等种类",
    "皮层酥松，色泽美观，馅料肥而不腻，口感酥脆",
    "采用了滇式火腿，饼皮疏松，馅料咸甜适口，有独特的滇式火腿香味",
    "甜度及皮馅比适中，重用麻油，口味清甜，口感脆松",
    "其表皮是油酥皮，小巧玲珑，洁白如玉，皮酥馅饱",
    "以芝麻为重要原料. 也被称为——衢州麻饼",
    "以鲍鱼月饼、茶月饼、玉米月饼、无糖月饼等为主要特点，荤素兼备",
    "焦黄松软、香脆可口、绵甜悠长、油而不腻"
]

func initOptions() -> [Int] {
    var p = 0
    var index = [Int](repeating: 0, count: 4)
    while p < index.count {
        let rand = Int(arc4random() % UInt32(mooncakeNames.count))
        var exist = false
        for i in 0..<p {
            if index[i] == rand {
                exist = true
                break
            }
        }
        if !exist {
            index[p] = rand
            p += 1
        }
    }
    return index
}

struct MooncakeView: View {
    @State var title:String = "猜月饼"
    @State var hintText:String = "猜猜这是哪一种月饼"
    @State var optionIndex = initOptions()
    @State var ans:Int = Int(arc4random() % 4)
    @State var showAns:Bool = false
    @State var showResult: Bool = false
    @State var hintSize:Int = 50
    @State var mooncakeImageId = arc4random()
    @State var ansTimer:Timer!
    
    private func shuffle() {
        var p = 0
        while p < optionIndex.count {
            let rand = Int(arc4random() % UInt32(mooncakeNames.count))
            var exist = false
            for i in 0..<p {
                if optionIndex[i] == rand {
                    exist = true
                    break
                }
            }
            if !exist {
                optionIndex[p] = rand
                p += 1
            }
        }
        self.ans = Int(arc4random() % UInt32(optionIndex.count))
        self.mooncakeImageId = arc4random()
    }
    
    var body: some View {
        ZStack {
            MooncakeBackgroundView()
            
            TitleView(text: $title)
            
            HStack {
                ZStack {
                    Image("plate")
                    .resizable()
                        .frame(width: 500, height: 500)
                    
                    Image(mooncakeImages[self.optionIndex[self.ans]])
                        .scaleEffect(0.8)
                        .transition(.opacity)
                        .animation(.easeInOut(duration:     1.2))
//                        .frame(width: 390, height: 390)
                }.padding(.leading, 150)
                    .offset(x: self.showAns ? 200 : 0, y: 0)
                    .id(mooncakeImageId)
                
                VStack {
                    ForEach(0 ..< self.optionIndex.count) {i in
                        Button(action: {
                            
                        }) {
                            HStack {
                                Image("latern")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .padding(.trailing, 10)
                                    .foregroundColor(Color(#colorLiteral(red: 0.7803921569, green: 0.2039215686, blue: 0.1254901961, alpha: 1)))
                                Text(mooncakeNames[self.optionIndex[i]])
                                    .font(.custom("MaShanZheng-Regular", size: 45))
                                    .transition(.opacity)
                                .id(arc4random())
                                    .foregroundColor(.black)
                                
                                Image(i == self.ans ? "tick" : "fork")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(Color(#colorLiteral(red: 0.7803921569, green: 0.2039215686, blue: 0.1254901961, alpha: 1)))
                                    .padding(.leading, 10)
                                    .transition(.opacity)
                                    .opacity(self.showResult ? 1.0 : 0.0)
                            }.padding(.bottom, 40)
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 1.1)) {
                                        self.showResult = true
                                        self.ansTimer = Timer.scheduledTimer(withTimeInterval: 0.9, repeats: false, block: { timer in
                                            withAnimation(.easeInOut(duration: 1.1)) {
                                                self.showResult = false
                                                self.showAns = true
                                                self.title = mooncakeNames[self.optionIndex[self.ans]]
                                                self.hintText = mooncakeDescription[self.optionIndex[self.ans]]
                                                self.hintSize = 34
                                            }
                                        })

                                    }
                            }
                        }
                    }
                }.padding(.leading, 110)
                    .padding(.top, 60)
                    .opacity(self.showAns ? 0.0 : 1.0)
                
                VStack {
                    Button(action: {}) {
                        Text("继续")
                            .font(.custom("MaShanZheng-Regular", size: 50))
                            .foregroundColor(.black)
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 1.1)) {
                                    self.shuffle()
                                    self.title = "猜月饼"
                                    self.hintText = "猜猜这是哪一种月饼"
                                    self.showAns = false
                                    self.hintSize = 50
                                }
                        }
                    }
                    Button(action: {}) {
                        Text("返回")
                            .font(.custom("MaShanZheng-Regular", size: 45))
                            .foregroundColor(.black)
                    }.padding(.top, 70)
                }.offset(x: -120, y: 0)
                    .opacity(self.showAns ? 1 : 0)
                
                Spacer()
            }
            
            MooncakeHintView(hintText: $hintText, hintSize: $hintSize)
        }
    }
}

struct MooncakeBackgroundView: View {
    var body: some View {
        ZStack {
            Image("mooncake-background")
                .resizable()
                .frame(width: 1200, height: 850)
                .edgesIgnoringSafeArea(.all)
        }
    }
}

struct MooncakeHintView: View {
    @Binding var hintText:String
    @Binding var hintSize:Int
    var body: some View {
        VStack {
            Spacer()
            Text(self.hintText)
                .font(.custom("MaShanZheng-Regular", size: CGFloat(self.hintSize)))
                .padding(.bottom, 60)
                .foregroundColor(.white)
                .transition(.opacity)
                .id(self.hintText)
        }
    }
}

struct MooncakeView_Previews: PreviewProvider {
    static var previews: some View {
        MooncakeView().previewLayout(.fixed(width: 1112, height: 834))
    }
}
