//
//  Helper Views.swift
//  ByTheWindow
//
//  Created by JJAYCHEN on 2020/2/18.
//  Copyright © 2020 JJAYCHEN. All rights reserved.
//

import SwiftUI

/// Help to get the size of the component. So you can user it in ohter places.
/// More Info: https://stackoverflow.com/questions/56729619/what-is-geometry-reader-in-swiftui
struct GeometryGetter: View {
    @Binding var rect: CGRect
//    @Binding var initialized: Bool

    var body: some View {
        return GeometryReader { geometry in
            self.makeView(geometry: geometry)
        }
    }

    func makeView(geometry: GeometryProxy) -> some View {
//        if !initialized {
            DispatchQueue.main.async {
                // Set the frame size.
                self.rect = geometry.frame(in: .global)
//                self.initialized = true
            }
//        }
        
        // It will not affect the visual effect.
        return Rectangle().fill(Color.clear)
    }
}
