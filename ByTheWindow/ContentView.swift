//
//  ContentView.swift
//  ByTheWindow
//
//  Created by JJAYCHEN on 2020/2/4.
//  Copyright © 2020 JJAYCHEN. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State var showGreetingCard = false
    
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
                            self.showGreetingCard.toggle()
                    }
                    .padding()
                    
                }
                .transition(.asymmetric(insertion: AnyTransition.scale(scale: 1).combined(with: .opacity).animation(.easeInOut), removal: AnyTransition.scale(scale: 1.3).combined(with: .opacity).animation(.easeInOut)))
                
            }
            
            if showGreetingCard {
//                GreetingCardViewControllerRepresentation()
//                    .transition(AnyTransition.scale.combined(with: .opacity).animation(Animation.easeInOut))
                
                CanvasMainViewControllerRepresentation()
                    .transition(AnyTransition.scale.combined(with: .opacity).animation(Animation.easeInOut))
            }
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().previewLayout(.fixed(width: 1112, height: 834))
    }
}

struct HeadView: View {
    var body: some View {
        HStack {
            Text("窗前")
                .font(.system(size: 60, weight: .bold))
            Spacer()
        }
    }
}

struct FestivalCard: View {
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("春节")
                        .font(.title)
                        .bold()
                    
                    Text("一年之岁首")
                        .font(.headline)
                }
                Spacer()
            }
            .padding(30)
            Spacer()
        }
        .frame(width: 360, height: 560)
        .background(Color.gray)
        .cornerRadius(40)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
    }
}

struct MainView: View {
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 50) {
                ForEach(0 ..< 5) { item in
                    GeometryReader { geometry in
                        FestivalCard()
                            .rotation3DEffect(Angle(degrees: Double((geometry.frame(in: .global).minX) - 50) / -200), axis: (x: 0, y: 10, z: 0))
                            .scaleEffect(CGFloat(1 - abs(geometry.frame(in: .global).minX - 50) / 3000), anchor: .leading)
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
