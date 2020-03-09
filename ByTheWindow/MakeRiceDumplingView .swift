//
//  MakeRiceDumplingView.swift
//  ByTheWindow
//
//  Created by 童翰文 on 2020/3/6.
//  Copyright © 2020 JJAYCHEN. All rights reserved.
//

import SwiftUI

struct MakeRiceDumplingView: View {
    @State var titleText = "煮粽叶"
    @State var showWater = false
    @State var tapsOnWater = 0
    @State var onFire = false
    @State var fireCount = 0
    @State var fireScale : CGFloat = 1
    @State var fireTimer : Timer!
    
    var body: some View {
        ZStack {
            TableBackgroundView()
            
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
                        }
                }
                
                VStack {
                    Image("switch")
                    .resizable()
                        .frame(width: 90, height: 90)
                        .rotationEffect(self.onFire ? Angle.degrees(90) : Angle.degrees(0))
                        .onTapGesture {
                            withAnimation(.spring()) {
                                self.onFire.toggle()
                                if self.onFire {
                                    self.fireTimer = Timer.scheduledTimer(withTimeInterval: 0.2,
                                                                          repeats: true,
                                                                          block: { timer in
                                                                            self.fireCount += 1
                                                                            self.fireScale = CGFloat(Float(arc4random()) / Float(UInt32.max)) * 0.3 + 0.8
                                     
                                    })
                                } else {
                                    self.fireTimer.invalidate()
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
                .opacity(showWater ? 0.7 : 0)
                .onTapGesture {
                    withAnimation() {
                        self.tapsOnWater += 1
                        print("\(self.tapsOnWater)")
                    }
            }
            
            TitleView(text: $titleText)
            
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
                .frame(width: 1112, height: 834)
                .edgesIgnoringSafeArea(.all)
            
            Image("tablecloth")
                .resizable()
                .frame(width:2 * screen.width, height: screen.height / 2)
        }
    }
}

struct TitleView: View {
    @Binding var text:String
    var body: some View {
        VStack {
            Text(self.text)
                .font(.custom("MaShanZheng-Regular", size: 70))
                .padding(.top, 20)
                .foregroundColor(Color(#colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)))
            Spacer()
        }
    }
}
