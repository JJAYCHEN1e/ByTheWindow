//
//  GreetingCardView.swift
//  ByTheWindow
//
//  Created by JJAYCHEN on 2020/2/16.
//  Copyright © 2020 JJAYCHEN. All rights reserved.
//

import SwiftUI
import PencilKit

struct GreetingCardView: View {
    @State var allowsFingerDrawing = true
    @State var clearAction: () -> () = {}
    @State var handWrittenToggleAction: () -> () = {}
    
    
    var body: some View {
        ZStack {
            Image("GreetingCard00")
                .resizable()
                .aspectRatio(contentMode: .fit)
            
            
            Text(
                """
                今年过节送你福，福来运来幸福来，
                人旺运旺财运旺，大吉大利好预兆，
                顺心顺利更如意，幸福快乐更逍遥，
                恭贺新春快乐，吉祥好运，
                健康平安，心想事成！
                """
            )
                .font(.custom("MaShanZheng-Regular", size: 40))
                .foregroundColor(Color(#colorLiteral(red: 0.9803134799, green: 0.9679825902, blue: 0.6949725151, alpha: 1)))
                .offset(x: -120, y: 0)
            
            PencilKitView(allowsFingerDrawing: $allowsFingerDrawing, clearAction: $clearAction, handWrittenToggleAction: $handWrittenToggleAction)
            
            VStack {
                HStack {
                    ButtonWithBlurBackground(
                        action: {
                            //  self.allowsFingerDrawing.toggle()
                            self.handWrittenToggleAction()
                    },
                        imageName: "hand.draw",
                        color: allowsFingerDrawing ? Color.blue : Color.white.opacity(0.9),
                        size: 34
                    )
                    
                    Spacer()
                    
                    ButtonWithBlurBackground(action: {
                        self.clearAction()
                    }, imageName: "trash")
                }
                .padding()
                Spacer()
            }
        }
    }
}

struct GreetingCardView_Previews: PreviewProvider {
    static var previews: some View {
        GreetingCardView(clearAction: {
            
        }, handWrittenToggleAction: {
            
        }).previewLayout(.fixed(width: 1112, height: 834))
    }
}
