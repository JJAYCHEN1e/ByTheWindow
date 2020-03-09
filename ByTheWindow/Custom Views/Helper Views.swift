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
    
    var body: some View {
        return GeometryReader { geometry in
            self.makeView(geometry: geometry)
        }
    }
    
    func makeView(geometry: GeometryProxy) -> some View {
        DispatchQueue.main.async {
            // Set the frame size.
            self.rect = geometry.frame(in: .global)
        }
        
        // It will not affect the visual effect.
        return Rectangle().fill(Color.clear)
    }
}

/// More info: https://forums.developer.apple.com/thread/123951
struct ShareSheet: UIViewControllerRepresentable {
    typealias Callback = (_ activityType: UIActivity.ActivityType?, _ completed: Bool, _ returnedItems: [Any]?, _ error: Error?) -> Void
      
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    let excludedActivityTypes: [UIActivity.ActivityType]? = nil
    let callback: Callback? = nil
      
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities)
        controller.excludedActivityTypes = excludedActivityTypes
        controller.completionWithItemsHandler = callback
        return controller
    }
      
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // nothing to do here
    }
}
