//
//  HomeView.swift
//  ByTheWindow
//
//  Created by 童翰文 on 2020/2/26.
//  Copyright © 2020 JJAYCHEN. All rights reserved.
//

import SwiftUI
/**
 作为首页
 */
struct HomeView: View {
    /**
     实例化NavigationStack，注入为全局变量
     */
    var navigation = NavigationStack(NavigationItem(view: AnyView(ContentView())))
    
    var body: some View {
        NavigationHost()
        .environmentObject(navigation)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView().previewLayout(.fixed(width: 1112, height: 834))
    }
}
