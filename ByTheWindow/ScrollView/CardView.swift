//
//  CardView.swift
//  ByTheWindow
//
//  Created by 徐滔锴 on 2020/3/9.
//  Copyright © 2020 JJAYCHEN. All rights reserved.
//

import SwiftUI

struct CardView: View {
    @EnvironmentObject var navigation: NavigationStack
    var showCard : Cards
    @State var isShowCard : Bool = true
    var body: some View {
        GeometryReader { geometry in
        ZStack {
            Image(self.showCard.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: screen.width, height: screen.height)
                
            
            Image(self.showCard.words)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: screen.width, height: screen.height)
                 .shadow(color: Color.white.opacity(0.2), radius: 10, x: 0, y: 2)
                .position(x: (geometry.frame(in: .global).minX + screen.width)/2, y: screen.height/2)
            .onTapGesture {
                    withAnimation() {
                        if self.showCard.getView() != nil
                        {
                            self.navigation.advance(NavigationItem(view: AnyView(self.showCard.getView().transition(.asymmetric(insertion: .scale, removal: .scale)))))
                        }
                                                   }
            }
            Button(action: {
                withAnimation(){
                    self.navigation.unwind()
                }
            }) {
            Text("返回")
                .font(.custom("?| ", size: 40))
                .foregroundColor(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 12)
                .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 2)
            }
            .offset(x:470 , y: -320)
        
        }
        .scaleEffect(self.isShowCard ? 1 : 1.5)
        .opacity(self.isShowCard ? 1 : 0)
        .animation(.easeInOut(duration: 0.3))
            
            

        }
        

    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(showCard: cards[0])
    }
}
