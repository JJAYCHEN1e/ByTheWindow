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
        case "LanFesBorder_03":
            return AnyView(MakeRiceDumplingView())
        case "LanFesBorder_04":
            return AnyView(PerfumebagView())
        case "LanFesBorder_05":
            return nil;
        case "LanFesBorder_07":
            return AnyView(EggDrawingView())
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
    var body: some View {
        Text("Hello World")
    }
}



struct SpringFestivalView_Previews: PreviewProvider {
    static var previews: some View {
        SpringFestivalView()
            .previewLayout(.fixed(width: 1112, height: 834))
        
    }
}


