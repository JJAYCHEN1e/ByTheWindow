//
//  LanternRiddle.swift
//  ByTheWindow
//
//  Created by 徐滔锴 on 2020/2/17.
//  Copyright © 2020 JJAYCHEN. All rights reserved.
//
import SwiftUI





func toVertical(toChange aString  :String) -> String {
    
    if aString == "" {return aString}
    var target :String = ""
    for aChar in aString {
        target.append(aChar)
        target += "\n"
    }
    target.removeLast()
    return target
}



func generateIndex(toGenerate index: Int)-> Int{
    var result: Int
    result = index
    if result >= Riddles.count
    {return result-Riddles.count }else
    {return result}
    
}

struct LanternRiddle: View {

    @State var index :Int = 0
    @State var index2 :Int = 1
    @State var index3 :Int = 2
    @State var showResultLeft: Bool = false
    @State var showResultMiddle: Bool = false
    @State var showResultRight: Bool = false
    @State var update = false
    @State var timer: Timer!
    @State var updateOpacity: Bool = true
    @EnvironmentObject var navigation: NavigationStack
    var body: some View {
        
        
        ZStack {
            
            Image("RiddleBackground")
            
            HStack(spacing: 30) {
                RiddleView(showResult: $showResultLeft, update: $update, index:  $index, updateOpacity: $updateOpacity)
                RiddleView(showResult: $showResultMiddle, update: $update, index: $index2, updateOpacity: $updateOpacity)
                RiddleView(showResult: $showResultRight, update: $update, index: $index3, updateOpacity: $updateOpacity)
                
            }
            .offset(x: -20)
            
            ZStack {
                Button(action: {
                    self.updateOpacity.toggle()
                    self.showResultLeft = false
                    self.showResultRight = false
                    self.showResultMiddle = false
                    
                    
                    
                    self.timer = Timer.scheduledTimer(
                        withTimeInterval: ((self.showResultMiddle || self.showResultRight || self.showResultLeft) ? 0.7 : 0.4 ),
                        repeats: false,
                        block:
                        { timer in
                            self.index = generateIndex(toGenerate: self.index + 3)
                            self.index2 = generateIndex(toGenerate: self.index2 + 3)
                            self.index3 = generateIndex(toGenerate: self.index3 + 3)
                            
                    }
                    )
                    
                    self.timer = Timer.scheduledTimer(
                        withTimeInterval: ((self.showResultMiddle || self.showResultRight || self.showResultLeft) ? 0.9 : 0.6 ),
                        repeats: false,
                        block:
                        { timer in
                            self.updateOpacity.toggle()
                            
                    }
                    )
                    
                    //                    self.timer.invalidate()
                    
                }) {
                    HStack {
                        

                        
                        Text(update ? "true" : "false")
                            .font(.custom("?| ", size: 40))
                            .foregroundColor(Color.white)
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 12)
                            .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 2)
                    }
                }
            }
            .offset(x:470 , y: -282)
            
            Text("返回")
            .font(.custom("?| ", size: 40))
            .foregroundColor(Color.white)
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 12)
            .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 2)
            .offset(x:470 , y: -345)
                .onTapGesture {
                    withAnimation(){
                        self.navigation.unwind()
                    }
            }
        }
        
    }
}


struct LanternRiddle_Previews: PreviewProvider {
    static var previews: some View {
        LanternRiddle()
            .previewLayout(.fixed(width: 1112, height: 834))
    }
}


struct Riddle {
    var id = UUID()
    var riddleContent : String
    var secondContent : String?
    
    var riddleTip : String
    var riddleAnswer : String
    var riddleLevel: Int
}

