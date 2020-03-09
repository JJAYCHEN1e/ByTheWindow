//
//  CardView.swift
//  ByTheWindow
//
//  Created by 徐滔锴 on 2020/3/9.
//  Copyright © 2020 JJAYCHEN. All rights reserved.
//

import SwiftUI

struct CardView: View {
    var showCard : Cards
    
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
                
                
            }.animation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0.3))
            

        }
        

    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(showCard: cards[0])
    }
}
