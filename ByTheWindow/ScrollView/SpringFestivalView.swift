//
//  SpringFestivalView.swift
//  ByTheWindow
//
//  Created by 徐滔锴 on 2020/3/2.
//  Copyright © 2020 JJAYCHEN. All rights reserved.
//

import SwiftUI


struct Cards : Identifiable {
    var id = UUID()
    var image : String
    var words : String
    func getView() -> AnyView? {
        
        switch image {
        case "border03":
            return AnyView(MatchCoupletView())
        case "border04":
            return AnyView(CoupletView())
        case "border05":
            return AnyView(ARCoupletView())
        case "border06":
            return AnyView(GreetingCardView())
        case "border07":
            return  AnyView(LanternRiddle())
        default:
            return nil
        }
    }
    
}

let cards = [
    Cards(image: "border01", words: "words01"),
    Cards(image: "border02", words: "words02"),
    Cards(image: "border03", words: "words03"),
    Cards(image: "border04", words: "words04"),
    Cards(image: "border05", words: "words05"),
    Cards(image: "border06", words: "words06"),
    Cards(image: "border07", words: "words07"),
]



struct SpringFestivalView: View {
    @State var viewState : CGFloat = 0
    @State var jesState = CGSize.zero
    var body: some View {
        
        HStack(spacing: 0){
            HStack(spacing: 0) {
                ForEach(cards) { item in
                    GeometryReader { geometry in
                        //CardView
                        ZStack{
                            Image(item.image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height : screen.height)
                            
                            
                            Image(item.words)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height : screen.height)
                                .shadow(color: Color.white.opacity(0.2), radius: 120, x: 0, y: 13)
                                .position(x: (geometry.frame(in: .global).minX + screen.width)/2, y: screen.height/2)
                            
                            
                        }
                        
                    }
                    //CardView
                }
                .frame(width: screen.width, height: screen.height)
                .offset(x: screen.width*3)
                    
                    .offset(x: self.jesState.width)
                    .offset(x: self.viewState)

                .animation(.linear(duration: 0))
                    
                       
        

                .gesture(
                    DragGesture()
                     .onChanged{value in
                         self.jesState = value.translation
                         
                    }
                        .onEnded{ value in
                            if value.translation.width > 100
                            {
                                self.viewState += screen.width
                            }
                            if value.translation.width < -100
                            {
                                self.viewState -= screen.width
                            }
                            self.jesState = .zero
                    }
                    
                )
                
            }
            
        }
            
       
        
        
        
        
        
    }
}



struct SpringFestivalView_Previews: PreviewProvider {
    static var previews: some View {
        SpringFestivalView()
            .previewLayout(.fixed(width: 1112, height: 834))
        
    }
}