let Riddles = [
    Riddle(riddleContent: "十五夜三更,黄袍已加身", riddleTip: "打一成语", riddleAnswer: "望子成龙", riddleLevel: 1),
    Riddle(riddleContent: "一只罐,两个口", secondContent: "只装火,不装酒",riddleTip: "打一日常用品", riddleAnswer: "灯笼", riddleLevel: 1),
    Riddle(riddleContent: "层云隐去月当头", riddleTip: "打一字", riddleAnswer: "屑", riddleLevel: 1),
    Riddle(riddleContent: "年终岁尾，不缺鱼米", riddleTip: "打一字", riddleAnswer: "鳞", riddleLevel: 1),
    Riddle(riddleContent: "久旱逢甘露", riddleTip: "打一水浒人物", riddleAnswer: "宋江", riddleLevel: 1),
    Riddle(riddleContent: "葱姜蒜皆可治病",riddleTip: "打一宋代词人", riddleAnswer: "辛弃疾", riddleLevel: 1),
    Riddle(riddleContent: "中间是火山，四边是大海", secondContent: "海里宝贝多，快快捞上来",riddleTip: "打一美食", riddleAnswer: "火锅", riddleLevel: 1),
    Riddle(riddleContent: "七仙女嫁出去一个",riddleTip: "打一成语", riddleAnswer: "六神无主", riddleLevel: 1),
    Riddle(riddleContent: "妇女节前夕",riddleTip: "打一中药名", riddleAnswer: "三七", riddleLevel: 1),
    Riddle(riddleContent: "远看像头牛，近看没有头",riddleTip: "打一字", riddleAnswer: "午", riddleLevel: 1),
    
]

struct RiddleView: View {
    @Binding var showResult: Bool
    @Binding var update: Bool
    @Binding var index: Int
    @Binding var updateOpacity: Bool
    
    
    var body: some View {
        
        VStack {
            
            Image("RiddleLantern")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 250)
            ZStack {
                
                
                Image("RiddleCouplet")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 205)
                    .rotation3DEffect(
                        showResult ? Angle.degrees(180) : Angle.degrees(0),
                        axis: (x: 0 , y: 1, z: 0))
                    
                    .animation(.easeInOut(duration: 0.6))
                    .onTapGesture {
                        self.showResult.toggle()
                }
                .offset(y: -7)
                
                
                Text(toVertical(toChange: Riddles[generateIndex(toGenerate: index)].riddleAnswer))
                    .font(.custom("?| ", size: 50))
                    .lineSpacing(20)
                    .animation(.easeInOut(duration: 0.1))

                    .opacity(updateOpacity ? 1 : 0)
                    .animation(.easeInOut(duration: 0.4))
                    
                    //                .opacity(showResult ? 1 : 0)
                    .rotation3DEffect(
                        showResult ? Angle.degrees(0) : Angle.degrees(-90),
                        axis: (x: 0 , y: 1, z: 0))
                    .animation(Animation.easeInOut(duration: 0.3)
                        .delay(showResult ? 0.3 : 0)
                )
                    
                    .offset(y: -30)
                
                
                ZStack {
                    Text(toVertical(toChange: Riddles[generateIndex(toGenerate: index)].riddleTip))
                        .font(.custom("MaShanZheng-Regular", size: 25))
                        //                .lineSpacing()
                        .offset(x: -52 ,y: 190)
                    
                    HStack {
                        
                        Text(toVertical(toChange: Riddles[generateIndex(toGenerate: index)].secondContent ?? ""))
                            .font(.custom("?| ", size: 36))
                        
                        Text(toVertical(toChange: Riddles[generateIndex(toGenerate: index)].riddleContent))
                            .font(.custom("?| ", size: 36))
                    }
                    .offset(x: 4, y: -50)
                    //            .opacity(showResult ? 0 : 1)
                    
                }
                    .animation(.easeInOut(duration: 0.1))

                .opacity(updateOpacity ? 1 : 0)
                .animation(.easeInOut(duration: 0.4))
                    
                .rotation3DEffect(
                    showResult ?  Angle.degrees(90) :Angle.degrees(0),
                    axis: (x: 0 , y: 1, z: 0))
                    .onTapGesture {
                        self.showResult.toggle()
                }
                .animation(Animation.easeInOut(duration: 0.3)
                .delay(showResult ? 0 : 0.3)
                )
                
                
                
                
            }
            
        }
    }
}
