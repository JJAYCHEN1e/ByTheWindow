//
//  ContentView.swift
//  ByTheWindow
//
//  Created by JJAYCHEN on 2020/2/4.
//  Copyright © 2020 JJAYCHEN. All rights reserved.
//

import SwiftUI
import UIKit

let screen = UIScreen.main.bounds

struct ContentView: View {
    // 需要使用跳转的View需要加入该EnvironmentObject
    @State var showGreetingCard = false
    @EnvironmentObject var navigation:NavigationStack
    
    var body: some View {
        ZStack {
            if !showGreetingCard {
                VStack() {
                    HeadView()
                        .padding(20)
                    
                    Spacer()
                    
                    MainView()
                    
                    Spacer()
                }
            }
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewLayout(.fixed(width: 1112, height: 834)) // iPad Air 10.5
//            .previewLayout(.fixed(width: 1080, height: 810)) // iPad 7th
//            .previewLayout(.fixed(width: 1194, height: 834)) // iPad Pro 11"
//            .previewLayout(.fixed(width: 1366, height: 1024)) // iPad Pro 12.9"
//            .previewLayout(.fixed(width: 1024, height: 768)) // iPad mini5, iPad Pro 9.7"
    }
}

struct HeadView: View {
    var body: some View {
        HStack {
            Text("窗前")
                .font(.custom("MaShanZheng-Regular", size: 60))
            Spacer()
        }.padding(.top, 30)
            .padding(.leading, 10)
    }
}

struct FestivalCard: View {
    var cardImage: String = "spring-festival"
    var barColor: Color = Color(#colorLiteral(red: 0.7607843137, green: 0.003921568627, blue: 0, alpha: 1))
    var barImage: String = "latern"
    var cardText: String = "春节"
    var verse: String = "爆竹声中一岁除，春风送暖入屠苏。"
    var author: String = "——《元旦》 王安石"
    
    var body: some View {
        VStack {
            Image(cardImage)
                .resizable()
                .frame(width: 330, height: 330)
                .shadow(color: Color(#colorLiteral(red: 0.7607843137, green: 0.003921568627, blue: 0, alpha: 1)).opacity(0.3), radius: 10, x: 0, y: 12)
            BarDecorationView(color: barColor, image: barImage)
            VStack(alignment: .center) {
                Text(cardText)
                    .font(.custom("MaShanZheng-Regular", size: 35))
                    .padding(.top, 15)
                    .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 0)
                VStack(alignment: .trailing, spacing: 15) {
                    Text(verse) .font(.custom("MaShanZheng-Regular", size: 18))
                        .padding(.top, 20)
                    Text(author)
                        .font(.custom("MaShanZheng-Regular", size: 18))
                }
            }
        }
    }
}

struct MainView: View {
    @EnvironmentObject var navigation: NavigationStack
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 100) {
                GeometryReader { geometry in
                    FestivalCard()
                        .rotation3DEffect(Angle(degrees: Double((geometry.frame(in: .global).minX) - 50) / -200), axis: (x: 0, y: 10, z: 0))
                        .scaleEffect(CGFloat(1 - abs(geometry.frame(in: .global).minX - 50) / 3000), anchor: .leading)
                        .onTapGesture {
                            withAnimation() {
                                self.navigation.advance(NavigationItem(view: AnyView(PageView(            cards.map{CardView(showCard: $0) }).transition(.asymmetric(insertion: .scale, removal: .opacity)))))
                                
                            }
                    }
                }
                .frame(width: 360, height: 560)
                GeometryReader { geometry in
                    FestivalCard(cardImage: "dragon-boat-festival", cardText: "端午", verse: "正是浴兰时节动。菖蒲酒美清尊共。", author: "——《渔家傲》 欧阳修")
                        .rotation3DEffect(Angle(degrees: Double((geometry.frame(in: .global).minX) - 50) / -200), axis: (x: 0, y: 10, z: 0))
                        .scaleEffect(CGFloat(1 - abs(geometry.frame(in: .global).minX - 50) / 3000), anchor: .leading)
                        .onTapGesture {
                            withAnimation() {
                                self.navigation.advance(NavigationItem(view: AnyView(PageView(            lanternFestivalCards.map{CardView(showCard: $0) }).transition(.asymmetric(insertion: .scale, removal: .opacity)))))
                                
                            }
                    }
                }
                .frame(width: 360, height: 560)
                GeometryReader { geometry in
                    FestivalCard(cardImage: "mid-autumn-festival", cardText: "中秋", verse: "但愿人长久，千里共婵娟。", author: "——《水调歌头》 苏轼")
                        .rotation3DEffect(Angle(degrees: Double((geometry.frame(in: .global).minX) - 50) / -200), axis: (x: 0, y: 10, z: 0))
                        .scaleEffect(CGFloat(1 - abs(geometry.frame(in: .global).minX - 50) / 3000), anchor: .leading)
                        .onTapGesture {
                            withAnimation() {
                                self.navigation.advance(NavigationItem(view: AnyView(PageView(            midAutumnFestivalCards.map{CardView(showCard: $0) }).transition(.asymmetric(insertion: .scale, removal: .opacity)))))
                                
                            }
                    }
                }
                .frame(width: 360, height: 560)
            }
            .padding(.leading, 50)
            .padding(.trailing, 376)
            .padding(.vertical, 50)
            
        }
    }
}

struct BarDecorationView: View {
    var color: Color = Color(#colorLiteral(red: 0.7607843137, green: 0.003921568627, blue: 0, alpha: 1))
    var image: String = "latern"
    
    var body: some View {
        HStack {
            Rectangle()
                .frame(width: 120, height: 4)
                .cornerRadius(4)
                .foregroundColor(color)
                .opacity(0.4)
            Image(image)
                .resizable()
                .frame(width: 30, height: 30)
            Rectangle()
                .frame(width: 120, height: 4)
                .cornerRadius(4)
                .foregroundColor(color)
                .opacity(0.4)
        }
    }
}
