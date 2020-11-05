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
    @State var hint:String = "猜猜这是哪一种月饼"
    @State var optionIndex = initOptions()
    @State var ans:Int = Int(arc4random() % 4)
    
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
//                    .resizable()
//                        .frame(width: 390, height: 390)
                }.padding(.leading, 150)
                
                VStack {
                    ForEach(0 ..< self.optionIndex.count) {i in
                        HStack {
                            Image("latern")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .padding(.trailing, 10)
                            Text(mooncakeNames[self.optionIndex[i]])
                                .font(.custom("MaShanZheng-Regular", size: 45))
                        }.padding(.bottom, 40)
                            .onTapGesture {
                                if i == self.ans {
                                    self.shuffle()
                                }
                        }
                    }
                }.padding(.leading, 110)
                    .padding(.top, 60)
                Spacer()
            }
            HintView(hintText: $hint)
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

struct MooncakeView_Previews: PreviewProvider {
    static var previews: some View {
        MooncakeView().previewLayout(.fixed(width: 1112, height: 834))
    }
}
