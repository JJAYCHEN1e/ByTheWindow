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
                    
                    Image(systemName: "xmark.circle")
                        .onTapGesture {
                            withAnimation() {
                                self.navigation.advance(NavigationItem(view: AnyView(CoupletView().transition(.asymmetric(insertion: .scale, removal: .opacity)))))
                            }
                    }
                    .padding()
                }
                .transition(.asymmetric(insertion: AnyTransition.scale(scale: 1).combined(with: .opacity).animation(.easeInOut), removal: AnyTransition.scale(scale: 1.3).combined(with: .opacity).animation(.easeInOut)))
                
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
                    Text("爆竹声中一岁除，春风送暖入屠苏。") .font(.custom("MaShanZheng-Regular", size: 18))
                        .padding(.top, 20)
                    Text("——《元旦》 王安石")
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
                ForEach(0 ..< 5) { item in
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
                }
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
