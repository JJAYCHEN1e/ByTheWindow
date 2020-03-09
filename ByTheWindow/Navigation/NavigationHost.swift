//
//  NavigationHost.swift
//  ByTheWindow
//
//  Created by 童翰文 on 2020/2/26.
//  Copyright © 2020 JJAYCHEN. All rights reserved.
//

import SwiftUI

struct NavigationHost: View {
    // 需要使用跳转的View需要加入该EnvironmentObject
    @EnvironmentObject var navigation: NavigationStack
    
    var body: some View {
        ZStack{
           if self.navigation.direction == 0 {
            self.navigation.currentView.view
                .zIndex(0)
           } else {
                self.navigation.currentView.view
                    .zIndex(0)
           }
        }
    }
}

struct NavigationHost_Previews: PreviewProvider {
    static var previews: some View {
        NavigationHost()
    }
}
