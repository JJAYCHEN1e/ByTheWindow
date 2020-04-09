//
//  PageView.swift
//  ByTheWindow
//
//  Created by 徐滔锴 on 2020/3/9.
//  Copyright © 2020 JJAYCHEN. All rights reserved.
//

import SwiftUI

struct PageView<Page: View>: View {
    @EnvironmentObject var navigation: NavigationStack
    var viewControllers: [UIHostingController<Page>]
    @State var currentPage = 0
//    @EnvironmentObject var rightPage = 0
    init(_ views: [Page]) {
        self.viewControllers = views.map { UIHostingController(rootView: $0) }
    }

    var body: some View {
        
        VStack {
            ZStack {
                PageViewController(controllers: viewControllers, currentPage: $currentPage)
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
        }
    }
}

struct PageView_Preview: PreviewProvider {
    static var previews: some View {
        PageView(
            cards.map{ CardView(showCard: $0) }
            )
    }
}
