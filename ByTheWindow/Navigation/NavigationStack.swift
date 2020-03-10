//
//  NavigationStack.swift
//  ByTheWindow
//
//  Created by 童翰文 on 2020/2/26.
//  Copyright © 2020 JJAYCHEN. All rights reserved.
//

import SwiftUI

struct NavigationItem {
    var view: AnyView
}

final class NavigationStack: ObservableObject {

    @Published var viewStack: [NavigationItem] = []
    @Published var currentView: NavigationItem
    @Published var direction = 0
    
    init(_ currentView: NavigationItem) {
        self.currentView = currentView
    }
    
    /**
     后退
     */
    func unwind() {
        if viewStack.count == 0 {
            return
        }
        let last = self.viewStack.count - 1
        self.direction = 0
        self.currentView = self.viewStack[last]
        self.viewStack.remove(at: last)
    }
    
    /**
     前进
     */
    func advance(_ view : NavigationItem) {
        
            viewStack.append(self.currentView)
            self.direction = 1
            self.currentView = view
            
        
    }
}

